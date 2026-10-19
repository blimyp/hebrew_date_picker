import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hebrew_date_picker/hebrew_date_picker.dart';
import 'package:hebrew_date_picker/src/hebrew_month.dart';
import 'package:intl/intl.dart';
import 'package:kosher_dart/kosher_dart.dart';

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
    Future<void> pumpPicker(
      WidgetTester tester,
      DayMode dayMode, {
      DatePickerMode initialDatePickerMode = DatePickerMode.day,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HebrewDatePicker(
                initialDate: DateTime(2026, 9, 1),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                dayMode: dayMode,
                initialDatePickerMode: initialDatePickerMode,
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

    final anyHebrew = find.textContaining(RegExp('[א-ת]'));

    testWidgets('both shows the Hebrew dates in the header and the month title',
        (tester) async {
      await pumpPicker(tester, DayMode.both);
      expect(find.text(DateTime(2026, 9, 1).getHebrewDateFormatted()), findsOneWidget);
      expect(find.text(DateTime(2026, 9, 1).getHebrewMonthsOfMonth()), findsOneWidget);
    });

    testWidgets('gregorian shows no Hebrew dates', (tester) async {
      await pumpPicker(tester, DayMode.gregorian);
      expect(find.text('September 2026'), findsOneWidget);
      expect(anyHebrew, findsNothing);
    });

    testWidgets('gregorian shows no Hebrew years in the year grid', (tester) async {
      await pumpPicker(tester, DayMode.gregorian, initialDatePickerMode: DatePickerMode.year);
      expect(find.text('2026'), findsOneWidget);
      expect(anyHebrew, findsNothing);
    });
  });

  group('HebrewMonth', () {
    test('numbers consecutive months without gaps, across leap years', () {
      var month = HebrewMonth.of(DateTime(2020, 1, 1));
      for (int i = 0; i < 150; i++) {
        final next = HebrewMonth.fromIndex(month.index + 1);
        final first = JewishDate.fromDateTime(month.firstDay);
        expect(first.getJewishYear(), month.year);
        expect(first.getJewishMonth(), month.month);
        expect(first.getJewishDayOfMonth(), 1);
        expect(month.lastDay.difference(month.firstDay).inDays + 1, month.length);
        expect(next.firstDay, month.lastDay.add(const Duration(days: 1)));
        expect(HebrewMonth.of(month.lastDay).index, month.index);
        month = next;
      }
    });

    test('maps Adar II to Adar in a year without one', () {
      expect(HebrewMonth.inYear(5784, 13).month, 13);
      expect(HebrewMonth.inYear(5785, 13).month, 12);
    });
  });

  group('Hebrew months', () {
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
                // 1 Tishrei 5787.
                initialDate: DateTime(2026, 9, 12),
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                dayMode: DayMode.hebrew,
                initialDatePickerMode: initialDatePickerMode,
                onConfirm: onConfirm ?? (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows only Hebrew dates', (tester) async {
      await pumpPicker(tester);
      // The header and the month title.
      expect(find.text('א׳ תשרי תשפ״ז'), findsOneWidget);
      expect(find.text('תשרי תשפ״ז'), findsOneWidget);
      expect(find.textContaining('2026'), findsNothing);
      expect(find.textContaining('Sep'), findsNothing);
      // The page holds only Tishrei, so its first day appears once.
      expect(find.text('א׳'), findsOneWidget);
    });

    testWidgets('shows Hebrew weekday letters', (tester) async {
      await pumpPicker(tester);
      for (final weekday in ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש']) {
        expect(find.text(weekday), findsOneWidget);
      }
      expect(find.text('S'), findsNothing);
    });

    testWidgets('the arrows page by Hebrew months', (tester) async {
      await pumpPicker(tester);

      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('חשוון תשפ״ז'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('אלול תשפ״ו'), findsOneWidget);
    });

    testWidgets('confirms a tapped day of the Hebrew month', (tester) async {
      DateTime? confirmed;
      await pumpPicker(tester, onConfirm: (date) => confirmed = date);

      // 30 Tishrei 5787.
      await tester.tap(find.text('ל׳'));
      await tester.pump();
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTime(2026, 10, 11));
    });

    testWidgets('the year grid lists Hebrew years and keeps the Hebrew day and month',
        (tester) async {
      DateTime? confirmed;
      await pumpPicker(
        tester,
        initialDatePickerMode: DatePickerMode.year,
        onConfirm: (date) => confirmed = date,
      );
      expect(find.text('תשפ״ז'), findsOneWidget);
      expect(find.text('2026'), findsNothing);

      await tester.tap(find.text('תשפ״ח'));
      await tester.pump();
      expect(find.text('תשרי תשפ״ח'), findsOneWidget);
      await tester.tap(find.text('OK'));

      final roshHashana =
          JewishDate.initDate(jewishYear: 5788, jewishMonth: 7, jewishDayOfMonth: 1);
      expect(
        confirmed,
        DateTime(roshHashana.getGregorianYear(), roshHashana.getGregorianMonth(),
            roshHashana.getGregorianDayOfMonth()),
      );
    });

    testWidgets('selects a range within the Hebrew month', (tester) async {
      DateTimeRange? confirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HebrewDateRangePicker(
                initialDateRange:
                    DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 12)),
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                dayMode: DayMode.hebrew,
                onConfirm: (range) => confirmed = range,
              ),
            ),
          ),
        ),
      );

      // 1 and 10 Tishrei 5787.
      await tester.tap(find.text('א׳'));
      await tester.pump();
      await tester.tap(find.text('י׳'));
      await tester.pump();
      // The year is written only outside the current Hebrew year.
      expect(find.textContaining(RegExp('^א׳ תשרי.* – י׳ תשרי')), findsOneWidget);
      await tester.tap(find.text('OK'));

      expect(confirmed, DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 21)));
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

  group('Today button', () {
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDate = DateTime(today.year - 2);
    final lastDate = DateTime(today.year + 2, 12, 31);
    // Far enough from today to be on another month.
    final otherDay = DateTime(today.year - 1, 1, 1);

    Widget wrap(Widget picker) => MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: picker)),
        );

    bool todayEnabled(WidgetTester tester) =>
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Today')).onPressed != null;

    testWidgets('is hidden by default', (tester) async {
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: otherDay,
        firstDate: firstDate,
        lastDate: lastDate,
        onConfirm: (_) {},
      )));
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('shows and selects today', (tester) async {
      DateTime? confirmed;
      DateTime? changed;
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: otherDay,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDatePickerMode: DatePickerMode.year,
        showTodayButton: true,
        onDateChanged: (date) => changed = date,
        onConfirm: (date) => confirmed = date,
      )));

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text(DateFormat.yMMMM().format(today)), findsOneWidget);
      expect(changed, today);
      await tester.tap(find.text('OK'));
      expect(confirmed, today);
    });

    testWidgets('starts a new range from today', (tester) async {
      await tester.pumpWidget(wrap(HebrewDateRangePicker(
        initialDateRange: DateTimeRange(start: otherDay, end: otherDay.add(const Duration(days: 2))),
        firstDate: firstDate,
        lastDate: lastDate,
        showTodayButton: true,
        onConfirm: (_) {},
      )));

      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text(today.getHebrewDateFormatted()), findsOneWidget);
      expect(
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'OK')).onPressed,
        isNull,
      );
    });

    testWidgets('is disabled when today is not selectable', (tester) async {
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: otherDay,
        firstDate: firstDate,
        lastDate: lastDate,
        showTodayButton: true,
        selectableDayPredicate: (day) => day != today,
        onConfirm: (_) {},
      )));
      expect(todayEnabled(tester), isFalse);
    });

    testWidgets('is disabled when today is out of range', (tester) async {
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: DateTime(2000, 1, 1),
        firstDate: DateTime(2000, 1, 1),
        lastDate: DateTime(2000, 12, 31),
        showTodayButton: true,
        onConfirm: (_) {},
      )));
      expect(todayEnabled(tester), isFalse);
    });

    testWidgets('uses todayText', (tester) async {
      await tester.pumpWidget(wrap(HebrewDatePicker(
        initialDate: otherDay,
        firstDate: firstDate,
        lastDate: lastDate,
        showTodayButton: true,
        todayText: 'היום',
        onConfirm: (_) {},
      )));
      expect(find.text('היום'), findsOneWidget);
    });
  });

  group('HebrewDateRangePicker', () {
    Future<void> pumpPicker(
      WidgetTester tester, {
      ValueChanged<DateTimeRange>? onConfirm,
      ValueChanged<DateTimeRange>? onDateRangeChanged,
      DayMode dayMode = DayMode.gregorian,
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
                dayMode: dayMode,
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
      await pumpPicker(tester, dayMode: DayMode.both);
      expect(
        find.text('${DateTime(2026, 9, 1).getHebrewDateFormatted()} – '
            '${DateTime(2026, 9, 3).getHebrewDateFormatted()}'),
        findsOneWidget,
      );
    });

    testWidgets('the header shows no Hebrew dates with DayMode.gregorian', (tester) async {
      await pumpPicker(tester);
      expect(find.textContaining(RegExp('[א-ת]')), findsNothing);
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

  group('Form fields', () {
    // The default 800x600 test surface is shorter than the dialog.
    void useTallView(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    Future<void> pumpField(WidgetTester tester, Widget field) {
      useTallView(tester);
      return tester.pumpWidget(MaterialApp(home: Scaffold(body: Form(child: field))));
    }

    testWidgets('tapping the date field opens the picker and shows the picked date',
        (tester) async {
      DateTime? changed;
      await pumpField(
        tester,
        HebrewDateFormField(
          initialValue: DateTime(2026, 9, 1),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          dayMode: DayMode.gregorian,
          onChanged: (date) => changed = date,
        ),
      );
      expect(find.text('Sep 1, 2026'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(changed, DateTime(2026, 9, 12));
      expect(find.text('Sep 12, 2026'), findsOneWidget);
    });

    testWidgets('the date field shows the Hebrew date by default', (tester) async {
      await pumpField(
        tester,
        HebrewDateFormField(
          initialValue: DateTime(2026, 9, 12, 15, 30),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        ),
      );

      final text = tester.widget<TextField>(find.byType(TextField)).controller!.text;
      expect(text, 'Sep 12, 2026 · ${DateTime(2026, 9, 12).getHebrewDateFormatted()}');
    });

    testWidgets('canceling the picker keeps the date field value', (tester) async {
      await pumpField(
        tester,
        HebrewDateFormField(
          initialValue: DateTime(2026, 9, 1),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          dateFormatter: (context, date) => 'day ${date.day}',
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('day 1'), findsOneWidget);
    });

    testWidgets('the date field validates and saves through its Form', (tester) async {
      useTallView(tester);
      final formKey = GlobalKey<FormState>();
      DateTime? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: HebrewDateFormField(
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                validator: (date) => date == null ? 'Pick a date' : null,
                onSaved: (date) => saved = date,
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick a date'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      final now = DateTime.now();
      expect(saved, DateTime(now.year, now.month, now.day));
    });

    testWidgets('an empty date field opens the picker on a selectable day', (tester) async {
      bool isSelectable(DateTime day) => day.day.isEven;
      DateTime? changed;
      await pumpField(
        tester,
        HebrewDateFormField(
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          selectableDayPredicate: isSelectable,
          onChanged: (date) => changed = date,
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(changed, isNotNull);
      expect(isSelectable(changed!), isTrue);
    });

    testWidgets('a disabled date field does not open the picker', (tester) async {
      await pumpField(
        tester,
        HebrewDateFormField(
          enabled: false,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        ),
      );

      await tester.tap(find.byType(TextField), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(HebrewDatePicker), findsNothing);
    });

    testWidgets('tapping the range field opens the range picker and shows the range',
        (tester) async {
      DateTimeRange? changed;
      await pumpField(
        tester,
        HebrewDateRangeFormField(
          initialValue: DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 3)),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          dayMode: DayMode.gregorian,
          onChanged: (range) => changed = range,
        ),
      );
      expect(find.text('Sep 1 – Sep 3, 2026'), findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('14'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(changed, DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 14)));
      expect(find.text('Sep 12 – Sep 14, 2026'), findsOneWidget);
    });

    testWidgets('the date field follows a new initialValue from its parent', (tester) async {
      var date = DateTime(2026, 9, 1);
      late StateSetter setParentState;
      var changes = 0;
      await pumpField(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setParentState = setState;
            return HebrewDateFormField(
              initialValue: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              dayMode: DayMode.gregorian,
              onChanged: (_) => changes++,
            );
          },
        ),
      );
      expect(find.text('Sep 1, 2026'), findsOneWidget);

      setParentState(() => date = DateTime(2026, 9, 20));
      await tester.pump();

      expect(find.text('Sep 20, 2026'), findsOneWidget);
      expect(changes, 0);
    });

    testWidgets('rebuilding with the same initialValue keeps the picked date', (tester) async {
      late StateSetter setParentState;
      await pumpField(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setParentState = setState;
            return HebrewDateFormField(
              initialValue: DateTime(2026, 9, 1),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              dayMode: DayMode.gregorian,
            );
          },
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      setParentState(() {});
      await tester.pump();

      expect(find.text('Sep 12, 2026'), findsOneWidget);
    });

    testWidgets('the range field follows a new initialValue from its parent', (tester) async {
      var range = DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 3));
      late StateSetter setParentState;
      await pumpField(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setParentState = setState;
            return HebrewDateRangeFormField(
              initialValue: range,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              dayMode: DayMode.gregorian,
            );
          },
        ),
      );

      setParentState(
        () => range = DateTimeRange(start: DateTime(2026, 9, 5), end: DateTime(2026, 9, 8)),
      );
      await tester.pump();

      expect(find.text('Sep 5 – Sep 8, 2026'), findsOneWidget);
    });

    testWidgets('Enter and Space open the picker from a focused field', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpField(
        tester,
        HebrewDateFormField(
          initialValue: DateTime(2026, 9, 1),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          focusNode: focusNode,
        ),
      );

      for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
        focusNode.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(find.byType(HebrewDatePicker), findsOneWidget, reason: '$key');

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.byType(HebrewDatePicker), findsNothing);
      }
    });

    group('default range text', () {
      Future<String> rangeText(WidgetTester tester, DateTimeRange range, DayMode dayMode) async {
        await pumpField(
          tester,
          HebrewDateRangeFormField(
            initialValue: range,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            dayMode: dayMode,
          ),
        );
        return tester.widget<TextField>(find.byType(TextField)).controller!.text;
      }

      testWidgets('writes a shared Hebrew month and year once', (tester) async {
        // 1-9 Tishrei 5787.
        final range = DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 20));
        expect(
          await rangeText(tester, range, DayMode.both),
          'Sep 12 – Sep 20, 2026 · א׳–ט׳ תשרי תשפ״ז',
        );
      });

      testWidgets('writes a shared Hebrew year once', (tester) async {
        // 1 Tishrei - 1 Cheshvan 5787.
        final range = DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 10, 12));
        final text = await rangeText(tester, range, DayMode.hebrew);
        expect(text, startsWith('א׳ תשרי – '));
        expect(text, endsWith('תשפ״ז'));
        expect('תשפ״ז'.allMatches(text), hasLength(1));
      });

      testWidgets('writes both years when the range crosses a year', (tester) async {
        // Elul 5786 - Tishrei 5787, and Dec 2026 - Jan 2027.
        expect(
          await rangeText(
            tester,
            DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 20)),
            DayMode.hebrew,
          ),
          '${DateTime(2026, 9, 1).getHebrewDateFormatted()} – '
          '${DateTime(2026, 9, 20).getHebrewDateFormatted()}',
        );
        expect(
          await rangeText(
            tester,
            DateTimeRange(start: DateTime(2026, 12, 30), end: DateTime(2027, 1, 2)),
            DayMode.gregorian,
          ),
          'Dec 30, 2026 – Jan 2, 2027',
        );
      });

      testWidgets('writes a one-day range as a single date', (tester) async {
        final day = DateTime(2026, 9, 12);
        expect(
          await rangeText(tester, DateTimeRange(start: day, end: day), DayMode.both),
          'Sep 12, 2026 · ${day.getHebrewDateFormatted()}',
        );
      });
    });
  });
}
