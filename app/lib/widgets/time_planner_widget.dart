import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/modeles/Shift.dart';
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
    String selectedCafeName =
        (Provider.of<CafeProvider>(context, listen: false).selectedCafe)!.name;
    final filteredShifts = shiftProvider.shifts
        .where((shift) => shift.cafeName == selectedCafeName)
        .toList();

    return ListView.builder(
      itemCount: filteredShifts.length,
      itemBuilder: (context, index) {
        final shift = filteredShifts[index];

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
                    children: dayShift.hours
                        .where((hourlyShift) => hourlyShift.staff.length > 0)
                        .map((hourlyShift) {
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
                              title: Text(staffMember.name),
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

  Widget _buildWeekView(ShiftProvider shiftProvider) {
    final tasks = <TimePlannerTask>[];
    String selectedCafeName =
        (Provider.of<CafeProvider>(context, listen: false).selectedCafe)!.name;

    // Prepare tasks for the TimePlanner widget, filtering for "Tore et fraction"
    final filteredShifts = shiftProvider.shifts
        .where((shift) => shift.cafeName == selectedCafeName)
        .toList();

    for (var shift in filteredShifts) {
      for (var entry in shift.shifts.entries) {
        final dayShift = entry.value;
        if (dayShift != null) {
          for (var hourlyShift in dayShift.hours) {
            if (hourlyShift.staff.length > 0) {
              // Check if staff length is greater than 0
              tasks.add(
                TimePlannerTask(
                  color: const Color.fromARGB(10, 33, 226, 243), // Task color
                  dateTime: TimePlannerDateTime(
                    day: _getDayIndex(entry.key),
                    hour: int.parse(hourlyShift.hourName.split(':')[0]),
                    minutes: int.parse(hourlyShift.hourName.split(':')[1]),
                  ),
                  minutesDuration: 60,
                  onTap: () {
                    // Navigate to the daily view with the selected day and hour
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyView(
                          dayName: entry.key,
                          hourName: hourlyShift.hourName,
                          hourlyShifts:
                              dayShift.hours, // Pass the list of hourly shifts
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildStaffCircles(hourlyShift.staff.length),
                      ),
                    ],
                  ),
                ),
              );
            }
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
        cellHeight: 80,
        cellWidth: 80,
        dividerColor: Colors.red[900],
        showScrollBar: true,
      ),
    );
  }

  // Update the method to build staff circles
  List<Widget> _buildStaffCircles(int staffCount) {
    // Define colors for the circles
    final colors = [
      Colors.blue,
      Colors.red[700],
      Colors.green[900],
    ];

    // Limit the number of circles to four
    final numCircles = staffCount > 4 ? 4 : staffCount;

    List<Widget> circles = [];

    for (int i = 0; i < numCircles; i++) {
      if (i < 3) {
        // Add only the first three colors
        circles.add(
          Container(
            margin: const EdgeInsets.all(2.0),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: colors[i], // Use the appropriate color based on the index
              shape: BoxShape.circle,
            ),
          ),
        );
      } else if (i == 3 && staffCount > 3) {
        // If there are more than three staff, add a plus icon
        circles.add(
          Container(
            margin: const EdgeInsets.all(2.0),
            width: 10,
            height: 10,
            child: Icon(
              Icons.add,
              size: 10, // Adjust the size of the icon
              color: Colors.black, // Color of the plus icon
            ),
          ),
        );
      }
    }

    return circles;
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
                Cafe? selectedCafe = cafeProvider.selectedCafe;
                final dayName = dayNameController.text;
                final hourName = hourNameController.text;
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                print(authProvider.username);

                Provider.of<ShiftProvider>(context, listen: false)
                    .addStaff(selectedCafe!.name, dayName, hourName,
                        authProvider.username!, authProvider.firstname!)
                    .then((_) {
                  Provider.of<ShiftProvider>(context, listen: false)
                      .fetchAllShifts();
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
                  Provider.of<ShiftProvider>(context, listen: false)
                      .fetchAllShifts();
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
                  Provider.of<ShiftProvider>(context, listen: false)
                      .fetchAllShifts();
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

class DailyView extends StatelessWidget {
  final String dayName;
  final String hourName;
  final List<HourlyShift> hourlyShifts;

  const DailyView({
    Key? key,
    required this.dayName,
    required this.hourName,
    required this.hourlyShifts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter hourly shifts to find the specific hour
    final filteredHourlyShifts = hourlyShifts
        .where((hourlyShift) => hourlyShift.hourName == hourName)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Horaire - $dayName at $hourName'),
      ),
      body: filteredHourlyShifts.isNotEmpty
          ? ListView.builder(
              itemCount: filteredHourlyShifts.length,
              itemBuilder: (context, index) {
                final hourlyShift = filteredHourlyShifts[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: hourlyShift.staff.map((staffMember) {
                    return Card(
                      color:
                          staffMember.set ? Colors.green[300] : Colors.black26,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(staffMember.name),
                        onTap: () {
                          _showShiftActionDialog(context, dayName, hourName,
                              staffMember.matricule);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            // Todo
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            )
          : const Center(child: Text('No shifts available for this hour.')),
    );
  }

  void _showShiftActionDialog(
      BuildContext context, String dayName, String hourName, String matricule) {
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Volunteer: $matricule'),
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
                  Provider.of<ShiftProvider>(context, listen: false)
                      .fetchAllShifts();
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
                  Provider.of<ShiftProvider>(context, listen: false)
                      .fetchAllShifts();
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
