import 'package:app/modeles/Cafe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';

class PostLoginRedirectPage extends StatefulWidget {
  const PostLoginRedirectPage({Key? key}) : super(key: key);

  @override
  _PostLoginRedirectPageState createState() => _PostLoginRedirectPageState();
}

class _PostLoginRedirectPageState extends State<PostLoginRedirectPage> {
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cafeProvider = Provider.of<CafeProvider>(context, listen: false);

    // Fetch the username and user role
    String? username = await authProvider.getUsername();
    String? firstname = await authProvider.getFirstname();
    String? lastname = await authProvider.getLastname();
    authProvider.setTheUsername(username);
    print(username);
    print(firstname);
    print(lastname);

    List<CafeRoleInfo> cafeRoles;
    // Based on roles, redirect to the appropriate page
    if (authProvider.userRole == 'Admin') {
      print(authProvider.userRole);
      cafeRoles = await cafeProvider.getAdminCafe(username!);
      if (cafeRoles.isNotEmpty) {
        CafeRoleInfo uniqueRoleInfo = cafeRoles.first;
        cafeProvider.setSelectedCafe(uniqueRoleInfo.cafeId);
        print(cafeRoles);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'this user is not an administrateur or does not have an admin account. Redirecting to login...')),
        );
        await Future.delayed(const Duration(seconds: 5));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      cafeRoles = await cafeProvider.getVolunteerCafe(username!);
    }
    print(cafeRoles);

    if (cafeRoles.isNotEmpty) {
      // Redirect to cafe selection page or the home page
      if (authProvider.userRole == 'Admin') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/select_cafe');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'this user is not an administrateur or does not have an admin account. Redirecting to login...')),
      );
      await Future.delayed(const Duration(seconds: 10));
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initializing...')),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
