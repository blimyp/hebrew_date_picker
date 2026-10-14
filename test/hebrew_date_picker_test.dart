import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_date_picker/hebrew_date_picker.dart';

void main() {
  group('HebrewDateExtension', () {
    // 12 Sep 2026 is Rosh Hashana 5787 (1 Tishrei).
    final roshHashana = DateTime(2026, 9, 12);

    test('formats the full Hebrew date', () {
      expect(roshHashana.getHebrewDateFormatted(), contains('תשרי'));
    });

    test('formats the Hebrew day of month in letters', () {
      expect(roshHashana.getHebrewDayOfMonth(), contains('א'));
    });

    test('lists the Hebrew months covered by a Gregorian month', () {
      final months = DateTime(2026, 9, 1).getHebrewMonthsOfMonth();
      expect(months, contains('אלול'));
      expect(months, contains('תשרי'));
    });

    test('lists the Hebrew years covered by a Gregorian year', () {
      expect(DateTime(1990).getHebrewYearsOfYear(), 'תש״נ–תשנ״א');
    });
  });

  group('Year picker', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      DatePickerMode initialDatePickerMode = DatePickerMode.day,
      ValueChanged<DateTime>? onConfirm,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HebrewDatePicker(
                initialDate: DateTime(2026, 9, 12),
                firstDate: DateTime(1980, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                initialDatePickerMode: initialDatePickerMode,
                onConfirm: onConfirm ?? (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('tapping the month title opens the year grid', (tester) async {
      await pumpPicker(tester);
      expect(find.text('2026'), findsNothing);

      await tester.tap(find.text('September 2026'));
      await tester.pump();

      expect(find.text('2026'), findsOneWidget);
      expect(find.text(DateTime(2026).getHebrewYearsOfYear()), findsOneWidget);
    });

    testWidgets('selecting a year keeps the day and month', (tester) async {
      DateTime? confirmed;
      await pumpPicker(
        tester,
        initialDatePickerMode: DatePickerMode.year,
        onConfirm: (date) => confirmed = date,
      );

      await tester.scrollUntilVisible(
        find.text('1990'),
        -100,
        scrollable: find.descendant(of: find.byType(GridView), matching: find.byType(Scrollable)),
      );
      // scrollUntilVisible stops as soon as 1990 is built, which can be under the grid's edge.
      await tester.drag(find.byType(GridView), const Offset(0, 100));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1990'));
      await tester.pump();

      expect(find.text('September 1990'), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(confirmed, DateTime(1990, 9, 12));
    });
  });

  group('DayMode', () {
    Future<void> pumpPicker(WidgetTester tester, DayMode dayMode) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HebrewDatePicker(
                initialDate: DateTime(2026, 9, 1),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                dayMode: dayMode,
                onConfirm: (_) {},
              ),
            ),
          ),
        ),
      );
    }

    // 4 Sep 2026 is 22 Elul, a Hebrew day that appears only once in September 2026.
    final hebrewDay = DateTime(2026, 9, 4).getHebrewDayOfMonth();

    testWidgets('both shows the Gregorian and the Hebrew day', (tester) async {
      await pumpPicker(tester, DayMode.both);
      expect(find.text('4'), findsOneWidget);
      expect(find.text(hebrewDay), findsOneWidget);
    });

    testWidgets('hebrew shows only the Hebrew day', (tester) async {
      await pumpPicker(tester, DayMode.hebrew);
      expect(find.text('4'), findsNothing);
      expect(find.text(hebrewDay), findsOneWidget);
    });

    testWidgets('gregorian shows only the Gregorian day', (tester) async {
      await pumpPicker(tester, DayMode.gregorian);
      expect(find.text('4'), findsOneWidget);
      expect(find.text(hebrewDay), findsNothing);
    });
  });

  group('HebrewDatePicker', () {
    testWidgets('confirms the tapped day', (tester) async {
      DateTime? confirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HebrewDatePicker(
                initialDate: DateTime(2026, 9, 1),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                onCancel: () {},
                onConfirm: (date) => confirmed = date,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTime(2026, 9, 12));
    });

    testWidgets('showHebrewDatePicker returns null on cancel', (tester) async {
      // The default 800x600 test surface is shorter than the dialog.
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<DateTime?>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => result = showHebrewDatePicker(
                context: context,
                initialDate: DateTime(2026, 9, 1),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await result, isNull);
    });

    testWidgets('showHebrewDatePicker returns the selected date', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<DateTime?>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => result = showHebrewDatePicker(
                context: context,
                initialDate: DateTime(2026, 9, 1),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(await result, DateTime(2026, 9, 12));
    });
  });

  group('selectableDayPredicate', () {
    // Saturdays in September 2026: 5, 12, 19 and 26.
    bool notSaturday(DateTime day) => day.weekday != DateTime.saturday;

    Widget wrap(Widget picker) => MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: picker)),
        );

    testWidgets('a disabled day cannot be selected', (tester) async {
      DateTime? confirmed;
      final calledWith = <DateTime>[];
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: DateTime(2026, 9, 1),
        firstDate: DateTime(2026, 1, 1),
        lastDate: DateTime(2026, 12, 31),
        dayMode: DayMode.gregorian,
        selectableDayPredicate: (day) {
          calledWith.add(day);
          return notSaturday(day);
        },
        onConfirm: (date) => confirmed = date,
      )));

      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTime(2026, 9, 1));
      expect(calledWith, isNotEmpty);
      expect(calledWith.every((day) => !day.isUtc && day == DateUtils.dateOnly(day)), isTrue);
    });

    testWidgets('a range may span disabled days but not end on one', (tester) async {
      DateTimeRange? confirmed;
      await tester.pumpWidget(wrap(HebrewDateRangePicker(
        firstDate: DateTime(2026, 9, 1),
        lastDate: DateTime(2026, 9, 30),
        dayMode: DayMode.gregorian,
        selectableDayPredicate: notSaturday,
        onConfirm: (range) => confirmed = range,
      )));

      await tester.tap(find.text('10'));
      await tester.pump();
      await tester.tap(find.text('19'));
      await tester.pump();
      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTimeRange(start: DateTime(2026, 9, 10), end: DateTime(2026, 9, 20)));
    });

    testWidgets('selecting a year whose day is disabled keeps the selection', (tester) async {
      DateTime? confirmed;
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: DateTime(2026, 9, 12),
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime(2030, 12, 31),
        initialDatePickerMode: DatePickerMode.year,
        selectableDayPredicate: (day) => day.year != 2027,
        onConfirm: (date) => confirmed = date,
      )));

      await tester.tap(find.text('2027'));
      await tester.pump();

      expect(find.text('September 2027'), findsOneWidget);
      await tester.tap(find.text('OK'));
      expect(confirmed, DateTime(2026, 9, 12));
    });

    testWidgets('asserts that the initial date is selectable', (tester) async {
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: DateTime(2026, 9, 12),
        firstDate: DateTime(2026, 1, 1),
        lastDate: DateTime(2026, 12, 31),
        selectableDayPredicate: notSaturday,
        onConfirm: (_) {},
      )));

      expect(tester.takeException(), isAssertionError);
    });
  });

  group('HebrewDateRangePicker', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      ValueChanged<DateTimeRange>? onConfirm,
      ValueChanged<DateTimeRange>? onDateRangeChanged,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HebrewDateRangePicker(
                initialDateRange:
                    DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 3)),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                dayMode: DayMode.gregorian,
                onConfirm: onConfirm ?? (_) {},
                onDateRangeChanged: onDateRangeChanged,
              ),
            ),
          ),
        ),
      );
    }

    bool okEnabled(WidgetTester tester) =>
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'OK')).onPressed != null;

    testWidgets('confirms the initial range', (tester) async {
      DateTimeRange? confirmed;
      await pumpPicker(tester, onConfirm: (range) => confirmed = range);

      await tester.tap(find.text('OK'));

      expect(confirmed, DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 3)));
    });

    testWidgets('two taps select a range and enable confirm', (tester) async {
      DateTimeRange? confirmed;
      DateTimeRange? changed;
      await pumpPicker(
        tester,
        onConfirm: (range) => confirmed = range,
        onDateRangeChanged: (range) => changed = range,
      );

      await tester.tap(find.text('10'));
      await tester.pump();
      expect(okEnabled(tester), isFalse);
      expect(changed, isNull);

      await tester.tap(find.text('20'));
      await tester.pump();
      expect(okEnabled(tester), isTrue);
      final expected = DateTimeRange(start: DateTime(2026, 9, 10), end: DateTime(2026, 9, 20));
      expect(changed, expected);

      await tester.tap(find.text('OK'));
      expect(confirmed, expected);
    });

    testWidgets('a tap before the start moves the start', (tester) async {
      DateTimeRange? confirmed;
      await pumpPicker(tester, onConfirm: (range) => confirmed = range);

      await tester.tap(find.text('20'));
      await tester.pump();
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(okEnabled(tester), isFalse);
      await tester.tap(find.text('15'));
      await tester.pump();
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTimeRange(start: DateTime(2026, 9, 10), end: DateTime(2026, 9, 15)));
    });

    testWidgets('a range can start and end on the same day', (tester) async {
      DateTimeRange? confirmed;
      await pumpPicker(tester, onConfirm: (range) => confirmed = range);

      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 12)));
    });

    testWidgets('the header shows the Hebrew dates of the range', (tester) async {
      await pumpPicker(tester);
      expect(
        find.text('${DateTime(2026, 9, 1).getHebrewDateFormatted()} – '
            '${DateTime(2026, 9, 3).getHebrewDateFormatted()}'),
        findsOneWidget,
      );
    });

    testWidgets('showHebrewDateRangePicker returns the selected range', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<DateTimeRange?>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => result = showHebrewDateRangePicker(
                context: context,
                firstDate: DateTime(2026, 9, 1),
                lastDate: DateTime(2026, 9, 30),
                dayMode: DayMode.gregorian,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Start Date – End Date'), findsOneWidget);
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('14'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        await result,
        DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 14)),
      );
    });
  });
}
