import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'day_mode.dart';
import 'hebrew_date_extension.dart';
import 'hebrew_month.dart';

/// Shows a Material-style dialog with a [HebrewDatePicker].
///
/// Completes with the selected date (time stripped), or null if the picker was canceled
/// or dismissed.
Future<DateTime?> showHebrewDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  SelectableDayPredicate? selectableDayPredicate,
  DayMode dayMode = DayMode.both,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  bool showTodayButton = false,
  String? locale,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? todayText,
  Color? primaryColor,
  Color? secondaryTextColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  return _showPickerDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => HebrewDatePicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      dayMode: dayMode,
      initialDatePickerMode: initialDatePickerMode,
      showTodayButton: showTodayButton,
      locale: locale,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      todayText: todayText,
      primaryColor: primaryColor,
      secondaryTextColor: secondaryTextColor,
      onCancel: () => Navigator.of(dialogContext).pop(),
      onConfirm: (date) => Navigator.of(dialogContext).pop(date),
    ),
  );
}

/// Shows a Material-style dialog with a [HebrewDateRangePicker].
///
/// Completes with the selected range (times stripped), or null if the picker was canceled
/// or dismissed.
Future<DateTimeRange?> showHebrewDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
  SelectableDayPredicate? selectableDayPredicate,
  DayMode dayMode = DayMode.both,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  bool showTodayButton = false,
  String? locale,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? todayText,
  Color? primaryColor,
  Color? secondaryTextColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  return _showPickerDialog<DateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => HebrewDateRangePicker(
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      dayMode: dayMode,
      initialDatePickerMode: initialDatePickerMode,
      showTodayButton: showTodayButton,
      locale: locale,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      todayText: todayText,
      primaryColor: primaryColor,
      secondaryTextColor: secondaryTextColor,
      onCancel: () => Navigator.of(dialogContext).pop(),
      onConfirm: (range) => Navigator.of(dialogContext).pop(range),
    ),
  );
}

Future<T?> _showPickerDialog<T>({
  required BuildContext context,
  required bool barrierDismissible,
  required bool useRootNavigator,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(child: builder(dialogContext)),
      ),
    ),
  );
}

/// Date picker styled like the Material one, with the Hebrew date shown in every day cell,
/// the Hebrew months in the month title and the full Hebrew date of the selected day.
///
/// Use [showHebrewDatePicker] to open it in a dialog, or embed it in your own container.
/// To pick a range of dates, use [HebrewDateRangePicker].
class HebrewDatePicker extends StatelessWidget {
  const HebrewDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
    required this.onConfirm,
    this.onCancel,
    this.onDateChanged,
    this.dayMode = DayMode.both,
    this.initialDatePickerMode = DatePickerMode.day,
    this.showTodayButton = false,
    this.locale,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.todayText,
    this.primaryColor,
    this.secondaryTextColor,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Decides which days can be selected; days for which it returns false are shown disabled.
  /// It is called with dates without a time. [initialDate] must satisfy it.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Called with the selected date (time stripped) when the confirm button is pressed.
  final ValueChanged<DateTime> onConfirm;

  /// Called when the cancel button is pressed. The cancel button is hidden when null.
  final VoidCallback? onCancel;

  /// Called whenever a day is tapped, before confirmation.
  final ValueChanged<DateTime>? onDateChanged;

  /// What each day cell shows: the Gregorian day, the Hebrew day or both (the default).
  /// With [DayMode.hebrew] the calendar pages by Hebrew months and the year grid shows
  /// Hebrew years.
  final DayMode dayMode;

  /// Whether the picker opens on the month calendar (the default) or on the year grid.
  /// Tapping the month title switches between the two.
  final DatePickerMode initialDatePickerMode;

  /// Whether to show a button that jumps to today and selects it. It is disabled when today
  /// is outside [firstDate]–[lastDate] or isn't selectable. Defaults to false.
  final bool showTodayButton;

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

  /// Label of the today button. Defaults to [MaterialLocalizations.currentDateLabel].
  final String? todayText;

  /// Color of the header, the selected day and the buttons. Defaults to [ColorScheme.primary].
  final Color? primaryColor;

