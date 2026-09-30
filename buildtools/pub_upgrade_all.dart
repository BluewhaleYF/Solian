// Upgrades the dependency sets of this repository, including every nested
// pubspec.yaml (packages/*, packages/*/example, ...).
//
// Run from the repository root:
//   dart run buildtools/pub_upgrade_all.dart --list
//   dart run buildtools/pub_upgrade_all.dart --dry-run
//   dart run buildtools/pub_upgrade_all.dart
//   dart run buildtools/pub_upgrade_all.dart --skip packages/flutter_math_fork -j 4
//
// Behavior:
//   * Discovers pubspec.yaml files below the repository root, skipping build
//     output, .dart_tool, third_party and dot directories.
//   * Uses `flutter pub upgrade` for Flutter packages and `dart pub upgrade`
//     for pure Dart packages (detected via `sdk: flutter`).
//   * Rewrites pubspec constraints to the latest resolvable versions
//     (--major-versions) unless --in-range is given.
//   * Deletes pubspec.lock files that the run creates where none existed
//     before (vendored library packages), unless --keep-locks is given.
//   * Runs nested packages first and the repository root last, so the app
//     resolves against the already-upgraded nested pubspecs.
//
// Exit code: 0 when every target upgraded/failed nothing, 1 if any target
// failed (bad tools, network, unresolvable constraints), 64 on bad usage.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _dependencyFreeDirs = {
  '.git',
  '.dart_tool',
  '.idea',
  '.vscode',
  'build',
  'node_modules',
  'third_party',
};

final _activeProcesses = <Process>{};

Future<void> main(List<String> arguments) async {
  final options = _Options.parse(arguments);
  final root = Directory.current.absolute;

  if (!File(_join(root.path, 'pubspec.yaml')).existsSync()) {
    _usage('no pubspec.yaml in ${root.path}; run from the repository root');
  }

  final targets = _discoverTargets(root, options);

  if (options.listOnly) {
    for (final target in targets) {
      stdout.writeln(_relative(root, target));
    }
    return;
  }

  if (targets.isEmpty) {
    _usage('no pubspec.yaml matched the given --only/--skip patterns');
  }

  final log = options.json ? stderr : stdout;
  log.writeln('root: ${root.path}');
  log.writeln(
    'mode: ${options.majorVersions ? '--major-versions' : '--in-range'}'
    '${options.dryRun ? ' (dry-run)' : ''}, ${targets.length} target(s), '
    'concurrency ${options.jobs}',
  );
  log.writeln('');

  final signals = SignalWatch.install(_activeProcesses);

  final stopwatch = Stopwatch()..start();
  final rootTargets = targets.where((d) => d.path == root.path).toList();
  final nestedTargets = targets.where((d) => d.path != root.path).toList();

  final reports = <_TargetReport>[
    ...await _runTargets(nestedTargets, options, root),
    ...await _runTargets(rootTargets, options, root),
  ];
  stopwatch.stop();

  // An active signal subscription keeps the event loop alive; without this the
  // process would never exit after the summary.
  await signals.cancel();

  final summary = _Summary(root: root, options: options, reports: reports, elapsed: stopwatch.elapsed);

  if (options.json) {
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(summary.toJson()));
  } else {
    summary.printTo(stdout);
  }

  exitCode = summary.failedReports.isEmpty ? 0 : 1;
}

class _Options {
  _Options();

  bool dryRun = false;
  bool majorVersions = true;
  bool tighten = false;
  bool offline = false;
  bool keepLocks = false;
  bool revertFailed = false;
  bool json = false;
  bool quiet = false;
  bool listOnly = false;
  // Targets are network-bound (each one re-resolves against the pub server),
  // hence the parallel default; pass -j 1 for interleaving-free output.
  int jobs = 4;
  Duration timeout = const Duration(minutes: 15);
  String dartBin = 'dart';
  String flutterBin = 'flutter';
  final List<_Glob> only = [];
  final List<_Glob> skip = [];

