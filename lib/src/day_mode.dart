/// What a day cell of the `HebrewDatePicker` shows.
enum DayMode {
  /// The Gregorian day with the Hebrew day below it, e.g. `12` / `א׳`.
  both,

  /// Only the Hebrew day, e.g. `א׳`.
  hebrew,

  /// Only the Gregorian day, e.g. `12`.
  gregorian,
}
