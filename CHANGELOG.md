## 0.4.0

* **Breaking:** `dayMode` now decides which calendar the whole picker shows, not only the
  day cells. With `CalendarMode.gregorian` the header, the month title and the year grid show
  no Hebrew dates; with `CalendarMode.hebrew` they show no Gregorian dates.
  `CalendarMode.both` (the default) is unchanged.
* Rename `dayMode` to `calendarMode` and `DayMode` to `CalendarMode`, to match what they do
  now. The old names still work but are deprecated, and will be removed in 1.0.0.
* With `CalendarMode.hebrew` the calendar pages by Hebrew months instead of Gregorian ones: each
  page is a whole Hebrew month, titled e.g. `תשרי תשפ״ז`, with Hebrew weekday letters, and
  the year grid lists Hebrew years. Selecting a year keeps the Hebrew day and month.
* Add screenshots of `CalendarMode.hebrew` and of the form fields, and refresh the date
  picker's screenshot.

## 0.3.0

* Add `HebrewDateFormField`: a read-only text field that opens the date picker when tapped,
  or with Enter or Space when focused, and shows the picked date. It is a `FormField`, with
  `validator`, `onSaved` and `onChanged`, and its text follows `dayMode` or a custom
  `dateFormatter`. A new `initialValue` from the parent replaces the field's value, so it can
  follow a date kept outside of it.
* Add `HebrewDateRangeFormField`, the same for the date range picker. Its default text writes
  what both ends share once, e.g. `Sep 12 – Sep 20, 2026 · א׳–ט׳ תשרי תשפ״ז`.

## 0.2.0

* Add `HebrewDateRangePicker` and `showHebrewDateRangePicker` to pick a range of dates. The
  header shows the Hebrew dates of the start and the end of the range.
* Add `selectableDayPredicate` to disable days that can't be picked.
* Add `showTodayButton` and `todayText` for a button that jumps to today and selects it.
* Add a screenshot of the range picker.

## 0.1.1

* Add `dayMode` (`DayMode.both` / `hebrew` / `gregorian`) to choose what each day cell shows.
* Tap the month title to pick a year from a grid that shows the Gregorian and the Hebrew
  years. Add `initialDatePickerMode` to open the picker on the year grid.
* Add `getHebrewYearsOfYear` to `HebrewDateExtension`.
* Add pub.dev topics and a screenshot.

## 0.1.0

* Initial release.
* `HebrewDatePicker` widget and `showHebrewDatePicker` dialog helper.
* `HebrewDateExtension` on `DateTime`: `getHebrewDateFormatted`, `getHebrewDayOfMonth`,
  `getHebrewMonthsOfMonth`.
