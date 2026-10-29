import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kosher_dart/kosher_dart.dart';

import 'calendar_mode.dart';
import 'hebrew_date_extension.dart';
import 'hebrew_date_picker.dart';
import 'hebrew_holidays.dart';

/// Formats a date for the text of a [HebrewDateFormField] or a [HebrewDateRangeFormField].
typedef HebrewDateFieldFormatter = String Function(BuildContext context, DateTime date);

/// A read-only text field that opens [showHebrewDatePicker] when tapped and shows the
/// picked date.
///
/// It is a [FormField], so it works inside a [Form] with [validator] and [onSaved], and on
/// its own with [onChanged].
///
/// When the parent rebuilds it with a different `initialValue`, the field shows that value
/// instead (without calling [onChanged]), so it can follow a date kept outside of it. Store the
/// picked date from [onChanged] and pass it back as `initialValue` to keep both in sync.
///
/// By default the text follows [calendarMode]: the Gregorian date, the Hebrew date or both. Pass
/// [dateFormatter] to show something else.
class HebrewDateFormField extends FormField<DateTime> {
  HebrewDateFormField({
    super.key,
    DateTime? initialValue,
    required this.firstDate,
    required this.lastDate,
    this.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.restorationId,
    this.decoration = const InputDecoration(),
    this.style,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.dateFormatter,
    this.selectableDayPredicate,
    CalendarMode calendarMode = CalendarMode.both,
    @Deprecated('Use calendarMode instead. Will be removed in 1.0.0.') CalendarMode? dayMode,
    this.initialDatePickerMode = DatePickerMode.day,
    this.showTodayButton = false,
    this.holidays,
    @Deprecated('Use holidays instead. Will be removed in 1.0.0.') this.holidayDecoration,
    this.locale,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.todayText,
    this.primaryColor,
    this.secondaryTextColor,
  })  : calendarMode = dayMode ?? calendarMode,
        assert(
          holidays == null || holidayDecoration == null,
          'Pass either holidays or holidayDecoration, not both.',
        ),
        super(
          initialValue: initialValue == null ? null : _dateOnly(initialValue),
          builder: (field) => (field as _HebrewDateFormFieldState)._buildTextField(),
        );

  /// The earliest date the picker allows.
  final DateTime firstDate;

  /// The latest date the picker allows.
  final DateTime lastDate;

  /// Called with the picked date (time stripped) whenever the user picks a new one.
  ///
  /// The date is nullable so that a future way to clear the field can report it.
  final ValueChanged<DateTime?>? onChanged;

  /// The decoration of the text field, e.g. its label, hint and icons. The [validator]'s
  /// error text is added to it.
  final InputDecoration decoration;

  /// The style of the date text.
  final TextStyle? style;

  /// How the date text is aligned in the field.
  final TextAlign textAlign;

  /// The focus node of the text field.
  final FocusNode? focusNode;

  /// Formats the date shown in the field. Defaults to a format that follows [calendarMode].
  final HebrewDateFieldFormatter? dateFormatter;

  /// See [HebrewDatePicker.selectableDayPredicate].
  final SelectableDayPredicate? selectableDayPredicate;

  /// Which calendar the picker shows. Also picks the default format of the text.
  final CalendarMode calendarMode;

  /// The old name of [calendarMode].
  @Deprecated('Use calendarMode instead. Will be removed in 1.0.0.')
  CalendarMode get dayMode => calendarMode;

  /// See [HebrewDatePicker.initialDatePickerMode].
  final DatePickerMode initialDatePickerMode;

  /// See [HebrewDatePicker.showTodayButton].
  final bool showTodayButton;

  /// See [HebrewDatePicker.holidays].
  final HebrewHolidays? holidays;

  /// The old way to mark the Yamim Tovim, as kept in Israel. The same as
  /// `holidays: HebrewHolidays(decoration: holidayDecoration)`. Can't be set with [holidays].
  @Deprecated('Use holidays instead. Will be removed in 1.0.0.')
  final Decoration? holidayDecoration;

  /// See [HebrewDatePicker.locale].
  final String? locale;

  /// See [HebrewDatePicker.helpText].
  final String? helpText;

  /// See [HebrewDatePicker.cancelText].
  final String? cancelText;

  /// See [HebrewDatePicker.confirmText].
  final String? confirmText;

  /// See [HebrewDatePicker.todayText].
  final String? todayText;

