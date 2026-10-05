// Re-exports intl's DateFormat, as the rest of the app uses it.
import 'package:easy_localization/easy_localization.dart';

/// Presentation rules for chat search results: the excerpt a result row
/// draws and the date span a room band summarises.
///
/// Everything here is pure — wire content in, presentation out — so the
/// sub-string and marking rules stay testable without a widget tree.

/// A body made of sticker tokens renders as an image, so it keeps the rich
/// renderer instead of an excerpt. Same token shape `MarkdownTextContent`
/// parses (`:pack+slug:`); keep the two in step.
final _stickerOnly = RegExp(r'^(?::[-\w]*\+[-\w]*:\s*)+$');

/// Spoiler bodies stay concealed in a result row: the index may hold the
/// text, the list must not print it.
final _spoiler = RegExp(r'=!([\s\S]*?)!=');
final _fencedCode = RegExp(r'```[\s\S]*?```');
final _inlineCode = RegExp(r'`([^`]*)`');
final _image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');
final _link = RegExp(r'\[([^\]]*)\]\(\s*[^)]*\)');
final _highlight = RegExp(r'==([\s\S]*?)==');

/// Unwrap paired emphasis markers but leave single underscores alone: `_` is
/// far more common inside identifiers (`snake_case`) than as emphasis in chat.
final _emphasis = <RegExp>[
  RegExp(r'\*\*(?=\S)([\s\S]*?\S)\*\*'),
  RegExp(r'(?<![\w*])\*(?=\S)([^*\n]*?\S)\*(?![\w*])'),
  RegExp(r'__(?=\S)([\s\S]*?\S)__'),
  RegExp(r'~~(?=\S)([\s\S]*?\S)~~'),
];

final _linePrefix = RegExp(
  r'^ {0,3}(?:#{1,6}\s+|>\s?|[-*+]\s+|\d+[.)]\s+)',
  multiLine: true,
);
final _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);
final _whitespace = RegExp(r'\s+');

/// One run of excerpt text: [marked] runs matched the query and are drawn
/// with the same ink the composer's `==highlight==` uses.
class MessageSearchExcerptRun {
  final String text;
  final bool marked;

  const MessageSearchExcerptRun(this.text, {this.marked = false});
}

/// The body of a result row: a window of the message around its first hit,
/// split into marked and unmarked runs, with `…` standing in for what the
/// window cut off.
class MessageSearchExcerpt {
  final List<MessageSearchExcerptRun> runs;

  const MessageSearchExcerpt(this.runs);

  /// The window with no marking, for tests and semantics labels.
  String get text => runs.map((run) => run.text).join();

  bool get isEmpty => text.isEmpty;
}

/// Builds the excerpt for [content], or returns null when the row should hand
/// the body to the rich message renderer instead (stickers, empty bodies).
///
/// [query] is the debounced text the user typed. The whole query is marked
/// where it appears; when it does not appear verbatim — the server's text
/// index also matches on terms — each term of two or more characters is
/// marked instead, so a row never shows a hit it cannot point at.
MessageSearchExcerpt? buildMessageSearchExcerpt({
  required String content,
  required String query,
  int maxLength = 150,
}) {
  final text = _plainBody(content);
  if (text == null) return null;

  return MessageSearchExcerpt(
    _windows(text, _needles(text, query), maxLength: maxLength),
  );
}

/// Reduces a message body to one line of prose, or null when the rich
/// renderer owns it.
String? _plainBody(String content) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) return null;
  if (_stickerOnly.hasMatch(trimmed)) return null;

  var text = trimmed.replaceAllMapped(_spoiler, (_) => '•••');
  text = text.replaceAllMapped(_fencedCode, (m) => _unfence(m.group(0)!));
  text = text.replaceAllMapped(_inlineCode, (m) => m.group(1)!);
  text = text.replaceAllMapped(_image, (m) => m.group(1)!);
  text = text.replaceAllMapped(_link, (m) => m.group(1)!);
  text = text.replaceAllMapped(_highlight, (m) => m.group(1)!);
  for (final marker in _emphasis) {
    text = text.replaceAllMapped(marker, (m) => m.group(1)!);
  }
  text = text
      .replaceAll(_linePrefix, '')
      .replaceAll(_lineBreak, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return text.isEmpty ? null : text;
}