  /// Color of secondary texts (weekday names, Hebrew months).
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    return _CalendarPicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      onConfirmDate: onConfirm,
      onCancel: onCancel,
      onDateChanged: onDateChanged,
      dayMode: dayMode,
      initialDatePickerMode: initialDatePickerMode,
      showTodayButton: showTodayButton,
      locale: locale,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      todayText: todayText,
      primaryColor: primaryColor,
      secondaryTextColor: secondaryTextColor,
    );
  }
}

/// Date range picker styled like the Material one, with the Hebrew date shown in every day
/// cell, the Hebrew months in the month title and the full Hebrew dates of the selected range.
///
/// The first tap picks the start of the range and the second tap picks its end (or a new
/// start, if it is before the current one). A range may start and end on the same day.
///
/// Use [showHebrewDateRangePicker] to open it in a dialog, or embed it in your own container.
class HebrewDateRangePicker extends StatelessWidget {
  const HebrewDateRangePicker({
    super.key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
    required this.onConfirm,
    this.onCancel,
    this.onDateRangeChanged,
    this.dayMode = DayMode.both,
    this.initialDatePickerMode = DatePickerMode.day,
    this.showTodayButton = false,
    this.locale,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.todayText,
    this.primaryColor,
    this.secondaryTextColor,
  });

  /// The range selected when the picker opens. When null, no range is selected and the
  /// calendar opens on the current month.
  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Decides which days can be selected as the start or the end of the range; days for which
  /// it returns false are shown disabled, but a range may span them. It is called with dates
  /// without a time. Both ends of [initialDateRange] must satisfy it.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Called with the selected range (times stripped) when the confirm button is pressed.
  /// The confirm button is disabled until both ends of the range are selected.
  final ValueChanged<DateTimeRange> onConfirm;

  /// Called when the cancel button is pressed. The cancel button is hidden when null.
  final VoidCallback? onCancel;

  /// Called whenever a complete range is tapped, before confirmation.
  final ValueChanged<DateTimeRange>? onDateRangeChanged;

  /// What each day cell shows: the Gregorian day, the Hebrew day or both (the default).
  /// With [DayMode.hebrew] the calendar pages by Hebrew months and the year grid shows
  /// Hebrew years.
  final DayMode dayMode;

  /// Whether the picker opens on the month calendar (the default) or on the year grid.
  /// Tapping the month title switches between the two.
  final DatePickerMode initialDatePickerMode;

  /// Whether to show a button that jumps to today and selects it. It is disabled when today
  /// is outside [firstDate]–[lastDate] or isn't selectable. Defaults to false.
  final bool showTodayButton;

  /// Locale used for the Gregorian month title and weekday names, e.g. 'he' or 'en_US'.
  /// Locales other than en_US require date formatting data to be initialized (for example
  /// via `flutter_localizations` or `initializeDateFormatting`).
  final String? locale;

  /// Defaults to [MaterialLocalizations.dateRangePickerHelpText].
  final String? helpText;

  /// Defaults to [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Defaults to [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Label of the today button. Defaults to [MaterialLocalizations.currentDateLabel].
  final String? todayText;

  /// Color of the header, the range ends, the range highlight and the buttons.
  /// Defaults to [ColorScheme.primary].
  final Color? primaryColor;

  /// Color of secondary texts (weekday names, Hebrew months).
  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? secondaryTextColor;

  @override
  Widget build(BuildContext context) {
    return _CalendarPicker(
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: selectableDayPredicate,
      onConfirmRange: onConfirm,
      onCancel: onCancel,
      onDateRangeChanged: onDateRangeChanged,
      dayMode: dayMode,
      initialDatePickerMode: initialDatePickerMode,
      showTodayButton: showTodayButton,
      locale: locale,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      todayText: todayText,
      primaryColor: primaryColor,
      secondaryTextColor: secondaryTextColor,
    );
  }
}

/// The picker behind [HebrewDatePicker] and [HebrewDateRangePicker]. It selects a range when
/// [onConfirmRange] is set and a single date otherwise.
class _CalendarPicker extends StatefulWidget {
  const _CalendarPicker({
    this.initialDate,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    this.selectableDayPredicate,
    this.onConfirmDate,
    this.onConfirmRange,
    this.onCancel,
    this.onDateChanged,
    this.onDateRangeChanged,
    required this.dayMode,
    required this.initialDatePickerMode,
    required this.showTodayButton,
    this.locale,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.todayText,
    this.primaryColor,
    this.secondaryTextColor,
  }) : assert((onConfirmDate == null) != (onConfirmRange == null));

