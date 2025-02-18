import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:app/config.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isAdmin;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
         if (isAdmin) // Only show Dashboard for admins
          NavigationDestination(
            icon: const Icon(Icons.dashboard, color: Colors.white),
            label: AppLocalizations.of(context)!.bottomNavigationBar_dashboardButtonText,
          ),
        NavigationDestination(
          icon: const Icon(Icons.volunteer_activism, color: Colors.white),
          label: AppLocalizations.of(context)!.bottomNavigationBar_volunteerButtonText,
        ),
        NavigationDestination(
          icon: const Icon(Icons.access_time, color: Colors.white),
          label: AppLocalizations.of(context)!.bottomNavigationBar_hourlyButtonText,
        ),
        NavigationDestination(
          icon: const Icon(Icons.article, color: Colors.white),
          label: AppLocalizations.of(context)!.bottomNavigationBar_articleButtonText,
        ),
      ],
      onDestinationSelected: onItemTapped,
      selectedIndex: selectedIndex,
      backgroundColor: Config.specialBlue,
    );
  }
}
