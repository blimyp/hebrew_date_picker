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
      darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark),
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
  bool _markSaturdays = false;
  bool _outsideIsrael = false;

  bool _isSelectable(DateTime day) => !_disableSaturdays || day.weekday != DateTime.saturday;

  YomTovLocation get _yomTovLocation =>
      _outsideIsrael ? YomTovLocation.outsideIsrael : YomTovLocation.israel;

  /// Marks the Yamim Tovim in the chosen style, and Saturdays with a light background.
  Decoration? _decorateDay(HebrewDay day) {
    final colors = Theme.of(context).colorScheme;
    final holiday = day.isYomTov ? _holidayStyle.decoration(colors) : null;
    if (holiday != null) return holiday;
    if (_markSaturdays && day.date.weekday == DateTime.saturday) {
      return BoxDecoration(shape: BoxShape.circle, color: colors.tertiaryContainer);
    }
    return null;
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
      dayDecorationBuilder: _decorateDay,
      yomTovLocation: _yomTovLocation,
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
      dayDecorationBuilder: _decorateDay,
      yomTovLocation: _yomTovLocation,
      calendarMode: _calendarMode,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      _Section(
        title: 'Calendar',
        description: 'Which dates each day shows.',
        children: [
          _Segments<CalendarMode>(
            values: CalendarMode.values,
            labels: const {
              CalendarMode.both: 'Both',
              CalendarMode.hebrew: 'Hebrew',
              CalendarMode.gregorian: 'Gregorian',
            },
            selected: _calendarMode,
            onChanged: (mode) => setState(() => _calendarMode = mode),
          ),
          _SwitchTile(
            title: 'Show today button',
            parameter: 'showTodayButton',
            value: _showTodayButton,
            onChanged: (value) => setState(() => _showTodayButton = value),
          ),
        ],
      ),
      _Section(
        title: 'Saturdays',
        children: [
          _SwitchTile(
            title: 'Disable Saturdays',
            parameter: 'selectableDayPredicate',
            value: _disableSaturdays,
            onChanged: (value) => setState(() => _disableSaturdays = value),
          ),
          _SwitchTile(
            title: 'Mark Saturdays',
            parameter: 'dayDecorationBuilder',
            value: _markSaturdays,
            onChanged: (value) => setState(() => _markSaturdays = value),
          ),
        ],
      ),
      _Section(
        title: 'Holidays',
        description: 'Marked with dayDecorationBuilder, like any other day.',
        children: [
          _Segments<_HolidayStyle>(
            values: _HolidayStyle.values,
            labels: {for (final style in _HolidayStyle.values) style: style.label},
            selected: _holidayStyle,
            onChanged: (style) => setState(() => _holidayStyle = style),
          ),
          _SwitchTile(
            title: 'Outside Israel',
            parameter: 'yomTovLocation',
            value: _outsideIsrael,
            onChanged: (value) => setState(() => _outsideIsrael = value),
          ),
        ],
      ),
    ];

    final localizations = MaterialLocalizations.of(context);
    final range = _range;
    final demos = [
      _Section(
        title: 'Date picker',
        description: 'showHebrewDatePicker',
        children: [
          _Result(
            hebrew: _date.getHebrewDateFormatted(),
            gregorian: localizations.formatFullDate(_date),
          ),
          _PickButton(icon: Icons.event, label: 'Pick a date', onPressed: _pickDate),
        ],
      ),
      _Section(
        title: 'Date range picker',
        description: 'showHebrewDateRangePicker',
        children: [
          if (range == null)
            const _Result(gregorian: 'No range selected')
          else
            _Result(
              hebrew: '${range.start.getHebrewDateFormatted()} – '
                  '${range.end.getHebrewDateFormatted()}',
              gregorian: '${localizations.formatMediumDate(range.start)} – '
                  '${localizations.formatMediumDate(range.end)}',
            ),
          _PickButton(icon: Icons.date_range, label: 'Pick a date range', onPressed: _pickRange),
        ],
      ),
      _Section(
        title: 'Form fields',
        description: 'HebrewDateFormField · HebrewDateRangeFormField',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                HebrewDateFormField(
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  selectableDayPredicate: _isSelectable,
                  showTodayButton: _showTodayButton,
                  dayDecorationBuilder: _decorateDay,
                  yomTovLocation: _yomTovLocation,
                  calendarMode: _calendarMode,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                HebrewDateRangeFormField(
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  selectableDayPredicate: _isSelectable,
                  showTodayButton: _showTodayButton,
                  dayDecorationBuilder: _decorateDay,
                  yomTovLocation: _yomTovLocation,
                  calendarMode: _calendarMode,
                  decoration: const InputDecoration(
                    labelText: 'Date range',
                    suffixIcon: Icon(Icons.date_range),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Hebrew Date Picker')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // The options beside the demos on wide screens, below them on narrow ones.
          final bool wide = constraints.maxWidth >= 840;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1000 : 560),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _Group(title: 'Try it', children: demos)),
                          const SizedBox(width: 24),
                          Expanded(child: _Group(title: 'Options', children: options)),
                        ],
                      )
                    : Column(
                        children: [
                          _Group(title: 'Try it', children: demos),
                          const SizedBox(height: 24),
                          _Group(title: 'Options', children: options),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A titled column of sections.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary, letterSpacing: 1.2),
          ),
        ),
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(height: 12),
          child,
        ],
      ],
    );
  }
}

/// A card with a title, an optional description and its content.
class _Section extends StatelessWidget {
  const _Section({required this.title, this.description, required this.children});

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = this.description;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  if (description != null)
                    Text(
                      description,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A full-width segmented button with one choice selected.
class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final Map<T, String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SegmentedButton<T>(
        expandedInsets: EdgeInsets.zero,
        showSelectedIcon: false,
        segments: [
          for (final value in values) ButtonSegment(value: value, label: Text(labels[value]!)),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}

/// A switch labelled with the picker parameter it drives.
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.parameter,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String parameter;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        parameter,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// The picked value in both calendars.
class _Result extends StatelessWidget {
  const _Result({this.hebrew, required this.gregorian});

  final String? hebrew;
  final String gregorian;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hebrew = this.hebrew;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (hebrew != null)
            Text(hebrew, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          Text(
            gregorian,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  const _PickButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}

/// Ways to mark the holidays: `dayDecorationBuilder` returns any [Decoration].
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
