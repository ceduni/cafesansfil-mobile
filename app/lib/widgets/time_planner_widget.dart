import 'package:app/config.dart';
import 'package:app/modeles/Shift.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_planner/time_planner.dart';

class TimePlannerWidget extends StatefulWidget {
  TimePlannerWidget({super.key});

  @override
  State<TimePlannerWidget> createState() => _TimePlannerWidgetState();
}

class _TimePlannerWidgetState extends State<TimePlannerWidget> {
  final List<TimePlannerTask> tasks = [];
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  int _selectedDay = 0;
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  // New field to capture end time or duration
  TimeOfDay _endTime =
      TimeOfDay(hour: 10, minute: 0); // Default end time could be next hour
  int _duration = 60;

  @override
  void initState() {
    for (TimePlannerTask task
        in context.read<ShiftProvider>().shiftsToDisplay) {
      tasks.add(task);
    }
    super.initState();
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Create start time and end time
        DateTime now = DateTime.now();
        final startTime = DateTime(
            now.year, now.month, now.day, _startTime.hour, _startTime.minute);
        final endTime = DateTime(
            now.year, now.month, now.day, _endTime.hour, _endTime.minute);

        // Create a new ShiftDetail based on user input
        print('1');
        ShiftDetail newShiftDetail = ShiftDetail(
          date: startTime,
          startTime: '${_startTime.hour}:${_startTime.minute}',
          endTime: '${_endTime.hour}:${_endTime.minute}',
        );

        String matricule = "20099561";

        // Call provider method to add shift detail
        print('2');
        Provider.of<ShiftProvider>(context, listen: false)
            .addShiftDetail(matricule, newShiftDetail)
            .then((_) {
          setState(() {
            tasks.clear();
            tasks.addAll(Provider.of<ShiftProvider>(context, listen: false)
                .shiftsToDisplay);
          });
        });
        print('3');
      });
      _taskController.clear();
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimePlanner(
        startHour: 6,
        endHour: 22,
        headers: [
          TimePlannerTitle(title: "Lun"),
          TimePlannerTitle(title: "Mar"),
          TimePlannerTitle(title: "Mer"),
          TimePlannerTitle(title: "Jeu"),
          TimePlannerTitle(title: "Ven"),
          TimePlannerTitle(title: "Sam"),
          TimePlannerTitle(title: "Dim"),
        ],
        tasks: tasks,
        style: TimePlannerStyle(
          cellHeight: 70,
          cellWidth: 70,
          dividerColor: Colors.red[900],
          showScrollBar: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add Task'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _taskController,
                      decoration: InputDecoration(labelText: 'Task Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Day'),
                      value: _selectedDay,
                      items: List.generate(7, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text('Day ${index + 1}'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value!;
                        });
                      },
                    ),
                    // Start Time Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Start Time: ${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}"),
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () => _selectStartTime(context),
                        ),
                      ],
                    ),
                    // End Time Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "End Time: ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}"),
                        IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () => _selectEndTime(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
