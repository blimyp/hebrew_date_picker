# hebrew_date_picker

A Material-style Flutter date picker that shows the **Hebrew (Jewish) date** alongside the
Gregorian one:

* every day cell shows the Gregorian day and the Hebrew day in letters (e.g. `12` / `א׳`),
* the month title shows the Gregorian month and the Hebrew months it covers
  (e.g. `September 2026` / `אלול–תשרי תשפ״ז`),
* the header shows the full Hebrew date of the selected day (e.g. `א׳ תשרי תשפ״ז`),
* tapping the month title opens a year grid with the Gregorian and the Hebrew years
  (e.g. `1990` / `תש״נ–תשנ״א`), so far-away dates are a couple of taps away,
* a range picker selects a start and an end date, with the Hebrew dates of both in the header.

<img src="https://raw.githubusercontent.com/blimyp/hebrew_date_picker/main/screenshots/hebrew_date_picker.png" alt="Hebrew date picker" width="360">

Hebrew dates are calculated with [kosher_dart](https://pub.dev/packages/kosher_dart) and the
calendar grid is built on [table_calendar](https://pub.dev/packages/table_calendar).

## Installation

```yaml
dependencies:
  hebrew_date_picker: ^0.1.1
```

## Usage

### As a dialog

```dart
import 'package:hebrew_date_picker/hebrew_date_picker.dart';

final DateTime? date = await showHebrewDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
);
```

The future completes with the selected date (time stripped), or `null` if the picker was
canceled or dismissed.

### As an embedded widget

```dart
HebrewDatePicker(
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onConfirm: (date) => print(date),
  onCancel: () => print('canceled'),
  onDateChanged: (date) => print('tapped $date'),
)
```

### Date range

```dart
final DateTimeRange? range = await showHebrewDateRangePicker(
  context: context,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  initialDateRange: DateTimeRange(start: DateTime(2026, 9, 12), end: DateTime(2026, 9, 20)),
);
```

The first tap picks the start of the range and the second tap picks its end; a tap before the
start moves the start instead. A range may start and end on the same day. `initialDateRange` is
optional, and the confirm button stays disabled until both ends are selected. The future
completes with the selected range (times stripped), or `null` if the picker was canceled or
dismissed.

`HebrewDateRangePicker` is the embeddable widget, with `onConfirm`, `onCancel` and
`onDateRangeChanged` (called whenever a complete range is tapped). It takes the same
customization parameters as `HebrewDatePicker`; `helpText` defaults to
`MaterialLocalizations.dateRangePickerHelpText`.

### Customization

| Parameter | Default |
|---|---|
| `dayMode` | `DayMode.both` |
| `selectableDayPredicate` | every day is selectable |
| `showTodayButton` | `false` |
| `initialDatePickerMode` | `DatePickerMode.day` |
| `primaryColor` | `ColorScheme.primary` |
| `secondaryTextColor` | `ColorScheme.onSurfaceVariant` |
| `helpText` | `MaterialLocalizations.datePickerHelpText` |
| `cancelText` | `MaterialLocalizations.cancelButtonLabel` |
| `confirmText` | `MaterialLocalizations.okButtonLabel` |
| `todayText` | `MaterialLocalizations.currentDateLabel` |
| `locale` | the `intl` default locale |

`dayMode` controls what each day cell shows:

| `DayMode` | Day cell |
|---|---|
| `both` | the Gregorian day with the Hebrew day below it (`12` / `א׳`) |
| `hebrew` | only the Hebrew day (`א׳`) |
| `gregorian` | only the Gregorian day (`12`) |

```dart
showHebrewDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  dayMode: DayMode.hebrew,
);
```

`initialDatePickerMode: DatePickerMode.year` opens the picker on the year grid, which suits
dates far from today such as a birth date:

```dart
showHebrewDatePicker(
  context: context,
  initialDate: DateTime(1990, 1, 1),
  firstDate: DateTime(1900),
  lastDate: DateTime.now(),
  initialDatePickerMode: DatePickerMode.year,
);
```

`selectableDayPredicate` decides which days can be picked. Days for which it returns `false`
are shown disabled and can't be tapped. The initial date (or both ends of the initial range)
must satisfy it. In the range picker it applies to the ends of the range, which may span
disabled days. For example, to disable Saturdays:

```dart
showHebrewDatePicker(
  context: context,
  initialDate: DateTime(2026, 9, 1),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  selectableDayPredicate: (day) => day.weekday != DateTime.saturday,
);
```

`showTodayButton: true` adds a button next to the cancel and confirm buttons that jumps to
today's month and selects today (in the range picker, as the start of a new range). It is
disabled when today is outside `firstDate`–`lastDate` or isn't selectable.

`locale` controls the Gregorian month title and the weekday names. For a locale other than
`en_US`, initialize the date formatting data first, e.g. by adding `flutter_localizations` to
your app or calling `initializeDateFormatting()` from `package:intl/date_symbol_data_local.dart`.

### Hebrew date helpers

The `DateTime` extension used by the picker is exported as well:

```dart
DateTime(2026, 9, 12).getHebrewDateFormatted(); // א׳ תשרי תשפ״ז
DateTime(2026, 9, 12).getHebrewDayOfMonth();    // א׳
DateTime(2026, 9, 1).getHebrewMonthsOfMonth();  // אלול–תשרי תשפ״ז
DateTime(1990).getHebrewYearsOfYear();          // תש״נ–תשנ״א
```

## Example

See the [example](example/lib/main.dart) app.