  final DateTime? initialDate;
  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final ValueChanged<DateTime>? onConfirmDate;
  final ValueChanged<DateTimeRange>? onConfirmRange;
  final VoidCallback? onCancel;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<DateTimeRange>? onDateRangeChanged;
  final DayMode dayMode;
  final DatePickerMode initialDatePickerMode;
  final bool showTodayButton;
  final String? locale;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;
  final String? todayText;
  final Color? primaryColor;
  final Color? secondaryTextColor;

  bool get rangeSelection => onConfirmRange != null;

  @override
  State<_CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<_CalendarPicker> {
  late final DateTime _firstDay = _dateOnly(widget.firstDate);
  late final DateTime _lastDay = _dateOnly(widget.lastDate);
  late DateTime _selectedDay = _clamp(_dateOnly(widget.initialDate ?? DateTime.now()));
  late DateTime? _rangeStart = _initialRangeDay(widget.initialDateRange?.start);
  late DateTime? _rangeEnd = _initialRangeDay(widget.initialDateRange?.end);
  late DateTime _focusedDay = _rangeStart ?? _selectedDay;
  late DatePickerMode _mode = widget.initialDatePickerMode;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    if (widget.rangeSelection) {
      assert(
        _rangeStart == null || _isSelectable(_rangeStart!),
        'initialDateRange.start must satisfy selectableDayPredicate.',
      );
      assert(
        _rangeEnd == null || _isSelectable(_rangeEnd!),
        'initialDateRange.end must satisfy selectableDayPredicate.',
      );
    } else {
      assert(_isSelectable(_selectedDay), 'initialDate must satisfy selectableDayPredicate.');
    }
  }

  static const double _rowHeight = 54;
  static const double _daysOfWeekHeight = 32;
  static const double _yearRowHeight = 52;
  static const int _yearsPerRow = 3;
  static const double _dayCellSize = 44;

  // TableCalendar uses a LayoutBuilder, which can't report intrinsic dimensions, so the
  // calendar gets a fixed height (six week rows) and the month title is built outside of
  // it - this lets the picker live inside containers that measure their content intrinsically.
  static const double _calendarHeight = _daysOfWeekHeight + 6 * _rowHeight;

