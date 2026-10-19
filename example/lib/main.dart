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

  bool _isSelectable(DateTime day) => !_disableSaturdays || day.weekday != DateTime.saturday;

  Future<void> _pickDate() async {
    final picked = await showHebrewDatePicker(
      context: context,
      // The initial date must be selectable.
      initialDate: _isSelectable(_date) ? _date : _date.add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      selectableDayPredicate: _isSelectable,
      showTodayButton: _showTodayButton,
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
              const SizedBox(height: 40),
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
