/// Where the Yamim Tovim are kept, which decides the days that are Yom Tov.
enum YomTovLocation {
  /// As kept in Israel: Rosh Hashana, Yom Kippur, the first day of Sukkot, Shemini Atzeres,
  /// the first and last days of Pesach, and Shavuos.
  israel,

  /// As kept outside Israel: the Yamim Tovim of Israel, and also the second days of Sukkot,
  /// Pesach and Shavuos, the eighth day of Pesach, and Simchas Torah.
  outsideIsrael,
}