  static _Options parse(List<String> arguments) {
    final options = _Options();
    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      String valueOf(String name) {
        if (index + 1 >= arguments.length) _usage('$name requires a value');
        return arguments[++index];
      }

      switch (argument) {
        case '--dry-run' || '-n':
          options.dryRun = true;
        case '--in-range':
          options.majorVersions = false;
        case '--major-versions':
          options.majorVersions = true;
        case '--tighten':
          options.tighten = true;
        case '--offline':
          options.offline = true;
        case '--keep-locks':
          options.keepLocks = true;
        case '--revert-failed':
          options.revertFailed = true;
        case '--json':
          options.json = true;
        case '--quiet':
          options.quiet = true;
        case '--list':
          options.listOnly = true;
        case '--jobs' || '-j':
          options.jobs = int.tryParse(valueOf(argument)) ?? 0;
          if (options.jobs < 1) _usage('--jobs must be a positive integer');
        case '--timeout':
          final seconds = int.tryParse(valueOf(argument)) ?? 0;
          if (seconds < 1) _usage('--timeout must be a positive number of seconds');
          options.timeout = Duration(seconds: seconds);
        case '--dart-bin':
          options.dartBin = valueOf(argument);
        case '--flutter-bin':
          options.flutterBin = valueOf(argument);
        case '--only':
          options.only.add(_Glob(valueOf(argument)));
        case '--skip':
          options.skip.add(_Glob(valueOf(argument)));
        case '--help' || '-h':
          _usage(null);
        default:
          _usage('unknown argument: $argument');
      }
    }
    return options;
  }
}

Never _usage(String? message) {
  if (message != null) stderr.writeln('pub_upgrade_all: $message');
  stderr.writeln('''
Upgrades every pubspec.yaml in the repository (root + nested packages).

Usage: dart run buildtools/pub_upgrade_all.dart [options]

  -n, --dry-run         Report what pub would change; write nothing.
      --in-range        Only upgrade within existing constraints
                        (default: --major-versions rewrites pubspec.yaml).
      --tighten         Also raise lower bounds to the resolved versions.
      --offline         Resolve from the local pub cache only.
      --only <glob>     Restrict to matching directories (repeatable).
      --skip <glob>     Exclude matching directories (repeatable).
      --list            Print the directories that would be processed.
      --keep-locks      Keep pubspec.lock files created in directories that had
                        none (default: delete them).
      --revert-failed   Restore pubspec.yaml/pubspec.lock if a target fails.
  -j, --jobs <n>        Targets to process concurrently (default: 4, -j 1 to
                        serialize output).
      --timeout <sec>   Per-target timeout (default: 900).
      --dart-bin <exe>  dart executable (default: dart).
      --flutter-bin <exe>
                        flutter executable (default: flutter).
      --json            Print a JSON report to stdout (logs go to stderr).
      --quiet           Only print the summary.
  -h, --help            Show this message.
''');
  exitCode = 64;
  throw ArgumentError(message ?? 'help');
}

/// Kills in-flight `pub` child processes when the user interrupts the run.
class SignalWatch {
  static StreamSubscription<ProcessSignal> install(Set<Process> active) {
    return ProcessSignal.sigint.watch().listen((_) {
      for (final process in active.toList()) {
        process.kill(ProcessSignal.sigkill);
      }
      stdout.writeln('\ninterrupted; killed ${active.length} running pub process(es)');
      exit(130);
    });
  }
}

