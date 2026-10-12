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
}
