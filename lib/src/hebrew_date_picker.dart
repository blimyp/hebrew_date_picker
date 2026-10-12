import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'day_mode.dart';
import 'hebrew_date_extension.dart';

/// Shows a Material-style dialog with a [HebrewDatePicker].
///
/// Completes with the selected date (time stripped), or null if the picker was canceled
/// or dismissed.
Future<DateTime?> showHebrewDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DayMode dayMode = DayMode.both,
  String? locale,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Color? primaryColor,
  Color? secondaryTextColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: HebrewDatePicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
            dayMode: dayMode,
            locale: locale,
            helpText: helpText,
            cancelText: cancelText,
            confirmText: confirmText,
            primaryColor: primaryColor,
            secondaryTextColor: secondaryTextColor,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: (date) => Navigator.of(dialogContext).pop(date),
          ),
        ),
      ),
    ),
  );
}

/// Date picker styled like the Material one, with the Hebrew date shown in every day cell,
/// the Hebrew months in the month title and the full Hebrew date of the selected day.
///
/// Use [showHebrewDatePicker] to open it in a dialog, or embed it in your own container.
class HebrewDatePicker extends StatefulWidget {
  const HebrewDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onConfirm,
    this.onCancel,
    this.onDateChanged,
    this.dayMode = DayMode.both,
    this.locale,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.primaryColor,
    this.secondaryTextColor,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Called with the selected date (time stripped) when the confirm button is pressed.
  final ValueChanged<DateTime> onConfirm;

  /// Called when the cancel button is pressed. The cancel button is hidden when null.
  final VoidCallback? onCancel;

  /// Called whenever a day is tapped, before confirmation.
  final ValueChanged<DateTime>? onDateChanged;

  /// What each day cell shows: the Gregorian day, the Hebrew day or both (the default).
  final DayMode dayMode;

  /// Locale used for the Gregorian month title and weekday names, e.g. 'he' or 'en_US'.
  /// Locales other than en_US require date formatting data to be initialized (for example
  /// via `flutter_localizations` or `initializeDateFormatting`).
  final String? locale;

  /// Defaults to [MaterialLocalizations.datePickerHelpText].
  final String? helpText;

  /// Defaults to [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Defaults to [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Color of the header, the selected day and the buttons. Defaults to [ColorScheme.primary].
  final Color? primaryColor;

  /// Color of secondary texts (weekday names, Hebrew months, disabled days).
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? secondaryTextColor;

  @override
  State<HebrewDatePicker> createState() => _HebrewDatePickerState();
}

class _HebrewDatePickerState extends State<HebrewDatePicker> {
  late final DateTime _firstDay = _dateOnly(widget.firstDate);
  late final DateTime _lastDay = _dateOnly(widget.lastDate);
  late DateTime _selectedDay = _clamp(_dateOnly(widget.initialDate));
  late DateTime _focusedDay = _selectedDay;
  PageController? _pageController;

  static const double _rowHeight = 54;
  static const double _daysOfWeekHeight = 32;

  // TableCalendar uses a LayoutBuilder, which can't report intrinsic dimensions, so the
  // calendar gets a fixed height (six week rows) and the month title is built outside of
  // it - this lets the picker live inside containers that measure their content intrinsically.
  static const double _calendarHeight = _daysOfWeekHeight + 6 * _rowHeight;