List<Directory> _discoverTargets(Directory root, _Options options) {
  final found = <Directory>[];

  void walk(Directory dir) {
    final entries = dir.listSync(followLinks: false);
    for (final entry in entries) {
      if (entry is! Directory) continue;
      final name = entry.uri.pathSegments.where((segment) => segment.isNotEmpty).last;
      if (name.startsWith('.') || _dependencyFreeDirs.contains(name)) continue;

      final relative = _relative(root, entry);
      if (options.skip.any((glob) => glob.matches(relative))) continue;

      if (File(_join(entry.path, 'pubspec.yaml')).existsSync()) found.add(entry);
      walk(entry);
    }
  }

  walk(root);
  if (File(_join(root.path, 'pubspec.yaml')).existsSync()) found.add(root);

  final filtered = found
      .where((dir) => options.only.isEmpty || options.only.any((glob) => glob.matches(_relative(root, dir))))
      .toList();

  // Deepest targets first, root last: the app resolves against nested pubspecs
  // that were already upgraded by this run.
  filtered.sort((a, b) {
    final depth = _depth(root, b).compareTo(_depth(root, a));
    if (depth != 0) return depth;
    return a.path.compareTo(b.path);
  });
  return filtered;
}

Future<List<_TargetReport>> _runTargets(List<Directory> targets, _Options options, Directory root) async {
  if (targets.isEmpty) return const [];

  final queue = List.of(targets);
  final reports = <_TargetReport>[];
  final progress = options.json || options.quiet ? null : stdout;

  Future<void> worker() async {
    while (queue.isNotEmpty) {
      final target = queue.removeAt(0);
      final report = await _upgradeTarget(target, options, root);
      reports.add(report);
      if (progress != null) _printReport(progress, report);
    }
  }

  await Future.wait(List.generate(options.jobs.clamp(1, targets.length), (_) => worker()));
  return reports;
}

Future<_TargetReport> _upgradeTarget(Directory target, _Options options, Directory root) async {
  final pubspec = File(_join(target.path, 'pubspec.yaml'));
  final lock = File(_join(target.path, 'pubspec.lock'));
  final pubspecBefore = pubspec.readAsStringSync();
  final lockExisted = lock.existsSync();
  final lockBefore = lockExisted ? lock.readAsStringSync() : null;

  final isFlutter = RegExp(r'^\s+sdk:\s*flutter\s*$', multiLine: true).hasMatch(pubspecBefore);
  final executable = isFlutter ? options.flutterBin : options.dartBin;
  final arguments = [
    'pub',
    'upgrade',
    // Discovery already covers example/ directories; avoid touching them twice.
    '--no-example',
    if (options.majorVersions) '--major-versions',
    if (options.tighten) '--tighten',
    if (options.offline) '--offline',
    if (options.dryRun) '--dry-run',
  ];

  final outcome = await _runProcess(executable, arguments, target, options.timeout);

  final lockExistsAfter = lock.existsSync();
  var lockFileRemoved = false;
  var lockFileCreated = false;

  if (!options.dryRun) {
    if (outcome.succeeded && !lockExisted && lockExistsAfter && !options.keepLocks) {
      lock.deleteSync();
      lockFileRemoved = true;
    } else if (!lockExisted && lockExistsAfter) {
      lockFileCreated = true;
    }

    if (!outcome.succeeded && options.revertFailed) {
      pubspec.writeAsStringSync(pubspecBefore);
      if (lockExisted) {
        lock.writeAsStringSync(lockBefore!);
      } else if (lockExistsAfter) {
        lock.deleteSync();
      }
    }
  }

  return _TargetReport(
    directory: target.path,
    relativePath: _relative(root, target),
    tool: executable,
    command: '$executable ${arguments.join(' ')}',
    outcome: outcome,
    summary: _PubOutput.parse(outcome.stdout),
    lockExistedBefore: lockExisted,
    lockFileRemoved: lockFileRemoved,
    lockFileCreated: lockFileCreated,
    reverted: !outcome.succeeded && options.revertFailed,
    dryRun: options.dryRun,
  );
}