  /// See [HebrewDatePicker.primaryColor].
  final Color? primaryColor;

  /// See [HebrewDatePicker.secondaryTextColor].
  final Color? secondaryTextColor;

  @override
  FormFieldState<DateTime> createState() => _HebrewDateFormFieldState();
}

class _HebrewDateFormFieldState extends _PickerFormFieldState<DateTime> {
  @override
  HebrewDateFormField get widget => super.widget as HebrewDateFormField;

  @override
  InputDecoration get _decoration => widget.decoration;

  @override
  TextStyle? get _style => widget.style;

  @override
  TextAlign get _textAlign => widget.textAlign;

  @override
  FocusNode? get _focusNode => widget.focusNode;

  @override
  String _format(DateTime value) =>
      (widget.dateFormatter ?? _defaultFormatter(widget.calendarMode))(context, value);

  @override
  Future<DateTime?> _pick() {
    final predicate = widget.selectableDayPredicate;
    return showHebrewDatePicker(
      context: context,
      initialDate: value ??
          _initialPickerDate(widget.firstDate, widget.lastDate, predicate) ??
          DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectableDayPredicate: predicate,
      calendarMode: widget.calendarMode,
      initialDatePickerMode: widget.initialDatePickerMode,
      showTodayButton: widget.showTodayButton,
      holidays: widget.holidays,
      // ignore: deprecated_member_use_from_same_package
      holidayDecoration: widget.holidayDecoration,
      locale: widget.locale,
      helpText: widget.helpText,
      cancelText: widget.cancelText,
      confirmText: widget.confirmText,
      todayText: widget.todayText,
      primaryColor: widget.primaryColor,
      secondaryTextColor: widget.secondaryTextColor,
    );
  }

  @override
  void _notifyChanged(DateTime? value) => widget.onChanged?.call(value);
}

/// A read-only text field that opens [showHebrewDateRangePicker] when tapped and shows the
/// picked range.
///
/// It is a [FormField], so it works inside a [Form] with [validator] and [onSaved], and on
/// its own with [onChanged].
///
/// When the parent rebuilds it with a different `initialValue`, the field shows that range
/// instead (without calling [onChanged]), so it can follow a range kept outside of it.
///
/// By default the text follows [calendarMode] and writes what both ends share once, so it fits in
/// one field: "Sep 12 – Sep 20, 2026 · א׳–ט׳ תשרי תשפ״ז". Pass [dateFormatter] to format each
/// end yourself instead.
class HebrewDateRangeFormField extends FormField<DateTimeRange> {
  HebrewDateRangeFormField({
    super.key,
    DateTimeRange? initialValue,
    required this.firstDate,
    required this.lastDate,
    this.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.restorationId,
    this.decoration = const InputDecoration(),
    this.style,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.dateFormatter,
    this.selectableDayPredicate,
    CalendarMode calendarMode = CalendarMode.both,
    @Deprecated('Use calendarMode instead. Will be removed in 1.0.0.') CalendarMode? dayMode,
    this.initialDatePickerMode = DatePickerMode.day,
    this.showTodayButton = false,
    this.holidays,
    @Deprecated('Use holidays instead. Will be removed in 1.0.0.') this.holidayDecoration,
    this.locale,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.todayText,
    this.primaryColor,
    this.secondaryTextColor,
  })  : calendarMode = dayMode ?? calendarMode,
        assert(
          holidays == null || holidayDecoration == null,
          'Pass either holidays or holidayDecoration, not both.',
        ),
        super(
          initialValue: initialValue == null
              ? null
              : DateTimeRange(
                  start: _dateOnly(initialValue.start),
                  end: _dateOnly(initialValue.end),
                ),
          builder: (field) => (field as _HebrewDateRangeFormFieldState)._buildTextField(),
        );

  /// The earliest date the picker allows.
  final DateTime firstDate;

  /// The latest date the picker allows.
  final DateTime lastDate;

  /// Called with the picked range (times stripped) whenever the user picks a new one.
  ///
  /// The range is nullable so that a future way to clear the field can report it.
  final ValueChanged<DateTimeRange?>? onChanged;

  /// The decoration of the text field, e.g. its label, hint and icons. The [validator]'s
  /// error text is added to it.
  final InputDecoration decoration;

  /// The style of the range text.
  final TextStyle? style;

  /// How the range text is aligned in the field.
  final TextAlign textAlign;

  /// The focus node of the text field.
  final FocusNode? focusNode;

