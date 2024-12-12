import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/services/VolunteerService.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/volunteer_provider.dart';
import 'package:app/screens/messages/Broadcast_message.dart';
import 'package:app/screens/others%20screens/add_benevole.dart';
import 'package:app/screens/side%20bar/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

import '../messages/message.dart';

class Benevole extends StatefulWidget {
  const Benevole({super.key});

  @override
  State<Benevole> createState() => _BenevoleState();
}

class _BenevoleState extends State<Benevole> {
  List<Map<String, String>> volunteers = [
    {'image': 'images/volunteer1.jpg', 'name': 'John Doe'},
    {'image': 'images/volunteer2.jpg', 'name': 'pauline Uvier'},
    {'image': 'images/volunteer3.jpg', 'name': 'paul van ingh'},
    {'image': 'images/volunteer4.jpg', 'name': 'Laurie campion'}
  ];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    Cafe? selectedCafe =
        Provider.of<CafeProvider>(context, listen: false).selectedCafe;
    //print(selectedCafe?.name);
    //await Provider.of<VolunteerProvider>(context, listen: false).fetchVolunteer();
    if (selectedCafe != null) {
      // Fetch volunteers using the staff from the selected cafe
      print(selectedCafe.name);
      await Provider.of<VolunteerProvider>(context, listen: false)
          .fetchVolunteer(selectedCafe.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? userRole = authProvider.userRole;
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pagesTitles_volunteerTitle),
        surfaceTintColor: Config.specialBlue,
      ),
      body: Consumer<VolunteerProvider>(
        builder: (context, volunteerProvider, child) {
          if (volunteerProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: Config.specialBlue));
          } else if (volunteerProvider.hasError) {
            return Center(
                child: Text('Error: ${volunteerProvider.errorMessage}'));
          } else {
            return Center(
              child: ListView.builder(
                itemCount:
                    (context.read<VolunteerProvider>().volunteers).length,
                itemBuilder: (context, index) {
                  final volunteer =
                      (context.read<VolunteerProvider>().volunteers)[index];
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Slidable(
                      endActionPane: userRole?.toLowerCase() == 'admin'
                          ? ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    // Pass the VolunteerProvider instance to the confirmation dialog
                                    final volunteerProvider =
                                        Provider.of<VolunteerProvider>(context,
                                            listen: false);
                                    _showDeleteConfirmationDialog(context,
                                        volunteer.username, volunteerProvider);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            )
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(volunteer.photoUrl),
                        ),
                        title: Text("${volunteer.firstName} "),
                        subtitle:
                            Text(AppLocalizations.of(context)!.volunteer_text),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagePage(
                                userName: volunteer.username,
                                userEmail: volunteer.email,
                                firstName: volunteer.firstName,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: Stack(
        children: [
          //(Provider.of<AuthProvider>(context).userRole == 'admin')
          if (userRole?.toLowerCase() == 'admin')
            Positioned(
              bottom: 16,
              right: 70, // Offset to avoid overlap
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddBenevole()));
                },
                backgroundColor: Config.specialBlue,
                child: const Icon(
                  Icons.add_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          // Second FloatingActionButton for broadcasting
          if (userRole?.toLowerCase() == 'admin')
            Positioned(
              bottom: 16,
              right: 10, // Positioned to the right of the first button
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BroadcastMessagePage()),
                  );
                },
                backgroundColor: Config.specialBlue,
                child: const Icon(
                  Icons.broadcast_on_home,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context,
      String username, VolunteerProvider volunteerProvider) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content:
              Text("Are you sure you want to delete $username as a volunteer?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Call the delete method from your VolunteerService
                Cafe? selectedCafe =
                    Provider.of<CafeProvider>(context, listen: false)
                        .selectedCafe;
                String response = await VolunteerService()
                    .deleteVolunteer(selectedCafe!.slug, username);

                // Remove the volunteer from the list if deletion was successful
                if (response == "Success: Volunteer deleted successfully.") {
                  volunteerProvider
                      .removeVolunteer(username); // Update the provider's list
                }

                // Show a Snackbar with the response
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response)),
                );

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
