import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:app/config.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:app/screens/side%20bar/side_bar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class Horaire extends StatefulWidget {
  const Horaire({super.key});

  @override
  State<Horaire> createState() => _HoraireState();
}

class _HoraireState extends State<Horaire> {
  final TextEditingController _eventTitleController = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pagesTitles_hourlyTitle),
        surfaceTintColor: Config.specialBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCalendar(
              view: CalendarView.month,
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.calendarCell) {
                  setState(() {
                    _selectedDate = details.date;
                    _startTime = null;
                    _endTime = null;
                  });
                }
              },
              // Todo add the event handling
            ),
          ),
          if (_selectedDate != null) ...[
            Text(
              'Selected Date: ${DateFormat.yMd().format(_selectedDate!)}',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _eventTitleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            ListTile(
              title: Text('Start Time'),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () async {
                  _startTime = await _selectTime(context);
                  setState(() {});
                },
              ),
              subtitle: Text(
                _startTime != null
                    ? DateFormat.jm().format(_startTime!)
                    : 'Select start time',
              ),
            ),
            ListTile(
              title: Text('End Time'),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () async {
                  _endTime = await _selectTime(context);
                  setState(() {}); // Refresh UI on time selection
                },
              ),
              subtitle: Text(
                _endTime != null
                    ? DateFormat.jm().format(_endTime!)
                    : 'Select end time',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedDate != null &&
                    _eventTitleController.text.isNotEmpty &&
                    _startTime != null &&
                    _endTime != null) {
                  // Todo

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Event Added'),
                      content: Text('Event: ${_eventTitleController.text}'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Add Event'),
            ),
          ],
        ],
      ),
    );
  }

  Future<DateTime?> _selectTime(BuildContext context) {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((TimeOfDay? time) {
      if (time != null) {
        final now = DateTime.now();
        return DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          time.hour,
          time.minute,
        );
      }
      return null;
    });
  }
}
