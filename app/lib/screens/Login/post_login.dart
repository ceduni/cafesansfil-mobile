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
    authProvider.setTheUserName(username);
    print(username);
    var cafeRoles = await cafeProvider.getRolesByUsername(username!);
    print(cafeRoles);
    // Based on roles, redirect to the appropriate page

    if (cafeRoles.isNotEmpty) {
      // Redirect to cafe selection page if roles exist, regardless of whether it's an admin
      Navigator.pushReplacementNamed(context, '/select_cafe');
    } else {
      // Optional: Maybe handle a case where the user has no roles
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No roles found for this user.')),
      );
      // You could choose to navigate somewhere else or show an error page
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
