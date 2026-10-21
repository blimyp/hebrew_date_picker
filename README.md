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

**[▶ Try the live demo](https://blimyp.github.io/hebrew_date_picker/)** — no installation needed.

<img src="https://raw.githubusercontent.com/blimyp/hebrew_date_picker/main/screenshots/hebrew_date_picker.png" alt="Hebrew date picker" width="260"> <img src="https://raw.githubusercontent.com/blimyp/hebrew_date_picker/main/screenshots/hebrew_date_range_picker.png" alt="Hebrew date range picker" width="260"> <img src="https://raw.githubusercontent.com/blimyp/hebrew_date_picker/main/screenshots/hebrew_calendar_mode.png" alt="Hebrew date picker with CalendarMode.hebrew" width="260">

Hebrew dates are calculated with [kosher_dart](https://pub.dev/packages/kosher_dart) and the
calendar grid is built on [table_calendar](https://pub.dev/packages/table_calendar).

## Installation

```yaml
dependencies:
  hebrew_date_picker: ^0.4.0
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

### As a text field

`HebrewDateFormField` is a read-only text field that opens the picker when tapped and shows
the picked date, so you don't have to build one yourself. It is a `FormField`, so it works
inside a `Form` with `validator` and `onSaved`, and on its own with `onChanged`:

<img src="https://raw.githubusercontent.com/blimyp/hebrew_date_picker/main/screenshots/hebrew_date_form_field.png" alt="Hebrew date form fields" width="480">

```dart
HebrewDateFormField(
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  decoration: const InputDecoration(
    labelText: 'Date',
    suffixIcon: Icon(Icons.calendar_today),
    border: OutlineInputBorder(),
  ),
  validator: (date) => date == null ? 'Pick a date' : null,
  onChanged: (date) => print(date),
)
```

`initialValue` is optional; while the field is empty the picker opens on today. When the
parent rebuilds the field with a different `initialValue`, the field shows the new value, so
it can follow a date kept elsewhere — e.g. an end date that moves with the start date:

```dart
DateTime? _endDate; // updated by onChanged and by the start date's field

HebrewDateFormField(
  initialValue: _endDate,
  firstDate: _startDate,
  lastDate: DateTime(2030),
  onChanged: (date) => setState(() => _endDate = date),
)
```

`onChanged` takes a nullable date (`ValueChanged<DateTime?>`), leaving room for clearing the
field in a later version.

The field takes the same customization parameters as `HebrewDatePicker`, plus `decoration`,
`style`, `textAlign`, `focusNode` and `enabled`. Tapping it, or pressing Enter or Space while
it is focused, opens the picker. By default its text follows `calendarMode`: the Gregorian
and the Hebrew date (`Oct 15, 2026 · ד׳ חשוון תשפ״ז`) for `both`, only the Hebrew date for
`hebrew` and only the Gregorian date for `gregorian`. Pass `dateFormatter` to show something
else:

```dart
HebrewDateFormField(
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  dateFormatter: (context, date) => date.getHebrewDateFormatted(),
)
```

`HebrewDateRangeFormField` does the same with the range picker. Its default text writes what
both ends share once, so both calendars fit in one field:
`Sep 12 – Sep 20, 2026 · א׳–ט׳ תשרי תשפ״ז`. A `dateFormatter` formats each end instead.

### Customization

| Parameter | Default |
|---|---|
| `calendarMode` | `CalendarMode.both` |
| `selectableDayPredicate` | every day is selectable |
| `showTodayButton` | `false` |
| `holidayDecoration` | `null` (no days are marked) |
| `initialDatePickerMode` | `DatePickerMode.day` |
| `primaryColor` | `ColorScheme.primary` |
| `secondaryTextColor` | `ColorScheme.onSurfaceVariant` |
| `helpText` | `MaterialLocalizations.datePickerHelpText` |
| `cancelText` | `MaterialLocalizations.cancelButtonLabel` |
| `confirmText` | `MaterialLocalizations.okButtonLabel` |
| `todayText` | `MaterialLocalizations.currentDateLabel` |
| `locale` | the `intl` default locale |

`calendarMode` controls which calendar the picker shows - both, or only one of them:

| | `both` | `hebrew` | `gregorian` |
|---|---|---|---|
| Day cell | `12` / `א׳` | `א׳` | `12` |
| Header | `Sat, Sep 12` / `א׳ תשרי תשפ״ז` | `א׳ תשרי תשפ״ז` | `Sat, Sep 12` |
| Month title | `September 2026` / `אלול–תשרי תשפ״ז` | `תשרי תשפ״ז` | `September 2026` |
| Pages by | Gregorian months | Hebrew months | Gregorian months |
| Weekdays | from `locale` | `א ב ג ד ה ו ש` | from `locale` |
| Year grid | `2026` / `תשפ״ו–תשפ״ז` | `תשפ״ז` | `2026` |

With `CalendarMode.hebrew` each page is a whole Hebrew month, and selecting a year keeps the
Hebrew day and month.

```dart
showHebrewDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  calendarMode: CalendarMode.hebrew,
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

`holidayDecoration` marks the Yamim Tovim: Rosh Hashana, Yom Kippur, the first day of Sukkot,
Shemini Atzeres, the first and last days of Pesach and Shavuos, as kept in Israel. Chol
Hamoed, Chanukah, Purim, fasts and modern holidays are not marked. It takes any `Decoration`,
painted behind the day, so a selected day's circle covers it. For example, an orange ring:

```dart
showHebrewDatePicker(
  context: context,
  initialDate: DateTime(2026, 9, 1),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  holidayDecoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: Colors.orange, width: 2),
  ),
);
```

Here the dashed circles mark Rosh Hashana (12–13), Yom Kippur (21) and Sukkot (26). The
example app draws them with a custom `Decoration`:

<img src="https://raw.githubusercontent.com/blimyp/hebrew_date_picker/main/screenshots/hebrew_holidays.png" alt="Hebrew date picker marking the Yamim Tovim with a dashed circle" width="260">

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
DateTime(2026, 9, 21).isYomTov();               // true (Yom Kippur)
```

## Example

See the [example](example/lib/main.dart) app.
