import 'package:app/models/Cafe.dart';
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

    /// Shows a SnackBar and redirects after a delay
    void _showAndRedirect(String message, String route) async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
            Navigator.pushReplacementNamed(context, route);
        }
    }

    Future<void> _initializeUserData() async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final cafeProvider = Provider.of<CafeProvider>(context, listen: false);
        
        // Fetch the username and user role
        String? username = await authProvider.getUsername();
        String? firstname = await authProvider.getFirstname();
        String? lastname = await authProvider.getLastname();

        if (username == null) {
            _showAndRedirect('Invalid user. Redirecting to login...', '/login');
            return;
        }

        authProvider.setTheUsername(username);

        // Based on roles, redirect to the appropriate page
        if (authProvider.userRole == 'Admin') {
            final List<CafeRoleInfo> cafeRoles = await cafeProvider.getAdminCafe(username);
            if (cafeRoles.isEmpty) {
                _showAndRedirect('This user is not an administrator. Redirecting to login...', '/login');
                return;
            }
            cafeProvider.setSelectedCafe(cafeRoles.first.cafeId);
            if (mounted) Navigator.pushReplacementNamed(context, '/home');
        } else {
            final List<CafeRoleInfo> cafeRoles = await cafeProvider.getVolunteerCafe(username);
            if (cafeRoles.isEmpty) {
                _showAndRedirect('No volunteer access found. Redirecting to login...', '/login');
                return;
            }
            if (mounted) Navigator.pushReplacementNamed(context, '/select_cafe');
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Initializing...')),
            body: Center(child: CircularProgressIndicator()),
        );
    }
}
