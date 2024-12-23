import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/modeles/Shift.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_planner/time_planner.dart';
import 'package:intl/intl.dart';

class TimePlannerWidget extends StatefulWidget {
  const TimePlannerWidget({super.key});

  @override
  State<TimePlannerWidget> createState() => _TimePlannerWidgetState();
}

class _TimePlannerWidgetState extends State<TimePlannerWidget> {
  bool isWeekView = false; // State variable to track the view type
  DateTime selectedDate = DateTime.now();

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

    // Get the current day's name
    String currentDayName = DateFormat('EEEE').format(selectedDate);

    // Get the shifts for the selected cafe and day
    final filteredShifts = shiftProvider.shifts
        .where((shift) => shift.cafeName == selectedCafeName)
        .toList();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? userRole = authProvider.userRole;
    String? username = authProvider.username;

    // Create a list to hold hourly shifts for the current day
    List<HourlyShift> dailyHourlyShifts = [];

    for (var shift in filteredShifts) {
      // Check if the shift contains a day shift for the current day
      if (shift.shifts.containsKey(currentDayName.toLowerCase())) {
        var dayShift =
            shift.shifts[currentDayName.toLowerCase()]; // Get the day shift
        if (dayShift != null && dayShift.hours.isNotEmpty) {
          dailyHourlyShifts.addAll(dayShift.hours);
        }
      }
    }

    // Filter out hourly shifts that have no staff members
    dailyHourlyShifts = dailyHourlyShifts
        .where((hourlyShift) => hourlyShift.staff.isNotEmpty)
        .toList();