  /// Formats each end of the range shown in the field. Defaults to a format that follows
  /// [calendarMode].
  final HebrewDateFieldFormatter? dateFormatter;

  /// See [HebrewDateRangePicker.selectableDayPredicate].
  final SelectableDayPredicate? selectableDayPredicate;

  /// Which calendar the picker shows. Also picks the default format of the text.
  final CalendarMode calendarMode;

  /// The old name of [calendarMode].
  @Deprecated('Use calendarMode instead. Will be removed in 1.0.0.')
  CalendarMode get dayMode => calendarMode;

  /// See [HebrewDateRangePicker.initialDatePickerMode].
  final DatePickerMode initialDatePickerMode;

  /// See [HebrewDateRangePicker.showTodayButton].
  final bool showTodayButton;

  /// See [HebrewDateRangePicker.holidays].
  final HebrewHolidays? holidays;

  /// The old way to mark the Yamim Tovim, as kept in Israel. The same as
  /// `holidays: HebrewHolidays(decoration: holidayDecoration)`. Can't be set with [holidays].
  @Deprecated('Use holidays instead. Will be removed in 1.0.0.')
  final Decoration? holidayDecoration;

  /// See [HebrewDateRangePicker.locale].
  final String? locale;

  /// See [HebrewDateRangePicker.helpText].
  final String? helpText;

  /// See [HebrewDateRangePicker.cancelText].
  final String? cancelText;

  /// See [HebrewDateRangePicker.confirmText].
  final String? confirmText;

  /// See [HebrewDateRangePicker.todayText].
  final String? todayText;

  /// See [HebrewDateRangePicker.primaryColor].
  final Color? primaryColor;

  /// See [HebrewDateRangePicker.secondaryTextColor].
  final Color? secondaryTextColor;

  @override
  FormFieldState<DateTimeRange> createState() => _HebrewDateRangeFormFieldState();
}

class _HebrewDateRangeFormFieldState extends _PickerFormFieldState<DateTimeRange> {
  @override
  HebrewDateRangeFormField get widget => super.widget as HebrewDateRangeFormField;

  @override
  InputDecoration get _decoration => widget.decoration;

  @override
  TextStyle? get _style => widget.style;

  @override
  TextAlign get _textAlign => widget.textAlign;

  @override
  FocusNode? get _focusNode => widget.focusNode;

  @override
  String _format(DateTimeRange value) {
    final format = widget.dateFormatter;
    if (format == null) return _defaultRangeText(context, value, widget.calendarMode);
    return '${format(context, value.start)} – ${format(context, value.end)}';
  }

  @override
  Future<DateTimeRange?> _pick() {
    return showHebrewDateRangePicker(
      context: context,
      initialDateRange: value,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      selectableDayPredicate: widget.selectableDayPredicate,
      calendarMode: widget.calendarMode,
      initialDatePickerMode: widget.initialDatePickerMode,
      showTodayButton: widget.showTodayButton,
      holidays: widget.holidays,
      // ignore: deprecated_member_use_from_same_package
      holidayDecoration: widget.holidayDecoration,
      locale: widget.locale,
      helpText: widget.helpText,
      cancelText: widget.cancelText,
      confirmText: widget.confirmText,
      todayText: widget.todayText,
      primaryColor: widget.primaryColor,
      secondaryTextColor: widget.secondaryTextColor,
    );
  }

  @override
  void _notifyChanged(DateTimeRange? value) => widget.onChanged?.call(value);
}

/// The shared state of the picker form fields: a read-only [TextField] that shows the
/// formatted value and opens the picker when tapped.
abstract class _PickerFormFieldState<T> extends FormFieldState<T> {
  final TextEditingController _controller = TextEditingController();

  InputDecoration get _decoration;
  TextStyle? get _style;
  TextAlign get _textAlign;
  FocusNode? get _focusNode;

  String _format(T value);
  Future<T?> _pick();
  void _notifyChanged(T? value);

  bool _picking = false;

