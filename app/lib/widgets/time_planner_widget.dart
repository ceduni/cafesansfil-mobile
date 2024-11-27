import 'package:app/config.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimePlannerWidget extends StatefulWidget {
  const TimePlannerWidget({super.key});

  @override
  State<TimePlannerWidget> createState() => _TimePlannerWidgetState();
}

class _TimePlannerWidgetState extends State<TimePlannerWidget> {
  @override
  Widget build(BuildContext context) {
    final shiftProvider = Provider.of<ShiftProvider>(context);

    if (shiftProvider.shifts.isEmpty) {
      shiftProvider.fetchAllShifts();
    }

    return Scaffold(
      body: shiftProvider.shifts.isNotEmpty
          ? ListView.builder(
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
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0),
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
                          return ListTile(
                            title: Text(
                                '${entry.key.capitalize()} - Not a work day'),
                          );
                        }
                      }).toList(),
                    ],
                  ),
                );
              },
            )
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
              /*TextField(
                controller: cafeNameController,
                decoration: const InputDecoration(labelText: 'Cafe Name'),
              ),*/
              TextField(
                controller: dayNameController,
                decoration: const InputDecoration(labelText: 'Day Name'),
              ),
              TextField(
                controller: hourNameController,
                decoration: const InputDecoration(labelText: 'Hour Name'),
              ),
              /*TextField(
                controller: matriculeController,
                decoration: const InputDecoration(labelText: 'Matricule'),
              ),*/
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                //final cafeName = cafeNameController.text;
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
                backgroundColor: Colors.blue, // Couleur de fond du bouton
                foregroundColor: Colors.white, // Couleur du texte du bouton
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
                  shiftProvider
                      .shifts[0].cafeName, // Adjust to the proper cafeName
                  dayName,
                  hourName,
                  matricule,
                )
                    .then((_) {
                  Navigator.of(context).pop(); // Close the dialog
                });
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400], // Couleur de fond du bouton
                foregroundColor: Colors.white, // Couleur du texte du bouton
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
                  shiftProvider
                      .shifts[0].cafeName, // Adjust to the proper cafeName
                  dayName,
                  hourName,
                  matricule,
                )
                    .then((_) {
                  Navigator.of(context).pop(); // Close the dialog
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
