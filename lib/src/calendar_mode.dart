/// Which calendar the `HebrewDatePicker` shows.
enum CalendarMode {
  /// Both calendars: the Gregorian day with the Hebrew day below it (`12` / `א׳`), and the
  /// Hebrew dates under the Gregorian ones in the header, the month title and the year grid.
  both,

  /// Only the Hebrew calendar: the Hebrew day (`א׳`), Hebrew months and Hebrew years.
  hebrew,

  /// Only the Gregorian calendar: the Gregorian day (`12`), months and years.
  gregorian,
}

/// The old name of [CalendarMode].
@Deprecated('Use CalendarMode instead. Will be removed in 1.0.0.')
typedef DayMode = CalendarMode;
