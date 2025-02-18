import 'package:app/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
    const Sidebar({super.key});

    @override
    Widget build(BuildContext context) {
        // Define a common text style for the list tiles.
        TextStyle style = const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
        );

        return Drawer(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Config.specialBlue, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                    ),
                ),
                child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                        // Drawer header with avatar and welcome message.
                        DrawerHeader(
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Config.specialBlue,
                                ),
                            ),
                            const SizedBox(height: 10),
                            Text("Salut boss!", style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            ],
                        ),
                        ),
                        // Profile
                        ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text(
                            AppLocalizations.of(context)!.sidebar_profile,
                            style: style,
                        ),
                        onTap: () {
                            // Navigate to Profile page (add your route/navigation here)
                        },
                        ),
                        // Settings
                        ListTile(
                        leading: const Icon(Icons.settings, color: Colors.white),
                        title: Text(
                            AppLocalizations.of(context)!.sidebar_setting,
                            style: style,
                        ),
                        onTap: () {
                            Navigator.pushNamed(context, '/settings');
                        },
                        ),
                        // Notifications
                        ListTile(
                        leading: const Icon(Icons.notifications, color: Colors.white),
                        title: Text(
                            AppLocalizations.of(context)!.sidebar_notification,
                            style: style,
                        ),
                        onTap: () {
                            // Navigate to Notifications page if available.
                        },
                        ),
                        const Divider(color: Colors.white54, indent: 16, endIndent: 16),
                        
                        // Logout
                        ListTile(
                            leading: const Icon(Icons.logout, color: Colors.white),
                            title: Text(AppLocalizations.of(context)!.sidebar_logOut, style: style,),
                        onTap: () async {
                            await Provider.of<AuthProvider>(context, listen: false).logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        ),
                    // Optional: Additional items or app version info can be added here.
                    ],
                ),
            ),
        );
    }
}
