import 'package:kosher_dart/kosher_dart.dart';

final HebrewDateFormatter _hebrewFormatter = HebrewDateFormatter()..hebrewFormat = true;

/// A Hebrew month, numbered consecutively from the start of the Hebrew calendar so it can be
/// paged like a Gregorian month.
class HebrewMonth {
  /// The month at [index] months after the start of the Hebrew calendar.
  HebrewMonth.fromIndex(this.index)
      : year = _yearOfIndex(index),
        month = _monthOfIndex(index);

  /// The Hebrew month of [day].
  factory HebrewMonth.of(DateTime day) {
    final date = JewishDate.fromDateTime(DateTime(day.year, day.month, day.day));
    return HebrewMonth.fromIndex(
      _monthsBeforeYear(date.getJewishYear()) +
          _positionInYear(date.getJewishYear(), date.getJewishMonth()),
    );
  }

  /// The month [month] (1 for Nisan ... 12 for Adar or Adar I, 13 for Adar II) of [year].
  /// Adar II becomes Adar in a year without one.
  factory HebrewMonth.inYear(int year, int month) {
    final int lastMonth = _isLeapYear(year) ? 13 : 12;
    return HebrewMonth.fromIndex(
      _monthsBeforeYear(year) + _positionInYear(year, month.clamp(1, lastMonth)),
    );
  }

  final int index;

  /// The Hebrew year, e.g. 5787.
  final int year;

  /// The Hebrew month as numbered by kosher_dart: 1 for Nisan ... 13 for Adar II.
  final int month;

  JewishDate _date(int day) =>
      JewishDate.initDate(jewishYear: year, jewishMonth: month, jewishDayOfMonth: day);

  /// The number of days in the month, 29 or 30.
  int get length => _date(1).getDaysInJewishMonth();

  /// The Gregorian date (UTC, without a time) of day [day] of the month.
  DateTime day(int day) {
    final date = _date(day);
    return DateTime.utc(
      date.getGregorianYear(),
      date.getGregorianMonth(),
      date.getGregorianDayOfMonth(),
    );
  }

  DateTime get firstDay => day(1);

  DateTime get lastDay => day(length);

  /// The month and the year in Hebrew, e.g. "חשוון תשפ״ז".
  String get title => '${_hebrewFormatter.formatMonth(_date(1))} ${formatYear(year)}';

  /// The Hebrew [year] in letters, e.g. "תשפ״ז".
  static String formatYear(int year) => _hebrewFormatter.formatHebrewNumber(year);

  /// The Gregorian years covered by the Hebrew [year], e.g. "2026–2027".
  static String gregorianYearsOf(int year) =>
      '${HebrewMonth.inYear(year, 7).firstDay.year}–${HebrewMonth.inYear(year, 6).lastDay.year}';

  static bool _isLeapYear(int year) => (7 * year + 1) % 19 < 7;

  /// The number of months from the start of the Hebrew calendar to Tishrei of [year].
  static int _monthsBeforeYear(int year) => (235 * year - 234) ~/ 19;

  /// The position of [month] in [year] counted from Tishrei, which is 0.
  static int _positionInYear(int year, int month) {
    final int monthsInYear = _isLeapYear(year) ? 13 : 12;
    return month >= 7 ? month - 7 : month + monthsInYear - 7;
  }

  static int _yearOfIndex(int index) {
    int year = index * 19 ~/ 235 + 1;
    while (_monthsBeforeYear(year + 1) <= index) {
      year++;
    }
    while (_monthsBeforeYear(year) > index) {
      year--;
    }
    return year;
  }

  static int _monthOfIndex(int index) {
    final int year = _yearOfIndex(index);
    final int monthsInYear = _isLeapYear(year) ? 13 : 12;
    final int month = index - _monthsBeforeYear(year) + 7;
    return month <= monthsInYear ? month : month - monthsInYear;
  }
}