  DateTime _dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day);

  DateTime _clamp(DateTime day) {
    if (day.isBefore(_firstDay)) return _firstDay;
    if (day.isAfter(_lastDay)) return _lastDay;
    return day;
  }

  DateTime get _selectedLocalDate =>
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

  Color get _primaryColor => widget.primaryColor ?? Theme.of(context).colorScheme.primary;

  Color get _onPrimaryColor => ThemeData.estimateBrightnessForColor(_primaryColor) ==
          Brightness.dark
      ? Colors.white
      : Colors.black;

  Color get _textColor => Theme.of(context).colorScheme.onSurface;

  Color get _secondaryTextColor =>
      widget.secondaryTextColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _selectedDateHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _monthTitle(),
              const SizedBox(height: 8),
              SizedBox(height: _calendarHeight, child: _tableCalendar()),
              _actions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectedDateHeader() {
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    return Container(
      color: _primaryColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.helpText ?? localizations.datePickerHelpText,
            style: textTheme.labelMedium?.copyWith(color: _onPrimaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.formatMediumDate(_selectedLocalDate),
            style: textTheme.headlineSmall?.copyWith(color: _onPrimaryColor),
          ),
          Text(
            _selectedDay.getHebrewDateFormatted(),
            style: textTheme.bodyMedium?.copyWith(color: _onPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _monthTitle() {
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMM(widget.locale).format(_focusedDay),
                style: textTheme.titleSmall?.copyWith(color: _textColor),
              ),
              Text(
                _focusedDay.getHebrewMonthsOfMonth(),
                style: textTheme.bodySmall?.copyWith(color: _secondaryTextColor),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: localizations.previousMonthTooltip,
          icon: Icon(Icons.chevron_left, color: _secondaryTextColor),
          onPressed: () => _pageController?.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        ),
        IconButton(
          tooltip: localizations.nextMonthTooltip,
          icon: Icon(Icons.chevron_right, color: _secondaryTextColor),
          onPressed: () => _pageController?.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        ),
      ],
    );
  }

  Widget _tableCalendar() {
    final weekdayStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(color: _secondaryTextColor);
    return TableCalendar(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      locale: widget.locale,
      headerVisible: false,
      sixWeekMonthsEnforced: true,
      daysOfWeekHeight: _daysOfWeekHeight,
      rowHeight: _rowHeight,
      onCalendarCreated: (pageController) => _pageController = pageController,
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (date, locale) => DateFormat.EEEEE(locale).format(date),
        weekdayStyle: weekdayStyle,
        weekendStyle: weekdayStyle,
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: EdgeInsets.zero,
      ),
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDateChanged?.call(_selectedLocalDate);
      },
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _dayCell(day),
        todayBuilder: (context, day, focusedDay) => _dayCell(day, today: true),
        disabledBuilder: (context, day, focusedDay) => _dayCell(day, enabled: false),
        selectedBuilder: (context, day, focusedDay) => _dayCell(day, selected: true),
      ),
    );
  }

  Widget _dayCell(DateTime day, {bool enabled = true, bool selected = false, bool today = false}) {
    final textTheme = Theme.of(context).textTheme;
    final Color dayColor = selected
        ? _onPrimaryColor
        : (!enabled ? _secondaryTextColor : (today ? _primaryColor : _textColor));
    final Color hebrewDayColor =
        selected ? _onPrimaryColor : (enabled ? _textColor : _secondaryTextColor);
    final TextStyle? mainStyle = textTheme.bodyMedium?.copyWith(
      color: dayColor,
      fontWeight: FontWeight.bold,
      height: 1.1,
    );
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? _primaryColor : null,
        border: today && !selected ? Border.all(color: _primaryColor) : null,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: switch (widget.dayMode) {
        DayMode.gregorian => Text('${day.day}', style: mainStyle),
        DayMode.hebrew => Text(day.getHebrewDayOfMonth(), style: mainStyle),
        DayMode.both => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${day.day}', style: mainStyle),
              const SizedBox(height: 3),
              Text(
                day.getHebrewDayOfMonth(),
                style: textTheme.labelSmall?.copyWith(height: 1, color: hebrewDayColor),
              ),
            ],
          ),
      },
    );
  }

  Widget _actions() {
    final localizations = MaterialLocalizations.of(context);
    final style = TextButton.styleFrom(foregroundColor: _primaryColor);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onCancel != null) ...[
            TextButton(
              style: style,
              onPressed: widget.onCancel,
              child: Text(widget.cancelText ?? localizations.cancelButtonLabel),
            ),
            const SizedBox(width: 8),
          ],
          TextButton(
            style: style,
            onPressed: () => widget.onConfirm(_selectedLocalDate),
            child: Text(widget.confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );
  }
}
