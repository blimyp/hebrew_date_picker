import 'package:flutter/painting.dart';

/// Which holidays the date pickers and the form fields mark, and how.
///
/// The Yamim Tovim are marked: Rosh Hashana, Yom Kippur, the first day of Sukkot, Shemini
/// Atzeres, the first and last days of Pesach and Shavuos. Outside Israel also the second
/// days of Sukkot, Pesach and Shavuos, the eighth day of Pesach, and Simchas Torah. Chol
/// Hamoed, Chanukah, Purim, fasts and modern holidays are not marked.
class HebrewHolidays {
  const HebrewHolidays({required this.decoration, this.inIsrael = true});

  /// Painted behind each Yom Tov, e.g. a [BoxDecoration] with a colored border. A selected
  /// day's circle covers it.
  final Decoration decoration;

  /// Whether to mark the Yamim Tovim as kept in Israel (the default) or as kept outside of it,
  /// with a second day of Yom Tov.
  final bool inIsrael;
}
