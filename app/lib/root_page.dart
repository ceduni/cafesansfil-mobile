import 'package:app/config.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/screens/main%20screens/article.dart';
import 'package:app/screens/main%20screens/benevole.dart';
import 'package:app/screens/main%20screens/dashboard.dart';
import 'package:app/screens/main%20screens/horaire.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 1;
  List<Widget> pagesadmin = [
    // barre de navigation
    const Benevole(),
    const Dashboard(),
    const Horaire(),
    const Article(),
  ];
  List<Widget> pagesbenevole = [
    // barre de navigation
    const Benevole(),
    const Horaire(),
    const Article(),
  ];
  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context); // Get AuthProvider instance
    final userRole = authProvider.userRole; // Get the current user role
    //final userRole = "admin";
    if (userRole?.toLowerCase() != "admin") {
      return Scaffold(
        body: pagesbenevole[currentPage], //const Dashboard(),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(
                Icons.volunteer_activism,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_volunteerButtonText,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.access_time,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_hourlyButtonText,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.article,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_articleButtonText,
            ),
            /*const NavigationDestination(
                icon: Icon(
                  Icons.message,
                  color: Colors.white,
                ),
                label: "Messages"),*/
          ],
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          selectedIndex: currentPage,
          backgroundColor: Config.specialBlue,
        ),
      );
    } else {
      return Scaffold(
        body: pagesadmin[currentPage], //const Dashboard(),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(
                Icons.volunteer_activism,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_volunteerButtonText,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.dashboard,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_dashboardButtonText,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.access_time,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_hourlyButtonText,
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.article,
                color: Colors.white,
              ),
              label: AppLocalizations.of(context)!
                  .bottomNavigationBar_articleButtonText,
            ),
            /*const NavigationDestination(
              icon: Icon(
                Icons.message,
                color: Colors.white,
              ),
              label: "Messages"),*/
          ],
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          selectedIndex: currentPage,
          backgroundColor: Config.specialBlue,
        ),
      );
    }
  }
}
