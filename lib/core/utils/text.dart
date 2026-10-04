import 'dart:ui';

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
}
