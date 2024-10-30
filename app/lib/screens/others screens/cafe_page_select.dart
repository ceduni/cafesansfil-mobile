import 'package:app/provider/cafe_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SelectCafePage extends StatelessWidget {
  const SelectCafePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var cafeProvider = Provider.of<CafeProvider>(context);
    var cafes = ["acquis-de-droit", "tore-et-fraction"];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Cafe')),
      body: (() {
        // Check how many cafes the user has
        if (cafes.length == 1) {
          // If only one cafe, set it as selected and navigate to home
          cafeProvider.setSelectedCafe(cafes[0]);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
          return const Center(child: Text('Redirecting to home...'));
        } else {
          // More than one cafe, show the list
          return ListView.builder(
            itemCount: cafes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(cafes[index]),
                onTap: () {
                  // Set the selected cafe in CafeProvider
                  cafeProvider.setSelectedCafe(cafes[index]);
                  // Navigate to the cafe's home page when clicking on a cafe
                  Navigator.pushReplacementNamed(context, '/home');
                },
              );
            },
          );
        }
      }()),
    );
  }
}
