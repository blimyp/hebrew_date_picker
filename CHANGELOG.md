## Unreleased

* Add `HebrewDateRangePicker` and `showHebrewDateRangePicker` to pick a range of dates. The
  header shows the Hebrew dates of the start and the end of the range.
* Add `selectableDayPredicate` to disable days that can't be picked.
* Add `showTodayButton` and `todayText` for a button that jumps to today and selects it.

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