  DateTime _dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day);

  DateTime? _initialRangeDay(DateTime? date) => date == null ? null : _clamp(_dateOnly(date));

  DateTime _clamp(DateTime day) {
    if (day.isBefore(_firstDay)) return _firstDay;
    if (day.isAfter(_lastDay)) return _lastDay;
    return day;
  }

  DateTime _localDate(DateTime day) => DateTime(day.year, day.month, day.day);

  bool _isSelectable(DateTime day) => widget.selectableDayPredicate?.call(_localDate(day)) ?? true;

  DateTime get _selectedLocalDate => _localDate(_selectedDay);

  DateTimeRange? get _selectedRange => _rangeStart == null || _rangeEnd == null
      ? null
      : DateTimeRange(start: _localDate(_rangeStart!), end: _localDate(_rangeEnd!));

  /// The year highlighted in the year grid: the selected one, or in range mode the
  /// displayed one.
  int get _activeYear => _yearOf(widget.rangeSelection ? _focusedDay : _selectedDay);

  /// Whether the calendar pages by Hebrew months and the year grid lists Hebrew years.
  bool get _hebrewMonths => widget.dayMode == DayMode.hebrew;

  /// The year of [day] that the year grid lists: the Hebrew one when paging by Hebrew months.
  int _yearOf(DateTime day) => _hebrewMonths ? HebrewMonth.of(day).year : day.year;

  Color get _primaryColor => widget.primaryColor ?? Theme.of(context).colorScheme.primary;

  Color get _onPrimaryColor =>
      ThemeData.estimateBrightnessForColor(_primaryColor) == Brightness.dark
          ? Colors.white
          : Colors.black;

  Color get _rangeHighlightColor => _primaryColor.withAlpha(0x33);

  Color get _textColor => Theme.of(context).colorScheme.onSurface;

  Color get _secondaryTextColor =>
      widget.secondaryTextColor ?? Theme.of(context).colorScheme.onSurfaceVariant;

  /// Like the Material date picker: the text color at 38% opacity.
  Color get _disabledTextColor => _textColor.withAlpha(0x61);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.rangeSelection ? _selectedRangeHeader() : _selectedDateHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _monthTitle(),
              const SizedBox(height: 8),
              SizedBox(
                height: _calendarHeight,
                child: _mode == DatePickerMode.year
                    ? _yearGrid()
                    : (_hebrewMonths ? _hebrewCalendar() : _tableCalendar()),
              ),
              _actions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header({required String helpText, required String title, String? hebrewTitle}) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: _primaryColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(helpText, style: textTheme.labelMedium?.copyWith(color: _onPrimaryColor)),
          const SizedBox(height: 16),
          Text(title, style: textTheme.headlineSmall?.copyWith(color: _onPrimaryColor)),
          // Keeps the header height while the Hebrew line is empty.
          Text(
            hebrewTitle ?? '',
            style: textTheme.bodyMedium?.copyWith(color: _onPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _selectedDateHeader() {
    final localizations = MaterialLocalizations.of(context);
    return _header(
      helpText: widget.helpText ?? localizations.datePickerHelpText,
      title: localizations.formatMediumDate(_selectedLocalDate),
      hebrewTitle: _selectedDay.getHebrewDateFormatted(),
    );
  }

  Widget _selectedRangeHeader() {
    final localizations = MaterialLocalizations.of(context);
    // Like the Material range picker: the short month and day in the current year, the short
    // numeric date otherwise.
    String format(DateTime day) => day.year == DateTime.now().year
        ? localizations.formatShortMonthDay(_localDate(day))
        : localizations.formatShortDate(_localDate(day));
    final start = _rangeStart;
    final end = _rangeEnd;
    return _header(
      helpText: widget.helpText ?? localizations.dateRangePickerHelpText,
      title: '${start == null ? localizations.dateRangeStartLabel : format(start)} – '
          '${end == null ? localizations.dateRangeEndLabel : format(end)}',
      hebrewTitle: start == null
          ? null
          : end == null
              ? start.getHebrewDateFormatted()
              : '${start.getHebrewDateFormatted()} – ${end.getHebrewDateFormatted()}',
    );
  }

  /// The Gregorian months covered by a Hebrew month, e.g. "Sep – Oct 2026".
  String _gregorianMonthsOf(HebrewMonth month) {
    final first = month.firstDay;
    final last = month.lastDay;
    final locale = widget.locale;
    if (first.year != last.year) {
      return '${DateFormat.yMMM(locale).format(first)} – ${DateFormat.yMMM(locale).format(last)}';
    }
    if (first.month == last.month) return DateFormat.yMMM(locale).format(first);
    return '${DateFormat.MMM(locale).format(first)} – ${DateFormat.yMMM(locale).format(last)}';
  }

  Widget _monthTitle() {
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    final bool yearMode = _mode == DatePickerMode.year;
    final HebrewMonth? hebrewMonth = _hebrewMonths ? HebrewMonth.of(_focusedDay) : null;
    return ConstrainedBox(
      // Keeps the same height when the month arrows are hidden in year mode.
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Semantics(
                button: true,
                label: localizations.selectYearSemanticsLabel,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () =>
                      setState(() => _mode = yearMode ? DatePickerMode.day : DatePickerMode.year),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hebrewMonth?.title ??
                                    DateFormat.yMMMM(widget.locale).format(_focusedDay),
                                style: textTheme.titleSmall?.copyWith(color: _textColor),
                              ),
                              Text(
                                hebrewMonth == null
                                    ? _focusedDay.getHebrewMonthsOfMonth()
                                    : _gregorianMonthsOf(hebrewMonth),
                                style: textTheme.bodySmall?.copyWith(color: _secondaryTextColor),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          yearMode ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: _secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!yearMode) ...[
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
        ],
      ),
    );
  }

  Widget _yearGrid() {
    final int firstYear = _yearOf(_firstDay);
    final int yearCount = _yearOf(_lastDay) - firstYear + 1;
    // Scroll so the active year's row is roughly centered.
    final int selectedRow = (_activeYear - firstYear) ~/ _yearsPerRow;
    final double contentHeight = (yearCount / _yearsPerRow).ceil() * _yearRowHeight;
    final double maxOffset = (contentHeight - _calendarHeight).clamp(0, double.infinity);
    final double offset =
        (selectedRow * _yearRowHeight - (_calendarHeight - _yearRowHeight) / 2).clamp(0, maxOffset);
    return _YearGrid(
      initialScrollOffset: offset,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _yearsPerRow,
        mainAxisExtent: _yearRowHeight,
      ),
      itemCount: yearCount,
      itemBuilder: (context, index) => _yearCell(firstYear + index),
    );
  }

  Widget _yearCell(int year) {
    final textTheme = Theme.of(context).textTheme;
    final bool selected = year == _activeYear;
    final bool current = year == _yearOf(DateTime.now());
    final Color color = selected ? _onPrimaryColor : (current ? _primaryColor : _textColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: selected ? _primaryColor : Colors.transparent,
        shape: StadiumBorder(
          side: current && !selected ? BorderSide(color: _primaryColor) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onYearSelected(year),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _hebrewMonths ? HebrewMonth.formatYear(year) : '$year',
                style: textTheme.bodyMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold, height: 1.1),
              ),
              Text(
                _hebrewMonths
                    ? HebrewMonth.gregorianYearsOf(year)
                    : DateTime(year).getHebrewYearsOfYear(),
                style: textTheme.labelSmall?.copyWith(
                  color: selected ? _onPrimaryColor : _secondaryTextColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Moves the selection to the same day and displayed month in [year], like the Material
  /// date picker, and goes back to the month calendar. In range mode, or when that day isn't
  /// selectable, only the displayed month moves, so the selection is kept. When paging by
  /// Hebrew months, [year] is a Hebrew year and the day and month are the Hebrew ones.
  void _onYearSelected(int year) {
    final DateTime newDay;
    final DateTime monthStart;
    if (_hebrewMonths) {
      final month = HebrewMonth.inYear(year, HebrewMonth.of(_focusedDay).month);
      final selectedMonth = HebrewMonth.of(_selectedDay);
      final int day =
          (_selectedDay.difference(selectedMonth.firstDay).inDays + 1).clamp(1, month.length);
      newDay = _clamp(month.day(day));
      monthStart = _clamp(month.firstDay);
    } else {
      final int month = _focusedDay.month;
      final int day = _selectedDay.day.clamp(1, DateUtils.getDaysInMonth(year, month));
      newDay = _clamp(DateTime.utc(year, month, day));
      monthStart = _clamp(DateTime.utc(year, month, 1));
    }
    if (widget.rangeSelection || !_isSelectable(newDay)) {
      setState(() {
        _focusedDay = monthStart;
        _mode = DatePickerMode.day;
      });
      return;
    }
    setState(() {
      _selectedDay = newDay;
      _focusedDay = _selectedDay;
      _mode = DatePickerMode.day;
    });
    widget.onDateChanged?.call(_selectedLocalDate);
  }

  void _onDayTapped(DateTime day) {
    _focusedDay = day;
    if (widget.rangeSelection) {
      _onRangeDayTapped(day);
      return;
    }
    setState(() => _selectedDay = day);
    widget.onDateChanged?.call(_selectedLocalDate);
  }

  /// Like the Material range picker: a tap starts a new range unless only its start is
  /// selected, in which case it sets the end - or moves the start, if it's before it.
  void _onRangeDayTapped(DateTime day) {
    final start = _rangeStart;
    setState(() {
      if (start == null || _rangeEnd != null || day.isBefore(start)) {
        _rangeStart = day;
        _rangeEnd = null;
      } else {
        _rangeEnd = day;
      }
    });
    final range = _selectedRange;
    if (range != null) widget.onDateRangeChanged?.call(range);
  }

  Widget _tableCalendar() {
    final weekdayStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(color: _secondaryTextColor);
    final bool range = widget.rangeSelection;
    return TableCalendar(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      locale: widget.locale,
      headerVisible: false,
      sixWeekMonthsEnforced: true,
      daysOfWeekHeight: _daysOfWeekHeight,
      rowHeight: _rowHeight,
      enabledDayPredicate: widget.selectableDayPredicate == null ? null : _isSelectable,
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
      // Range taps are handled here rather than by TableCalendar's own range selection, which
      // doesn't allow a range that starts and ends on the same day.
      selectedDayPredicate: range ? null : (day) => isSameDay(day, _selectedDay),
      rangeStartDay: range ? _rangeStart : null,
      rangeEndDay: range ? _rangeEnd : null,
      onDaySelected: (selectedDay, focusedDay) => _onDayTapped(selectedDay),
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _dayCell(day),
        todayBuilder: (context, day, focusedDay) => _dayCell(day, today: true),
        disabledBuilder: (context, day, focusedDay) =>
            _dayCell(day, enabled: false, today: isSameDay(day, DateTime.now())),
        selectedBuilder: (context, day, focusedDay) => _dayCell(day, selected: true),
        rangeStartBuilder: (context, day, focusedDay) => _dayCell(day, selected: true),
        rangeEndBuilder: (context, day, focusedDay) => _dayCell(day, selected: true),
        withinRangeBuilder: (context, day, focusedDay) => _dayCell(day),
        rangeHighlightBuilder: (context, day, isWithinRange) =>
            isWithinRange ? _rangeHighlight(day) : null,
      ),
    );
  }

  /// The month calendar when paging by Hebrew months, which TableCalendar can't do. It looks
  /// and behaves like [_tableCalendar].
  Widget _hebrewCalendar() {
    return _HebrewMonthCalendar(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      locale: widget.locale,
      daysOfWeekHeight: _daysOfWeekHeight,
      rowHeight: _rowHeight,
      weekdayStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: _secondaryTextColor),
      onCalendarCreated: (pageController) => _pageController = pageController,
      onPageChanged: (month) => setState(() => _focusedDay = _clamp(month.firstDay)),
      dayBuilder: _hebrewCalendarDay,
    );
  }

  Widget _hebrewCalendarDay(DateTime day) {
    final bool enabled = !day.isBefore(_firstDay) && !day.isAfter(_lastDay) && _isSelectable(day);
    final bool range = widget.rangeSelection;
    final start = _rangeStart;
    final end = _rangeEnd;
    final bool selected =
        range ? isSameDay(day, start) || isSameDay(day, end) : isSameDay(day, _selectedDay);
    final bool withinRange =
        range && start != null && end != null && !day.isBefore(start) && !day.isAfter(end);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => _onDayTapped(day) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (withinRange) Positioned.fill(child: _rangeHighlight(day)),
          _dayCell(
            day,
            enabled: enabled,
            selected: selected,
            today: isSameDay(day, DateTime.now()),
          ),
        ],
      ),
    );
  }

  /// The band behind the days of the range, which starts and ends in the middle of the
  /// range's first and last day.
  Widget _rangeHighlight(DateTime day) {
    Widget half(bool visible) => Expanded(
          child: visible
              ? Container(height: _dayCellSize, color: _rangeHighlightColor)
              : const SizedBox.shrink(),
        );
    return Row(
      children: [
        half(!isSameDay(day, _rangeStart)),
        half(!isSameDay(day, _rangeEnd)),
      ],
    );
  }

  Widget _dayCell(DateTime day, {bool enabled = true, bool selected = false, bool today = false}) {
    final textTheme = Theme.of(context).textTheme;
    final Color dayColor = selected
        ? _onPrimaryColor
        : (!enabled ? _disabledTextColor : (today ? _primaryColor : _textColor));
    final Color hebrewDayColor =
        selected ? _onPrimaryColor : (enabled ? _textColor : _disabledTextColor);
    final TextStyle? mainStyle = textTheme.bodyMedium?.copyWith(
      color: dayColor,
      fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
      height: 1.1,
    );
    return Container(
      width: _dayCellSize,
      height: _dayCellSize,
      decoration: BoxDecoration(
        color: selected ? _primaryColor : null,
        border: today && !selected
            ? Border.all(color: enabled ? _primaryColor : _disabledTextColor)
            : null,
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

  bool get _canSelectToday {
    final today = _dateOnly(DateTime.now());
    return !today.isBefore(_firstDay) && !today.isAfter(_lastDay) && _isSelectable(today);
  }

  /// Shows today's month and selects today - in range mode, as the start of a new range.
  void _selectToday() {
    final today = _dateOnly(DateTime.now());
    setState(() {
      _focusedDay = today;
      _mode = DatePickerMode.day;
      if (widget.rangeSelection) {
        _rangeStart = today;
        _rangeEnd = null;
      } else {
        _selectedDay = today;
      }
    });
    if (!widget.rangeSelection) widget.onDateChanged?.call(_selectedLocalDate);
  }

  void _confirm() {
    final onConfirmRange = widget.onConfirmRange;
    if (onConfirmRange != null) {
      onConfirmRange(_selectedRange!);
    } else {
      widget.onConfirmDate!(_selectedLocalDate);
    }
  }

  Widget _actions() {
    final localizations = MaterialLocalizations.of(context);
    final style = TextButton.styleFrom(foregroundColor: _primaryColor);
    final bool canConfirm = !widget.rangeSelection || _selectedRange != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.showTodayButton) ...[
            TextButton(
              style: style,
              onPressed: _canSelectToday ? _selectToday : null,
              child: Text(widget.todayText ?? localizations.currentDateLabel),
            ),
            const Spacer(),
          ],
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
            onPressed: canConfirm ? _confirm : null,
            child: Text(widget.confirmText ?? localizations.okButtonLabel),
          ),
        ],
      ),
    );
  }
}