Future<_ProcessOutcome> _runProcess(
  String executable,
  List<String> arguments,
  Directory workingDirectory,
  Duration timeout,
) async {
  final stopwatch = Stopwatch()..start();
  final Process process;
  try {
    process = await Process.start(executable, arguments, workingDirectory: workingDirectory.path);
  } on ProcessException catch (error) {
    return _ProcessOutcome(
      exitCode: 127,
      stdout: '',
      stderr: '$error',
      elapsed: stopwatch.elapsed,
      timedOut: false,
    );
  }

  _activeProcesses.add(process);
  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();
  final stdoutDone = process.stdout.transform(utf8.decoder).listen(stdoutBuffer.write).asFuture<void>();
  final stderrDone = process.stderr.transform(utf8.decoder).listen(stderrBuffer.write).asFuture<void>();

  var timedOut = false;
  int exitCode;
  try {
    exitCode = await process.exitCode.timeout(timeout);
  } on TimeoutException {
    timedOut = true;
    process.kill(ProcessSignal.sigkill);
    exitCode = await process.exitCode;
  }

  await Future.wait([stdoutDone, stderrDone]);
  _activeProcesses.remove(process);
  stopwatch.stop();

  return _ProcessOutcome(
    exitCode: timedOut ? 124 : exitCode,
    stdout: stdoutBuffer.toString(),
    stderr: stderrBuffer.toString(),
    elapsed: stopwatch.elapsed,
    timedOut: timedOut,
  );
}

/// The slice of `pub upgrade` output worth reporting.
class _PubOutput {
  const _PubOutput({
    required this.constraintChanges,
    required this.dependencyChanges,
    required this.changedPackages,
  });

  final List<_ConstraintChange> constraintChanges;
  final int dependencyChanges;

  /// Raw `pub upgrade` lines such as `+ archive 4.3.0` (added/downloaded) and
  /// `> dio 5.11.0 -> 5.11.1` (upgraded), without the leading marker.
  final List<String> changedPackages;

  static _PubOutput parse(String output) {
    final constraintChanges = <_ConstraintChange>[];
    final changedPackages = <String>[];
    var dependencyChanges = 0;
    var inConstraints = false;

    for (final line in const LineSplitter().convert(output)) {
      final trimmed = line.trimRight();

      if (RegExp(r'^(Would change|Changed) \d+ constraints? in pubspec\.yaml').hasMatch(trimmed)) {
        inConstraints = true;
        continue;
      }
      if (trimmed == 'No changes to pubspec.yaml!') {
        inConstraints = false;
        continue;
      }
      if (RegExp(r'^(Would change|Changed) \d+ dependencies').hasMatch(trimmed)) {
        dependencyChanges = int.parse(RegExp(r'\d+').firstMatch(trimmed)!.group(0)!);
        inConstraints = false;
        continue;
      }
      if (trimmed == 'No dependencies changed.') {
        inConstraints = false;
        continue;
      }

      if (inConstraints) {
        final match = RegExp(r'^\s*(\S+):\s*(.+?)\s*->\s*(.+)$').firstMatch(trimmed);
        if (match != null) {
          constraintChanges.add(_ConstraintChange(match.group(1)!, match.group(2)!, match.group(3)!));
          continue;
        }
      }

      if (trimmed.length > 2 && trimmed[1] == ' ' && ('+>-'.contains(trimmed[0]))) {
        changedPackages.add(trimmed.substring(2).trim());
      }
    }

    return _PubOutput(
      constraintChanges: constraintChanges,
      dependencyChanges: dependencyChanges,
      changedPackages: changedPackages,
    );
  }
}

class _ConstraintChange {
  const _ConstraintChange(this.name, this.from, this.to);

  final String name;
  final String from;
  final String to;

  Map<String, String> toJson() => {'name': name, 'from': from, 'to': to};
}