  // Like DropdownButtonFormField: a new initialValue from the parent replaces the value, so
  // the field follows a value kept outside of it (e.g. an end date moved by its start date).
  @override
  void didUpdateWidget(covariant FormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) setValue(widget.initialValue);
  }

  Future<void> _onTap() async {
    if (_picking) return;
    _picking = true;
    try {
      final picked = await _pick();
      if (picked == null || !mounted) return;
      didChange(picked);
      _notifyChanged(picked);
    } finally {
      _picking = false;
    }
  }

  Widget _buildTextField() {
    final value = this.value;
    final text = value == null ? '' : _format(value);
    // The field and its descendants are being built, so updating the text here is safe.
    if (_controller.text != text) _controller.text = text;
    final enabled = widget.enabled;
    // Enter and Space open the picker too, for keyboard users who reach the field with Tab.
    return CallbackShortcuts(
      bindings: enabled
          ? {
              const SingleActivator(LogicalKeyboardKey.enter): _onTap,
              const SingleActivator(LogicalKeyboardKey.numpadEnter): _onTap,
              const SingleActivator(LogicalKeyboardKey.space): _onTap,
            }
          : const {},
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: true,
        enabled: enabled,
        style: _style,
        textAlign: _textAlign,
        enableInteractiveSelection: false,
        mouseCursor: enabled ? SystemMouseCursors.click : null,
        decoration: _decoration
            .applyDefaults(Theme.of(context).inputDecorationTheme)
            .copyWith(errorText: errorText),
        onTap: enabled ? _onTap : null,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Today's date, moved into [firstDate]..[lastDate] and then to the nearest day that
/// satisfies [predicate] - the picker requires its initial date to be selectable.
DateTime? _initialPickerDate(
  DateTime firstDate,
  DateTime lastDate,
  SelectableDayPredicate? predicate,
) {
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  var start = _dateOnly(DateTime.now());
  if (start.isBefore(first)) start = first;
  if (start.isAfter(last)) start = last;
  if (predicate == null || predicate(start)) return start;
  for (var offset = 1; offset <= 366; offset++) {
    for (final day in [
      DateTime(start.year, start.month, start.day + offset),
      DateTime(start.year, start.month, start.day - offset),
    ]) {
      if (!day.isBefore(first) && !day.isAfter(last) && predicate(day)) return day;
    }
  }
  return null;
}

HebrewDateFieldFormatter _defaultFormatter(CalendarMode calendarMode) {
  return (context, date) {
    final gregorian = MaterialLocalizations.of(context).formatShortDate(date);
    return switch (calendarMode) {
      CalendarMode.both => '$gregorian · ${date.getHebrewDateFormatted()}',
      CalendarMode.hebrew => date.getHebrewDateFormatted(),
      CalendarMode.gregorian => gregorian,
    };
  };
}

final HebrewDateFormatter _hebrewFormatter = HebrewDateFormatter()..hebrewFormat = true;

/// The default range text. The ends share what they have in common, so both calendars fit in
/// one field: "Sep 12 – Sep 20, 2026 · א׳–ט׳ תשרי תשפ״ז".
String _defaultRangeText(BuildContext context, DateTimeRange range, CalendarMode calendarMode) {
  final start = range.start;
  final end = range.end;
  final localizations = MaterialLocalizations.of(context);

  String gregorian() {
    if (DateUtils.isSameDay(start, end)) return localizations.formatShortDate(start);
    final startText = start.year == end.year
        ? localizations.formatShortMonthDay(start)
        : localizations.formatShortDate(start);
    return '$startText – ${localizations.formatShortDate(end)}';
  }

  String hebrew() {
    if (DateUtils.isSameDay(start, end)) return start.getHebrewDateFormatted();
    final startDate = JewishDate.fromDateTime(DateTime(start.year, start.month, start.day));
    final endDate = JewishDate.fromDateTime(DateTime(end.year, end.month, end.day));
    if (startDate.getJewishYear() != endDate.getJewishYear()) {
      return '${start.getHebrewDateFormatted()} – ${end.getHebrewDateFormatted()}';
    }
    final year = _hebrewFormatter.formatHebrewNumber(endDate.getJewishYear());
    final startMonth = _hebrewFormatter.formatMonth(startDate);
    final endMonth = _hebrewFormatter.formatMonth(endDate);
    if (startMonth == endMonth) {
      return '${start.getHebrewDayOfMonth()}–${end.getHebrewDayOfMonth()} $endMonth $year';
    }
    return '${start.getHebrewDayOfMonth()} $startMonth – '
        '${end.getHebrewDayOfMonth()} $endMonth $year';
  }

  return switch (calendarMode) {
    CalendarMode.both => '${gregorian()} · ${hebrew()}',
    CalendarMode.hebrew => hebrew(),
    CalendarMode.gregorian => gregorian(),
  };
}
