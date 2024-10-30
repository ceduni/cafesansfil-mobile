import 'package:app/config.dart';
import 'package:app/modeles/Cafe.dart';
//import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/volunteer_provider.dart';
import 'package:app/screens/messages/Broadcast_message.dart';
import 'package:app/screens/others%20screens/add_benevole.dart';
import 'package:app/screens/others%20screens/delete_benevole.dart';
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
    await Provider.of<VolunteerProvider>(context, listen: false)
        .fetchVolunteer();
    /*if (selectedCafe != null) {
      // Fetch volunteers using the staff from the selected cafe
      await Provider.of<VolunteerProvider>(context, listen: false)
          .fetchVolunteersByStaff(selectedCafe.staff);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final userRole = "admin";
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
                    (context.read<VolunteerProvider>().Volunteers).length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage((context
                                    .read<VolunteerProvider>()
                                    .Volunteers)[index]
                                .photoUrl),
                          ),
                          title: Text(
                              "${(context.read<VolunteerProvider>().Volunteers)[index].firstName} "),
                          subtitle: Text(
                              AppLocalizations.of(context)!.volunteer_text),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagePage(
                                  userName:
                                      "${(context.read<VolunteerProvider>().Volunteers)[index].username}",
                                  userEmail:
                                      "${(context.read<VolunteerProvider>().Volunteers)[index].email}",
                                  firstName:
                                      "${(context.read<VolunteerProvider>().Volunteers)[index].firstName}",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
          if (userRole == 'admin')
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
          if (userRole == 'admin')
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
          if (userRole == 'admin')
            Positioned(
              bottom: 85,
              right: 10, // Positioned to the right of the first button
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DeleteBenevole()));
                },
                backgroundColor: Config.specialBlue,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