class _ProcessOutcome {
  const _ProcessOutcome({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.elapsed,
    required this.timedOut,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final Duration elapsed;
  final bool timedOut;

  bool get succeeded => exitCode == 0;
}

class _TargetReport {
  const _TargetReport({
    required this.directory,
    required this.relativePath,
    required this.tool,
    required this.command,
    required this.outcome,
    required this.summary,
    required this.lockExistedBefore,
    required this.lockFileRemoved,
    required this.lockFileCreated,
    required this.reverted,
    required this.dryRun,
  });

  final String directory;
  final String relativePath;
  final String tool;
  final String command;
  final _ProcessOutcome outcome;
  final _PubOutput summary;

  /// False for vendored library packages that never tracked a lock file; in
  /// that case pub reports every dependency as "new", which is not an upgrade.
  final bool lockExistedBefore;
  final bool lockFileRemoved;
  final bool lockFileCreated;
  final bool reverted;
  final bool dryRun;

  bool get succeeded => outcome.succeeded;

  /// Only comparisons against a pre-existing pubspec.lock (or a rewritten
  /// constraint) mean anything; a fresh resolution has nothing to diff.
  bool get hasMeaningfulChanges =>
      summary.constraintChanges.isNotEmpty || (lockExistedBefore && summary.dependencyChanges > 0);

  String get status {
    if (!succeeded) return outcome.timedOut ? 'timeout' : 'failed';
    if (hasMeaningfulChanges) return dryRun ? 'would-change' : 'changed';
    return 'ok';
  }

  String get changeLabel {
    final parts = <String>[
      if (summary.constraintChanges.isNotEmpty) '${summary.constraintChanges.length} constraint(s)',
      if (lockExistedBefore && summary.dependencyChanges > 0) '${summary.dependencyChanges} package(s)',
      if (!lockExistedBefore) 'resolved without pubspec.lock',
    ];
    return parts.isEmpty ? 'no changes' : parts.join(', ');
  }

  Map<String, Object?> toJson() => {
    'directory': relativePath,
    'tool': tool,
    'command': command,
    'status': status,
    'exitCode': outcome.exitCode,
    'elapsedMs': outcome.elapsed.inMilliseconds,
    'constraintChanges': summary.constraintChanges.map((change) => change.toJson()).toList(),
    'dependencyChanges': summary.dependencyChanges,
    'lockExistedBefore': lockExistedBefore,
    'changedPackages': summary.changedPackages,
    'lockFileRemoved': lockFileRemoved,
    'lockFileCreated': lockFileCreated,
    'reverted': reverted,
    'stdout': outcome.stdout,
    'stderr': outcome.stderr,
  };
}

class _Summary {
  const _Summary({
    required this.root,
    required this.options,
    required this.reports,
    required this.elapsed,
  });

  final Directory root;
  final _Options options;
  final List<_TargetReport> reports;
  final Duration elapsed;

  List<_TargetReport> get failedReports => reports.where((report) => !report.succeeded).toList();

  Map<String, Object?> toJson() => {
    'root': root.path,
    'dryRun': options.dryRun,
    'majorVersions': options.majorVersions,
    'elapsedMs': elapsed.inMilliseconds,
    'targets': reports.map((report) => report.toJson()).toList(),
    'totals': {
      'targets': reports.length,
      'failed': failedReports.length,
      'constraintsChanged': reports.fold<int>(0, (sum, r) => sum + r.summary.constraintChanges.length),
      'packagesChanged': reports
          .where((report) => report.lockExistedBefore)
          .fold<int>(0, (sum, r) => sum + r.summary.dependencyChanges),
      'targetsWithoutLock': reports.where((report) => !report.lockExistedBefore).length,
    },
  };

  void printTo(IOSink sink) {
    final ordered = reports.toList()
      ..sort((a, b) {
        if (a.relativePath == '.') return -1;
        if (b.relativePath == '.') return 1;
        return a.relativePath.compareTo(b.relativePath);
      });

    final width = ordered.fold<int>(0, (max, report) => report.relativePath.length > max ? report.relativePath.length : max);
    final statusWidth = ordered.fold<int>(10, (max, report) => report.status.length > max ? report.status.length : max);

    sink.writeln('summary');
    for (final report in ordered) {
      final seconds = (report.outcome.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
      sink.writeln(
        '${report.relativePath.padRight(width)}  ${report.status.padRight(statusWidth)}'
        '${'${seconds}s'.padLeft(8)}  ${report.changeLabel}'
        '${report.lockFileRemoved ? '  [removed created pubspec.lock]' : ''}'
        '${report.lockFileCreated ? '  [new pubspec.lock]' : ''}'
        '${report.reverted ? '  [reverted]' : ''}',
      );

      for (final change in report.summary.constraintChanges) {
        sink.writeln('${' ' * width}    ${change.name} ${change.from} -> ${change.to}');
      }
      if (report.summary.changedPackages.isNotEmpty) {
        final shown = report.summary.changedPackages.take(8).join(', ');
        final rest = report.summary.changedPackages.length - 8;
        sink.writeln('${' ' * width}    packages: $shown${rest > 0 ? ' (+$rest more)' : ''}');
      }

      if (!report.succeeded) {
        final details = report.outcome.stderr.trim().isEmpty
            ? report.outcome.stdout.trim()
            : report.outcome.stderr.trim();
        final lines = details.isEmpty
            ? ['(no output; exit code ${report.outcome.exitCode})']
            : details.split('\n');
        for (final line in lines.take(15)) {
          sink.writeln('${' ' * width}    | $line');
        }
      }
    }

    final constraints = reports.fold<int>(0, (sum, report) => sum + report.summary.constraintChanges.length);
    final dependencies = reports
        .where((report) => report.lockExistedBefore)
        .fold<int>(0, (sum, report) => sum + report.summary.dependencyChanges);
    final fresh = reports.where((report) => !report.lockExistedBefore).length;
    final seconds = (elapsed.inMilliseconds / 1000).toStringAsFixed(1);
    sink.writeln('');
    sink.writeln(
      '${reports.length} target(s): ${reports.length - failedReports.length} ok, ${failedReports.length} failed; '
      '$constraints constraint(s), $dependencies package version(s) ${options.dryRun ? 'would change' : 'changed'}'
      '${fresh > 0 ? ', $fresh target(s) without pubspec.lock' : ''} in ${seconds}s',
    );
  }
}

/// Minimal glob: `*` matches within a path segment, `**` across segments.
class _Glob {
  _Glob(this.pattern) : _regex = _compile(pattern);

  final String pattern;
  final RegExp _regex;

  /// A pattern matches the directory itself or any ancestor of it, so
  /// `--only packages/foo` also selects `packages/foo/example`.
  bool matches(String relativePath) {
    if (_regex.hasMatch(relativePath)) return true;
    var index = relativePath.indexOf('/');
    while (index != -1) {
      if (_regex.hasMatch(relativePath.substring(0, index))) return true;
      index = relativePath.indexOf('/', index + 1);
    }
    return false;
  }

  static RegExp _compile(String pattern) {
    final buffer = StringBuffer('^');
    for (var index = 0; index < pattern.length; index++) {
      final character = pattern[index];
      switch (character) {
        case '*':
          if (index + 1 < pattern.length && pattern[index + 1] == '*') {
            buffer.write('.*');
            index++;
          } else {
            buffer.write('[^/]*');
          }
        case '?':
          buffer.write('[^/]');
        default:
          buffer.write(RegExp.escape(character));
      }
    }
    buffer.write(r'$');
    return RegExp(buffer.toString());
  }
}

String _join(String directory, String name) => directory.endsWith('/') ? '$directory$name' : '$directory/$name';

String _relative(Directory root, Directory dir) {
  if (dir.path == root.path) return '.';
  final rootPath = root.path.endsWith('/') ? root.path : '${root.path}/';
  return dir.path.startsWith(rootPath) ? dir.path.substring(rootPath.length) : dir.path;
}

int _depth(Directory root, Directory dir) => _relative(root, dir) == '.' ? 0 : _relative(root, dir).split('/').length;

/// Prints a per-target line as soon as it finishes.
void _printReport(IOSink sink, _TargetReport report) {
  final seconds = (report.outcome.elapsed.inMilliseconds / 1000).toStringAsFixed(1);
  sink.writeln('${report.status.padRight(12)} ${report.relativePath} (${seconds}s) — ${report.changeLabel}');
}
