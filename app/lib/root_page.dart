import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/navbar_provider.dart';
import 'package:app/screens/article/article.dart';
import 'package:app/screens/benevole/benevole.dart';
import 'package:app/screens/dashboard/dashboard.dart';
import 'package:app/screens/benevole/horaire.dart';
import 'package:app/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RootPage extends StatefulWidget {
    const RootPage({super.key});

    @override
    State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
    int currentPage = 0; // Set default page to 0 instead of 1 for consistency

    @override
    Widget build(BuildContext context) {
        final authProvider = Provider.of<AuthProvider>(context);
        final navbarProvider = Provider.of<BottomNavProvider>(context);
        final userRole = authProvider.userRole?.toLowerCase();
        final bool isAdmin = userRole == "admin";

        List<Widget> pages = isAdmin
            ? [const Dashboard(), const Benevole(), const Horaire(), const Article()]
            : [const Benevole(), const Horaire()];

        return Scaffold(
        body: pages[navbarProvider.selectedIndex], // Dynamically set the body based on selected index
        bottomNavigationBar: CustomNavigationBar(
            selectedIndex: navbarProvider.selectedIndex,
            onItemTapped: (index) {
                navbarProvider.updateIndex(index);
            },
            isAdmin: isAdmin,
        ),
        );
    }
}

