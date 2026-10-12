import 'package:kosher_dart/kosher_dart.dart';

final HebrewDateFormatter _hebrewFormatter = HebrewDateFormatter()..hebrewFormat = true;

extension HebrewDateExtension on DateTime {
  JewishDate get _jewishDate => JewishDate.fromDateTime(DateTime(year, month, day));

  /// The full Hebrew date, e.g. "כ״ו תשרי תשפ״ז".
  String getHebrewDateFormatted() {
    return _hebrewFormatter.format(_jewishDate);
  }

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
}