String _unfence(String fence) {
  final inner = fence.substring(3, fence.length - 3);
  // Drop the opening info string (```dart) but keep the code itself.
  final newline = inner.indexOf('\n');
  return newline < 0 ? inner : inner.substring(newline + 1);
}

/// Substrings worth marking: the whole query, or — when it is absent — the
/// terms it is made of, longest first so overlapping terms resolve to the
/// widest mark.
List<String> _needles(String text, String query) {
  final lower = text.toLowerCase();
  final whole = query.trim();
  if (whole.isEmpty) return const [];
  if (lower.contains(whole.toLowerCase())) return [whole];

  final terms =
      whole
          .split(_whitespace)
          .where(
            (term) => term.length >= 2 && lower.contains(term.toLowerCase()),
          )
          .toList()
        ..sort((a, b) => b.length.compareTo(a.length));
  return terms;
}

/// Cuts [text] to a window around the first needle and marks every needle in
/// what is left. With no needles (the index matched on a term the body does
/// not spell out) the window is the head of the body, unmarked.
List<MessageSearchExcerptRun> _windows(
  String text,
  List<String> needles, {
  required int maxLength,
}) {
  final lower = text.toLowerCase();
  var first = -1;
  for (final needle in needles) {
    final index = lower.indexOf(needle.toLowerCase());
    if (index >= 0 && (first < 0 || index < first)) first = index;
  }

  var start = 0;
  var end = text.length;
  if (text.length > maxLength) {
    // Show a little of what precedes the hit: half a line is enough to
    // recognise the sentence, and the tail keeps the row to two lines.
    final lead = first < 0 ? 0 : (first - 40).clamp(0, text.length);
    start = _snapStart(text, lead, limit: first < 0 ? text.length : first);
    end = _snapEnd(
      text,
      (start + maxLength).clamp(start, text.length),
      floor: first < 0 ? start : first,
    );
  }

  final window = text.substring(start, end);
  return <MessageSearchExcerptRun>[
    if (start > 0) const MessageSearchExcerptRun('…'),
    ..._mark(window, needles),
    if (end < text.length) const MessageSearchExcerptRun('…'),
  ];
}

int _snapStart(String text, int index, {required int limit}) {
  if (index <= 0) return 0;
  final space = text.indexOf(' ', index);
  if (space < 0 || space >= limit) return index;
  return space + 1;
}

int _snapEnd(String text, int index, {required int floor}) {
  if (index >= text.length) return text.length;
  final space = text.lastIndexOf(' ', index);
  if (space <= floor) return index;
  return space;
}

List<MessageSearchExcerptRun> _mark(String window, List<String> needles) {
  if (needles.isEmpty) {
    return window.isEmpty ? const [] : [MessageSearchExcerptRun(window)];
  }

  final pattern = RegExp(
    needles.map(RegExp.escape).join('|'),
    caseSensitive: false,
  );
  final runs = <MessageSearchExcerptRun>[];
  var cursor = 0;
  for (final match in pattern.allMatches(window)) {
    if (match.start > cursor) {
      runs.add(MessageSearchExcerptRun(window.substring(cursor, match.start)));
    }
    runs.add(MessageSearchExcerptRun(match.group(0)!, marked: true));
    cursor = match.end;
  }
  if (cursor < window.length) {
    runs.add(MessageSearchExcerptRun(window.substring(cursor)));
  }
  return runs;
}

/// The dates a room's matches span, as one line of data: a single day reads
/// as that day, a range as its ends, and the year appears whenever it is not
/// the reader's current one or when the range crosses a year boundary.
String formatMatchDateSpan(DateTime newest, DateTime oldest) {
  final from = oldest.toLocal();
  final to = newest.toLocal();
  final now = DateTime.now();
  final sameDay =
      from.year == to.year && from.month == to.month && from.day == to.day;
  final withYear =
      from.year != to.year || from.year != now.year || to.year != now.year;

  if (sameDay) {
    return DateFormat(withYear ? 'MMM d, yyyy' : 'MMM d').format(to);
  }
  return '${DateFormat(withYear ? 'MMM d, yyyy' : 'MMM d').format(from)} – '
      '${DateFormat(withYear ? 'MMM d, yyyy' : 'MMM d').format(to)}';
}
