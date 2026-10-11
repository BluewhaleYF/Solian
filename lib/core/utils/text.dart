import 'dart:ui';

/// A fenced code block, including the info string on its opening fence.
final _fencedCode = RegExp(r'```[\s\S]*?```');

/// The code an inline span wraps.
final _inlineCode = RegExp(r'`([^`]*)`');

/// The alt text an image stands for.
final _image = RegExp(r'!\[([^\]]*)\]\([^)]*\)');

/// The label a link stands for — a URL shown as its own label survives.
final _link = RegExp(r'\[([^\]]*)\]\(\s*[^)]*\)');

/// The text a `==highlight==` wraps.
final _highlight = RegExp(r'==([\s\S]*?)==');

/// The text a `=!spoiler!=` conceals.
final _spoiler = RegExp(r'=!([\s\S]*?)!=');

/// Unwrap paired emphasis markers but leave single underscores alone: `_` is far
/// more common inside identifiers (`snake_case`) than as emphasis in prose.
final _emphasis = <RegExp>[
  RegExp(r'\*\*(?=\S)([\s\S]*?\S)\*\*'),
  RegExp(r'(?<![\w*])\*(?=\S)([^*\n]*?\S)\*(?![\w*])'),
  RegExp(r'__(?=\S)([\s\S]*?\S)__'),
  RegExp(r'~~(?=\S)([\s\S]*?\S)~~'),
];

/// Block markers a line can open with: headings, quotes and list bullets.
final _linePrefix = RegExp(
  r'^ {0,3}(?:#{1,6}\s+|>\s?|[-*+]\s+|\d+[.)]\s+)',
  multiLine: true,
);

final _lineBreak = RegExp(r'<br\s*/?>', caseSensitive: false);

extension StringExtension on String {
  String capitalizeEachWord() {
    if (isEmpty) return this;

    return split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  String toCamelCase() {
    if (isEmpty) return this;
    return split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join();
  }

  Color? parseHexColor() {
    if (isEmpty) return null;
    final normalized = replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final buffer = StringBuffer();
    if (normalized.length == 6) buffer.write('ff');
    buffer.write(normalized);
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0);
  }

  /// Fediverse summaries and actor metadata arrive as HTML; single-line rows
  /// need the markup and the entities out of the way.
  ///
  /// Block boundaries become spaces so adjacent paragraphs stay separated,
  /// inline tags collapse into the text they wrap, entity references are
  /// decoded and horizontal whitespace is collapsed. Line breaks already in the
  /// source text are kept.
  String htmlToPlainText() {
    if (!contains('<') && !contains('&')) return this;

    final decoded = replaceAll(
          RegExp(
            r'<br\s*/?>|</p>|</div>|</li>|</h[1-6]>',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAllMapped(RegExp(r'&#(x?)([0-9a-fA-F]+);'), (match) {
          final code = int.tryParse(
            match.group(2)!,
            radix: match.group(1)!.isEmpty ? 10 : 16,
          );
          return code == null ? match.group(0)! : String.fromCharCode(code);
        })
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ');

    return decoded.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  }

  /// Reduces markdown [content] to a single line of prose: block markers,
  /// emphasis, links and code fences give way to the text they wrap, and every
  /// run of whitespace collapses to one space. Spoilers become [spoilerMask]
  /// because a one-line row must not print what the author concealed.
  ///
  /// Sticker tokens are left untouched: callers that care about them decide for
  /// themselves what a body made of nothing but stickers means.
  String markdownToPlainLine({String spoilerMask = '•••'}) {
    var text = replaceAllMapped(_spoiler, (_) => spoilerMask);
    text = text.replaceAllMapped(_fencedCode, (m) => _unfence(m.group(0)!));
    text = text.replaceAllMapped(_inlineCode, (m) => m.group(1)!);
    text = text.replaceAllMapped(_image, (m) => m.group(1)!);
    text = text.replaceAllMapped(_link, (m) => m.group(1)!);
    text = text.replaceAllMapped(_highlight, (m) => m.group(1)!);
    for (final marker in _emphasis) {
      text = text.replaceAllMapped(marker, (m) => m.group(1)!);
    }
    return text
        .replaceAll(_linePrefix, '')
        .replaceAll(_lineBreak, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

/// The code inside a fenced block, minus the info string on the opening fence.
String _unfence(String fence) {
  final inner = fence.substring(3, fence.length - 3);
  final newline = inner.indexOf('\n');
  return newline < 0 ? inner : inner.substring(newline + 1);
}