/// A paged month calendar whose months are Hebrew months, with a row of weekday names and six
/// week rows starting on Sunday, like the TableCalendar used for Gregorian months.
class _HebrewMonthCalendar extends StatefulWidget {
  const _HebrewMonthCalendar({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.locale,
    required this.daysOfWeekHeight,
    required this.rowHeight,
    required this.weekdayStyle,
    required this.onCalendarCreated,
    required this.onPageChanged,
    required this.dayBuilder,
  });

  final DateTime firstDay;
  final DateTime lastDay;

  /// A day in the displayed month. The calendar jumps to its month when it changes.
  final DateTime focusedDay;
  final String? locale;
  final double daysOfWeekHeight;
  final double rowHeight;
  final TextStyle weekdayStyle;
  final ValueChanged<PageController> onCalendarCreated;
  final ValueChanged<HebrewMonth> onPageChanged;

  /// Builds the cell of a day of the displayed month.
  final Widget Function(DateTime day) dayBuilder;

  @override
  State<_HebrewMonthCalendar> createState() => _HebrewMonthCalendarState();
}

class _HebrewMonthCalendarState extends State<_HebrewMonthCalendar> {
  late final int _firstIndex = HebrewMonth.of(widget.firstDay).index;
  late int _page = _pageOf(widget.focusedDay);
  late final PageController _controller = PageController(initialPage: _page);

