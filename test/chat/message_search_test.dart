import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/utils/message_search.dart';

/// Text of every marked run, in order.
List<String> markedRuns(MessageSearchExcerpt excerpt) => [
  for (final run in excerpt.runs)
    if (run.marked) run.text,
];

void main() {
  group('buildMessageSearchExcerpt', () {
    test('unwraps the inline markup a chat body carries', () {
      final excerpt = buildMessageSearchExcerpt(
        content:
            '**bold** and *italic* and `code` and [a link](https://x.test)',
        query: 'italic',
      );

      expect(excerpt!.text, 'bold and italic and code and a link');
      expect(markedRuns(excerpt), ['italic']);
    });

    test('reduces an image to its alt text and a spoiler to a mark', () {
      final excerpt = buildMessageSearchExcerpt(
        content:
            'look ![a photo](https://x.test/a.png) and =!the secret!= here',
        query: 'here',
      );

      expect(excerpt!.text, 'look a photo and ••• here');
      expect(excerpt.text, isNot(contains('secret')));
    });

    test('keeps underscores inside a word', () {
      final excerpt = buildMessageSearchExcerpt(
        content: 'set search_messages_across_rooms and __stop__',
        query: 'search_messages_across_rooms',
      );

      expect(excerpt!.text, 'set search_messages_across_rooms and stop');
    });

    test('joins block lines into one line of prose', () {
      final excerpt = buildMessageSearchExcerpt(
        content: '# heading\n\n- first item\n> quoted<br>line',
        query: 'quoted',
      );

      expect(excerpt!.text, 'heading first item quoted line');
    });

    test('unwraps a fence and drops its info string', () {
      final excerpt = buildMessageSearchExcerpt(
        content: 'try\n```dart\nfinal x = 1;\n```\nplease',
        query: 'please',
      );

      expect(excerpt!.text, 'try final x = 1; please');
    });

    test('hands stickers and empty bodies to the rich renderer', () {
      expect(
        buildMessageSearchExcerpt(content: ':pack+wave:', query: 'wave'),
        isNull,
      );
      expect(buildMessageSearchExcerpt(content: '   ', query: 'x'), isNull);
    });

    test('marks every hit inside the window', () {
      final excerpt = buildMessageSearchExcerpt(
        content: 'ping ping ping',
        query: 'ping',
      );

      expect(markedRuns(excerpt!), ['ping', 'ping', 'ping']);
      expect(excerpt.text, 'ping ping ping');
    });

    test('falls back to marking the terms the index matched', () {
      final excerpt = buildMessageSearchExcerpt(
        content: 'the plan is to leave early',
        query: 'plan early',
      );

      expect(markedRuns(excerpt!), ['plan', 'early']);
    });

    test('centres a long body on the hit and marks what it cut', () {
      final body = '${'filler ' * 20}the needle sits here${' tail' * 20}';
      final excerpt = buildMessageSearchExcerpt(content: body, query: 'needle');

      expect(excerpt!.text, startsWith('…'));
      expect(excerpt.text, endsWith('…'));
      expect(excerpt.text, contains('the needle sits here'));
      expect(markedRuns(excerpt), ['needle']);
      // The window stays short enough for a two-line row, and the hit is
      // still near its start.
      expect(excerpt.text.length, lessThan(170));
      expect(excerpt.text.indexOf('needle'), lessThan(46));
    });

    test('shows the body head unmarked when the term is not spelled out', () {
      final excerpt = buildMessageSearchExcerpt(
        content: 'hello there',
        query: 'greetings',
      );

      expect(excerpt!.text, 'hello there');
      expect(markedRuns(excerpt), isEmpty);
    });

    test('marks a hit in long text without cutting the match off', () {
      final body = '${'a' * 200} needle ${'b' * 200}';
      final excerpt = buildMessageSearchExcerpt(content: body, query: 'needle');

      expect(markedRuns(excerpt!), ['needle']);
      expect(excerpt.text.length, lessThan(170));
    });
  });

  group('formatMatchDateSpan', () {
    test('a single day reads as that day', () {
      final day = DateTime.now().subtract(const Duration(days: 3));
      expect(
        formatMatchDateSpan(day, DateTime(day.year, day.month, day.day, 8)),
        _monthDay(day),
      );
    });

    test('a range reads as its two ends', () {
      final newest = DateTime.now().subtract(const Duration(days: 2));
      final oldest = DateTime(
        newest.year,
        newest.month,
        newest.day,
      ).subtract(const Duration(days: 20));
      expect(
        formatMatchDateSpan(newest, oldest),
        '${_monthDay(oldest)} – ${_monthDay(newest)}',
      );
    });

    test('a range in another year carries the year', () {
      final newest = DateTime(2019, 3, 4);
      final oldest = DateTime(2018, 12, 30);
      expect(formatMatchDateSpan(newest, oldest), 'Dec 30, 2018 – Mar 4, 2019');
      expect(
        formatMatchDateSpan(DateTime(2019, 3, 4), DateTime(2019, 3, 1)),
        'Mar 1, 2019 – Mar 4, 2019',
      );
    });
  });
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _monthDay(DateTime date) => '${_months[date.month - 1]} ${date.day}';
