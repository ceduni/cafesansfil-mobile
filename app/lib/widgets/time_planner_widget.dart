import 'package:app/config.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_planner/time_planner.dart';

class TimePlannerWidget extends StatefulWidget {
  const TimePlannerWidget({super.key});

  @override
  State<TimePlannerWidget> createState() => _TimePlannerWidgetState();
}

class _TimePlannerWidgetState extends State<TimePlannerWidget> {
  bool isWeekView = false; // State variable to track the view type

  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);

    if (shiftProvider.shifts.isEmpty) {
      shiftProvider.fetchAllShifts();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isWeekView ? 'Vue semaine' : 'Vue jour'),
        actions: [
          IconButton(
            icon: Icon(isWeekView ? Icons.view_day : Icons.calendar_today),
            onPressed: () {
              setState(() {
                isWeekView = !isWeekView; // Toggle the view
              });
            },
          ),
        ],
      ),
      body: shiftProvider.shifts.isNotEmpty
          ? isWeekView
              ? _buildWeekView(
                  shiftProvider) // Use separate method for week view
              : _buildDailyView(
                  shiftProvider) // Use separate method for daily view
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStaffDialog(context);
        },
        tooltip: 'Add Staff',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Method to build daily view
  Widget _buildDailyView(ShiftProvider shiftProvider) {
    return ListView.builder(
      itemCount: shiftProvider.shifts.length,
      itemBuilder: (context, index) {
        final shift = shiftProvider.shifts[index];

        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...shift.shifts.entries.map((entry) {
                final dayShift = entry.value;
                if (dayShift != null) {
                  return ExpansionTile(
                    title: Text(
                      entry.key.capitalize(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: dayShift.hours.map((hourlyShift) {
                      return ExpansionTile(
                        title: Text(
                          '${hourlyShift.hourName} (${hourlyShift.staff.length})',
                        ),
                        children: hourlyShift.staff.map((staffMember) {
                          return Card(
                            color: staffMember.set
                                ? Colors.green[300]
                                : Colors.black26,
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              title: Text(staffMember.matricule),
                              onTap: () {
                                _showShiftActionDialog(
                                    context,
                                    shiftProvider,
                                    entry.key,
                                    hourlyShift.hourName,
                                    staffMember.matricule);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  );
                } else {
                  /*return ListTile(
                    title: Text('${entry.key.capitalize()} - Not a work day'),
                  );*/
                  // Return an empty widget if it's not a work day
                  return SizedBox.shrink();
                }
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Method to build week view using TimePlanner
  Widget _buildWeekView(ShiftProvider shiftProvider) {
    final tasks = <TimePlannerTask>[];

    // Prepare tasks for the TimePlanner widget
    for (var shift in shiftProvider.shifts) {
      for (var entry in shift.shifts.entries) {
        final dayShift = entry.value;
        if (dayShift != null) {
          for (var hourlyShift in dayShift.hours) {
            tasks.add(
              TimePlannerTask(
                color: Config.specialBlue,
                dateTime: TimePlannerDateTime(
                  day: _getDayIndex(entry.key),
                  hour: int.parse(hourlyShift.hourName.split(':')[0]),
                  minutes: int.parse(hourlyShift.hourName.split(':')[1]),
                ),
                minutesDuration: 60,
                child: Text(
                  hourlyShift.staff.map((s) => s.matricule).join('\n'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        }
      }
    }

    return TimePlanner(
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
        cellHeight: 150,
        cellWidth: 150,
        dividerColor: Colors.red[900],
        showScrollBar: true,
      ),
    );
  }

  // Helper function to map day names to index
  int _getDayIndex(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
        return 0;
      case 'tuesday':
        return 1;
      case 'wednesday':
        return 2;
      case 'thursday':
        return 3;
      case 'friday':
        return 4;
      case 'saturday':
        return 5;
      case 'sunday':
        return 6;
      default:
        return 0; // Default to Monday if the day name is unknown
    }
  }

  void _showAddStaffDialog(BuildContext context) {
    final cafeNameController = TextEditingController();
    final dayNameController = TextEditingController();
    final hourNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Staff Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayNameController,
                decoration: const InputDecoration(labelText: 'Day Name'),
              ),
              TextField(
                controller: hourNameController,
                decoration: const InputDecoration(labelText: 'Hour Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final cafeProvider =
                    Provider.of<CafeProvider>(context, listen: false);
                final dayName = dayNameController.text;
                final hourName = hourNameController.text;
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                print(authProvider.username);

                Provider.of<ShiftProvider>(context, listen: false)
                    .addStaff(cafeProvider.cafeName, dayName, hourName,
                        authProvider.username!)
                    .then((_) {
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showShiftActionDialog(BuildContext context, ShiftProvider shiftProvider,
      String dayName, String hourName, String matricule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Volunteer: ' + matricule),
          content: const Text('What would you like to do'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm Shift'),
              onPressed: () {
                shiftProvider
                    .confirmStaff(
                  shiftProvider.shifts[0].cafeName,
                  dayName,
                  hourName,
                  matricule,
                )
                    .then((_) {
                  Navigator.of(context).pop();
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text('Remove Shift'),
              onPressed: () {
                shiftProvider
                    .removeStaff(
                  shiftProvider.shifts[0].cafeName,
                  dayName,
                  hourName,
                  matricule,
                )
                    .then((_) {
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }
}
