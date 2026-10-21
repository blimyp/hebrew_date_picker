import 'package:kosher_dart/kosher_dart.dart';

final HebrewDateFormatter _hebrewFormatter = HebrewDateFormatter()..hebrewFormat = true;

extension HebrewDateExtension on DateTime {
  JewishDate get _jewishDate => JewishDate.fromDateTime(DateTime(year, month, day));

  /// The full Hebrew date, e.g. "כ״ו תשרי תשפ״ז".
  String getHebrewDateFormatted() {
    return _hebrewFormatter.format(_jewishDate);
  }

  /// Whether this day is a Yom Tov as kept in Israel: Rosh Hashana, Yom Kippur, the first day
  /// of Sukkot, Shemini Atzeres, the first and last days of Pesach, or Shavuos.
  /// Chol Hamoed, Chanukah, Purim, fasts and modern holidays are not.
  bool isYomTov() => _israelCalendar.isYomTovAssurBemelacha();

  /// The Hebrew name of the Yom Tov on this day, e.g. "ראש השנה", or null when [isYomTov] is
  /// false.
  String? getYomTovName() {
    final calendar = _israelCalendar;
    return calendar.isYomTovAssurBemelacha() ? _hebrewFormatter.formatYomTov(calendar) : null;
  }

  JewishCalendar get _israelCalendar =>
      JewishCalendar.fromDateTime(DateTime(year, month, day))..inIsrael = true;

  /// The Hebrew day of month in letters, e.g. "כ״ו".
  String getHebrewDayOfMonth() {
    return _hebrewFormatter.formatHebrewNumber(_jewishDate.getJewishDayOfMonth());
  }

  /// The Hebrew month(s) covered by this Gregorian month, e.g. "תשרי–חשוון תשפ״ז".
  String getHebrewMonthsOfMonth() {
    final first = DateTime(year, month, 1)._jewishDate;
    final last = DateTime(year, month + 1, 0)._jewishDate;
    final firstMonth = _hebrewFormatter.formatMonth(first);
    final lastMonth = _hebrewFormatter.formatMonth(last);
    final lastYear = _hebrewFormatter.formatHebrewNumber(last.getJewishYear());
    if (first.getJewishYear() != last.getJewishYear()) {
      final firstYear = _hebrewFormatter.formatHebrewNumber(first.getJewishYear());
      return '$firstMonth $firstYear–$lastMonth $lastYear';
    }
    if (firstMonth == lastMonth) return '$firstMonth $lastYear';
    return '$firstMonth–$lastMonth $lastYear';
  }

  /// The Hebrew years covered by this Gregorian year, e.g. "תש״ן–תשנ״א".
  String getHebrewYearsOfYear() {
    final first = DateTime(year, 1, 1)._jewishDate.getJewishYear();
    final last = DateTime(year, 12, 31)._jewishDate.getJewishYear();
    return '${_hebrewFormatter.formatHebrewNumber(first)}–'
        '${_hebrewFormatter.formatHebrewNumber(last)}';
  }
}
