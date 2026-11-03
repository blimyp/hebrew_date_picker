import 'package:flutter/painting.dart';

import 'hebrew_date_extension.dart';
import 'yom_tov_location.dart';

/// Returns the decoration painted behind [day] in the date pickers, e.g. a [BoxDecoration]
/// with a colored border, or null to leave the day unmarked.
typedef DayDecorationBuilder = Decoration? Function(HebrewDay day);

/// A day of the date pickers' calendar, as passed to a [DayDecorationBuilder].
class HebrewDay {
  const HebrewDay(this.date, {this.yomTovLocation = YomTovLocation.israel});

  /// The date, without a time.
  final DateTime date;

  /// Where the Yamim Tovim are kept, the picker's `yomTovLocation`. It decides [isYomTov] and
  /// [yomTovName].
  final YomTovLocation yomTovLocation;

  /// Whether the day is a Yom Tov, as kept in [yomTovLocation].
  bool get isYomTov => date.isYomTov(location: yomTovLocation);

  /// The Hebrew name of the Yom Tov on this day, e.g. "ראש השנה", or null when [isYomTov] is
  /// false.
  String? get yomTovName => date.getYomTovName(location: yomTovLocation);
}
