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
  DayMode _dayMode = DayMode.both;

  Future<void> _pickDate() async {
    final picked = await showHebrewDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      dayMode: _dayMode,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hebrew Date Picker')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(MaterialLocalizations.of(context).formatFullDate(_date),
                style: textTheme.titleMedium),
            Text(_date.getHebrewDateFormatted(), style: textTheme.titleLarge),
            const SizedBox(height: 24),
            SegmentedButton<DayMode>(
              segments: const [
                ButtonSegment(value: DayMode.both, label: Text('Both')),
                ButtonSegment(value: DayMode.hebrew, label: Text('Hebrew')),
                ButtonSegment(value: DayMode.gregorian, label: Text('Gregorian')),
              ],
              selected: {_dayMode},
              onSelectionChanged: (modes) => setState(() => _dayMode = modes.first),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _pickDate, child: const Text('Pick a date')),
          ],
        ),
      ),
    );
  }
}
