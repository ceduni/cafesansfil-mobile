import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/screens/login/components/my_button.dart';
import 'package:app/screens/login/components/my_textfield.dart';
import 'package:app/screens/login/components/role_toggle.dart';
import 'package:app/widgets/animated_logo.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/models/Cafe.dart';


/// Login page with inline spinner in the login button and conditional animated logo.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final TextEditingController _emailController = TextEditingController(text: "admin.tore.et.fraction@umontreal.ca"); // Remove before production
    final TextEditingController _passwordController = TextEditingController(text: "Cafepass1"); // Remove before production
    int _selectedRole = 1;
    bool _isProcessing = false;

    void _showSnackBar(String message) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
        );
    }

    Future<void> _login() async {
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();

        if (email.isEmpty || password.isEmpty) {
            _showSnackBar('Please fill in all fields.');
            return;
        }

        setState(() {
            _isProcessing = true;
        });

        try {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            final cafeProvider = Provider.of<CafeProvider>(context, listen: false);

            await authProvider.login(email, password);

            // Set the user role based on selection.
            final role = _selectedRole == 0 ? 'Bénévole' : 'Admin';
            authProvider.setTheUserRole(role);

            // Fetch the username.
            String? username = await authProvider.getUsername();
            if (username == null) {
                _showSnackBar('Login failed: username not found.');
                return;
            }
            authProvider.setTheUsername(username);

            // Role-based access checks.
            if (role == 'Admin') {
                final List<CafeRoleInfo> cafeRoles = await cafeProvider.getAdminCafe(username);
                if (cafeRoles.isEmpty) {
                    _showSnackBar('This user is not an administrator.');
                    return;
                }
                cafeProvider.setSelectedCafe(cafeRoles.first.cafeId);
                if (mounted) Navigator.pushReplacementNamed(context, '/home');
            } else {
                final List<CafeRoleInfo> cafeRoles = await cafeProvider.getVolunteerCafe(username);
                if (cafeRoles.isEmpty) {
                    _showSnackBar('No volunteer access found.');
                    return;
                }
                if (mounted) Navigator.pushReplacementNamed(context, '/select_cafe');
            }
        } catch (e) {
            _showSnackBar('Login failed: ${e.toString()}');
        } finally {
            setState(() {
            _isProcessing = false;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    _isProcessing? const AnimatedBeatingLogo() : Image.asset('images/logo.png', width: 200, height: 200),

                    const SizedBox(height: 50),
                    MyTextField(hintText: "Email", obscureText: false, controller: _emailController),

                    const SizedBox(height: 20),
                    MyTextField(hintText: "Password", obscureText: true, controller: _passwordController),
                    
                    const SizedBox(height: 20),
                    const Text('Choose Account Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    
                    const SizedBox(height: 20),
                    RoleToggle(
                        selectedIndex: _selectedRole,
                        onSelect: (index) => setState(() => _selectedRole = index),
                    ),
                    
                    const SizedBox(height: 35),
                    // Use the updated button with inline spinner.
                    MyButton(text: "Se connecter", isLoading: _isProcessing, onTap: _login),
                ],
            ),
            ),
        ),
        );
    }
}