    return Column(
      children: [
        // Header with navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.subtract(Duration(days: 1));
                  });
                },
              ),
              Text(
                currentDayName.capitalize(), // Display the current day
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    selectedDate = selectedDate.add(Duration(days: 1));
                  });
                },
              ),
            ],
          ),
        ),
        // Display shifts for the selected day
        Expanded(
          child: dailyHourlyShifts.isNotEmpty // Check if any shifts remain
              ? ListView.builder(
                  itemCount: dailyHourlyShifts.length,
                  itemBuilder: (context, index) {
                    final hourlyShift = dailyHourlyShifts[index];

                    return ExpansionTile(
                      title: Text(
                        '${hourlyShift.hourName} (${hourlyShift.staff.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: hourlyShift.staff.map((staffMember) {
                        return Card(
                          color: staffMember.set
                              ? Colors.green[300]
                              : Colors.grey[400],
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: Text(staffMember.name),
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // Only show the confirmation button if `set` is false
                                      if ((!staffMember.set) &&
                                          (userRole?.toLowerCase() == 'admin'))
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            iconColor: Colors.blue,
                                            padding: EdgeInsets.all(12.0),
                                            shape:
                                                CircleBorder(), // Make the button circular
                                          ),
                                          child: Icon(Icons.check),
                                          onPressed: () {
                                            _showConfirmationDialog(
                                                context,
                                                'Confirm Shift',
                                                'Are you sure you want to confirm this shift?',
                                                () => _confirmShift(
                                                    context,
                                                    staffMember.matricule,
                                                    currentDayName
                                                        .toLowerCase(),
                                                    hourlyShift.hourName));
                                          },
                                        ),
                                      if ((userRole?.toLowerCase() ==
                                              'admin') ||
                                          ((username ==
                                                  staffMember.matricule) &&
                                              (staffMember.set == false)))
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            iconColor: Colors.red,
                                            padding: EdgeInsets.all(12.0),
                                            shape:
                                                CircleBorder(), // Make the button circular
                                          ),
                                          child: Icon(Icons.delete_forever),
                                          onPressed: () {
                                            _showConfirmationDialog(
                                              context,
                                              'Remove Shift',
                                              'Are you sure you want to remove this shift?',
                                              () => _removeShift(
                                                  context,
                                                  staffMember.matricule,
                                                  currentDayName.toLowerCase(),
                                                  hourlyShift.hourName),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              : const Center(child: Text('No shifts available for this day.')),
        ),
      ],
    );
  }

  void _confirmShift(
      BuildContext context, String matricule, String dayName, String hourName) {
    String selectedCafeName =
        (Provider.of<CafeProvider>(context, listen: false).selectedCafe)!.name;
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    shiftProvider
        .confirmStaff(
      selectedCafeName,
      dayName,
      hourName,
      matricule,
    )
        .then((_) {
      Provider.of<ShiftProvider>(context, listen: false).fetchAllShifts();
    });
  }

  void _removeShift(
      BuildContext context, String matricule, String dayName, String hourName) {
    String selectedCafeName =
        (Provider.of<CafeProvider>(context, listen: false).selectedCafe)!.name;
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    shiftProvider
        .removeStaff(
      selectedCafeName,
      dayName,
      hourName,
      matricule,
    )
        .then((_) {
      Provider.of<ShiftProvider>(context, listen: false).fetchAllShifts();
    });
  }

  void _showConfirmationDialog(BuildContext context, String title,
      String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekView(ShiftProvider shiftProvider) {
    final tasks = <TimePlannerTask>[];
    String selectedCafeName =
        (Provider.of<CafeProvider>(context, listen: false).selectedCafe)!.name;

    final filteredShifts = shiftProvider.shifts
        .where((shift) => shift.cafeName == selectedCafeName)
        .toList();

    for (var shift in filteredShifts) {
      for (var entry in shift.shifts.entries) {
        final dayShift = entry.value;
        if (dayShift != null) {
          for (var hourlyShift in dayShift.hours) {
            if (hourlyShift.staff.isNotEmpty) {
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
                decoration: const InputDecoration(
                    labelText: 'Day Name (ex: Monday, Friday)'),
              ),
              TextField(
                controller: hourNameController,
                decoration: const InputDecoration(
                    labelText: 'Hour Name (ex: 9:00, 10:00, 17:00)'),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? userRole = authProvider.userRole;
    String? username = authProvider.username;

    return Scaffold(
      appBar: AppBar(
        title: Text('$dayName - $hourName'),
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
                      color: staffMember.set
                          ? Colors.green[300]
                          : Colors.grey[400],
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ExpansionTile(
                        title: Text(staffMember.name),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Only show the confirmation button if `set` is false
                              if ((!staffMember.set) &&
                                  (userRole?.toLowerCase() == 'admin'))
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    iconColor: Colors.blue,
                                    padding: EdgeInsets.all(
                                        12.0), // Adjust padding as needed
                                    shape:
                                        CircleBorder(), // Make the button circular
                                  ),
                                  child: Icon(Icons.check),
                                  onPressed: () {
                                    _showConfirmationDialog(
                                      context,
                                      'Confirm Shift',
                                      'Are you sure you want to confirm this shift?',
                                      () => _confirmShift(
                                          context, staffMember.matricule),
                                    );
                                  },
                                ),
                              if ((userRole?.toLowerCase() == 'admin') ||
                                  ((username == staffMember.matricule) &&
                                      (staffMember.set == false)))
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    iconColor: Colors.red,
                                    padding: EdgeInsets.all(
                                        12.0), // Adjust padding as needed
                                    shape:
                                        CircleBorder(), // Make the button circular
                                  ),
                                  child: Icon(Icons.delete_forever),
                                  onPressed: () {
                                    _showConfirmationDialog(
                                      context,
                                      'Remove Shift',
                                      'Are you sure you want to remove this shift?',
                                      () => _removeShift(
                                          context, staffMember.matricule),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            )
          : const Center(child: Text('No shifts available for this hour.')),
    );
  }

  void _confirmShift(BuildContext context, String matricule) {
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    shiftProvider
        .confirmStaff(
      shiftProvider.shifts[0].cafeName,
      dayName,
      hourName,
      matricule,
    )
        .then((_) {
      Provider.of<ShiftProvider>(context, listen: false).fetchAllShifts();
      Navigator.of(context).pop();
    });
  }

  void _removeShift(BuildContext context, String matricule) {
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    shiftProvider
        .removeStaff(
      shiftProvider.shifts[0].cafeName,
      dayName,
      hourName,
      matricule,
    )
        .then((_) {
      Provider.of<ShiftProvider>(context, listen: false).fetchAllShifts();
      Navigator.of(context).pop();
    });
  }

  void _showConfirmationDialog(BuildContext context, String title,
      String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm(); // Call the provided callback function
                Navigator.of(context).pop(); // Close the dialog
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
