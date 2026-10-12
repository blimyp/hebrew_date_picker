# hebrew_date_picker

A Material-style Flutter date picker that shows the **Hebrew (Jewish) date** alongside the
Gregorian one:

* every day cell shows the Gregorian day and the Hebrew day in letters (e.g. `12` / `א׳`),
* the month title shows the Gregorian month and the Hebrew months it covers
  (e.g. `September 2026` / `אלול–תשרי תשפ״ז`),
* the header shows the full Hebrew date of the selected day (e.g. `א׳ תשרי תשפ״ז`).

Hebrew dates are calculated with [kosher_dart](https://pub.dev/packages/kosher_dart) and the
calendar grid is built on [table_calendar](https://pub.dev/packages/table_calendar).

## Installation

```yaml
dependencies:
  hebrew_date_picker: ^0.1.0
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

### Customization

| Parameter | Default |
|---|---|
| `primaryColor` | `ColorScheme.primary` |
| `secondaryTextColor` | `ColorScheme.onSurfaceVariant` |
| `helpText` | `MaterialLocalizations.datePickerHelpText` |
| `cancelText` | `MaterialLocalizations.cancelButtonLabel` |
| `confirmText` | `MaterialLocalizations.okButtonLabel` |
| `locale` | the `intl` default locale |

`locale` controls the Gregorian month title and the weekday names. For a locale other than
`en_US`, initialize the date formatting data first, e.g. by adding `flutter_localizations` to
your app or calling `initializeDateFormatting()` from `package:intl/date_symbol_data_local.dart`.

### Hebrew date helpers

The `DateTime` extension used by the picker is exported as well:

```dart
DateTime(2026, 9, 12).getHebrewDateFormatted(); // א׳ תשרי תשפ״ז
DateTime(2026, 9, 12).getHebrewDayOfMonth();    // א׳
DateTime(2026, 9, 1).getHebrewMonthsOfMonth();  // אלול–תשרי תשפ״ז
```

## Example

See the [example](example/lib/main.dart) app.