  int _pageOf(DateTime day) => HebrewMonth.of(day).index - _firstIndex;

  @override
  void initState() {
    super.initState();
    widget.onCalendarCreated(_controller);
  }

  @override
  void didUpdateWidget(_HebrewMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int page = _pageOf(widget.focusedDay);
    if (page != _page) {
      _page = page;
      _controller.jumpToPage(page);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekdayFormat = DateFormat.EEEEE(widget.locale);
    return Column(
      children: [
        SizedBox(
          height: widget.daysOfWeekHeight,
          child: Row(
            children: [
              // 1 Jan 2023 is a Sunday.
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      weekdayFormat.format(DateTime(2023, 1, 1 + i)),
                      style: widget.weekdayStyle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: HebrewMonth.of(widget.lastDay).index - _firstIndex + 1,
            onPageChanged: (page) {
              _page = page;
              widget.onPageChanged(HebrewMonth.fromIndex(_firstIndex + page));
            },
            itemBuilder: (context, page) => _month(HebrewMonth.fromIndex(_firstIndex + page)),
          ),
        ),
      ],
    );
  }

  Widget _month(HebrewMonth month) {
    final DateTime firstDay = month.firstDay;
    final int length = month.length;
    // The empty cells before the first day; DateTime.sunday is 7.
    final int offset = firstDay.weekday % 7;
    return Column(
      children: [
        for (int row = 0; row < 6; row++)
          SizedBox(
            height: widget.rowHeight,
            child: Row(
              children: [
                for (int column = 0; column < 7; column++)
                  Expanded(
                    child: switch (row * 7 + column - offset) {
                      final int i when i >= 0 && i < length =>
                        widget.dayBuilder(firstDay.add(Duration(days: i))),
                      _ => const SizedBox.shrink(),
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Scrollable year grid that owns its [ScrollController], so the initial scroll position is
/// applied once when the grid opens.
class _YearGrid extends StatefulWidget {
  const _YearGrid({
    required this.initialScrollOffset,
    required this.gridDelegate,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double initialScrollOffset;
  final SliverGridDelegate gridDelegate;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  State<_YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<_YearGrid> {
  late final ScrollController _controller =
      ScrollController(initialScrollOffset: widget.initialScrollOffset);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _controller,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
    );
  }
}
