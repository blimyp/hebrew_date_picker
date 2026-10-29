import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hebrew_date_picker/hebrew_date_picker.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hebrew Date Picker',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  DateTime _date = DateTime.now();
  DateTimeRange? _range;
  CalendarMode _calendarMode = CalendarMode.both;
  bool _disableSaturdays = false;
  bool _showTodayButton = false;
  _HolidayStyle _holidayStyle = _HolidayStyle.none;
  bool _outsideIsrael = false;

  bool _isSelectable(DateTime day) => !_disableSaturdays || day.weekday != DateTime.saturday;

  HebrewHolidays? get _holidays {
    final decoration = _holidayStyle.decoration(Theme.of(context).colorScheme);
    if (decoration == null) return null;
    return HebrewHolidays(decoration: decoration, inIsrael: !_outsideIsrael);
  }

  Future<void> _pickDate() async {
    final picked = await showHebrewDatePicker(
      context: context,
      // The initial date must be selectable.
      initialDate: _isSelectable(_date) ? _date : _date.add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      selectableDayPredicate: _isSelectable,
      showTodayButton: _showTodayButton,
      holidays: _holidays,
      calendarMode: _calendarMode,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickRange() async {
    final range = _range;
    final picked = await showHebrewDateRangePicker(
      context: context,
      // Both ends of the initial range must be selectable.
      initialDateRange:
          range != null && _isSelectable(range.start) && _isSelectable(range.end) ? range : null,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      selectableDayPredicate: _isSelectable,
      showTodayButton: _showTodayButton,
      holidays: _holidays,
      calendarMode: _calendarMode,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    final range = _range;
    return Scaffold(
      appBar: AppBar(title: const Text('Hebrew Date Picker')),
      // Centered when the content fits, scrollable when it doesn't.
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<CalendarMode>(
                segments: const [
                  ButtonSegment(value: CalendarMode.both, label: Text('Both')),
                  ButtonSegment(value: CalendarMode.hebrew, label: Text('Hebrew')),
                  ButtonSegment(value: CalendarMode.gregorian, label: Text('Gregorian')),
                ],
                selected: {_calendarMode},
                onSelectionChanged: (modes) => setState(() => _calendarMode = modes.first),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 280,
                child: SwitchListTile(
                  title: const Text('Disable Saturdays'),
                  value: _disableSaturdays,
                  onChanged: (value) => setState(() => _disableSaturdays = value),
                ),
              ),
              SizedBox(
                width: 280,
                child: SwitchListTile(
                  title: const Text('Show today button'),
                  value: _showTodayButton,
                  onChanged: (value) => setState(() => _showTodayButton = value),
                ),
              ),
              const SizedBox(height: 12),
              Text('Holidays', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<_HolidayStyle>(
                segments: [
                  for (final style in _HolidayStyle.values)
                    ButtonSegment(value: style, label: Text(style.label)),
                ],
                selected: {_holidayStyle},
                onSelectionChanged: (styles) => setState(() => _holidayStyle = styles.first),
              ),
              SizedBox(
                width: 280,
                child: SwitchListTile(
                  title: const Text('Outside Israel'),
                  value: _outsideIsrael,
                  onChanged: _holidayStyle == _HolidayStyle.none
                      ? null
                      : (value) => setState(() => _outsideIsrael = value),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(onPressed: _pickDate, child: const Text('Pick a date')),
              const SizedBox(height: 12),
              Text(localizations.formatFullDate(_date), style: textTheme.titleMedium),
              Text(_date.getHebrewDateFormatted(), style: textTheme.titleLarge),
              const SizedBox(height: 40),
              FilledButton(onPressed: _pickRange, child: const Text('Pick a date range')),
              if (range != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${localizations.formatMediumDate(range.start)} – '
                  '${localizations.formatMediumDate(range.end)}',
                  style: textTheme.titleMedium,
                ),
                Text(
                  '${range.start.getHebrewDateFormatted()} – ${range.end.getHebrewDateFormatted()}',
                  style: textTheme.titleLarge,
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: 360,
                child: HebrewDateFormField(
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  selectableDayPredicate: _isSelectable,
                  showTodayButton: _showTodayButton,
                  holidays: _holidays,
                  calendarMode: _calendarMode,
                  decoration: const InputDecoration(
                    labelText: 'Date field',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 360,
                child: HebrewDateRangeFormField(
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  selectableDayPredicate: _isSelectable,
                  showTodayButton: _showTodayButton,
                  holidays: _holidays,
                  calendarMode: _calendarMode,
                  decoration: const InputDecoration(
                    labelText: 'Date range field',
                    suffixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ways to mark the holidays: `HebrewHolidays.decoration` takes any [Decoration].
enum _HolidayStyle {
  none('None'),
  border('Border'),
  background('Background');

  const _HolidayStyle(this.label);

  final String label;

  /// Colors from the theme, so the marks match the picker.
  Decoration? decoration(ColorScheme colors) => switch (this) {
        none => null,
        border => _DashedCircleDecoration(color: colors.primary),
        background => BoxDecoration(shape: BoxShape.circle, color: colors.secondaryContainer),
      };
}

/// A dashed circle around the day, as an example of a custom [Decoration].
class _DashedCircleDecoration extends Decoration {
  const _DashedCircleDecoration({required this.color});

  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _DashedCirclePainter(color);
}

class _DashedCirclePainter extends BoxPainter {
  _DashedCirclePainter(this.color);

  final Color color;

  static const int _dashCount = 16;
  static const double _strokeWidth = 1.5;

  /// The share of each dash-and-gap step taken by the dash.
  static const double _dashRatio = 0.6;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size size = configuration.size!;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final rect = Rect.fromCircle(
      center: offset + size.center(Offset.zero),
      radius: (size.shortestSide - _strokeWidth) / 2,
    );
    const double step = 2 * math.pi / _dashCount;
    for (int i = 0; i < _dashCount; i++) {
      canvas.drawArc(rect, i * step, step * _dashRatio, false, paint);
    }
  }
}
