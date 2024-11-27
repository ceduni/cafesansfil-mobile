import 'package:app/modeles/Cafe.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCafePage extends StatelessWidget {
  const SelectCafePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cafeProvider = Provider.of<CafeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Get the actual username from your auth provider
    final String username = authProvider.username!;
    String? userRole = authProvider.userRole;
    print(userRole);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Cafe Where you are Volunteer')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Logged in as: $username',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CafeRoleInfo>>(
              future: cafeProvider.getVolunteerCafe(username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cafes assigned to you.'));
                }

                final userRoles = snapshot.data!;

                // Use a Set to keep track of unique identifiers
                Set<String> uniqueIdentifiers = {};
                List<CafeRoleInfo> uniqueRoles = [];

                for (var roleInfo in userRoles) {
                  String identifier = '${roleInfo.cafeName} - ${roleInfo.role}';
                  if (!uniqueIdentifiers.contains(identifier)) {
                    uniqueIdentifiers.add(identifier);
                    uniqueRoles.add(roleInfo);
                  }
                }
                // If there's only one café
                if (uniqueRoles.length == 1) {
                  CafeRoleInfo uniqueRoleInfo = uniqueRoles.first;
                  cafeProvider.setSelectedCafe(uniqueRoleInfo.cafeId);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacementNamed(context, '/home');
                  });
                  return const Center(child: Text('Redirecting to home...'));
                } else {
                  // Display the list of cafés with roles
                  return ListView.builder(
                    itemCount: uniqueRoles.length,
                    itemBuilder: (context, index) {
                      CafeRoleInfo cafeRoleInfo = uniqueRoles[index];

                      return ListTile(
                        title: ElevatedButton(
                          child: Text(
                              '${cafeRoleInfo.cafeName}- Role: ${cafeRoleInfo.role}'),
                          onPressed: () {
                            // Set the selected café in CafeProvider
                            print(cafeRoleInfo.cafeId);
                            cafeProvider.setSelectedCafe(cafeRoleInfo.cafeId);
                            authProvider.setTheUserRole(cafeRoleInfo.role);
                            // Navigate to the café's home page when clicking on a café
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
