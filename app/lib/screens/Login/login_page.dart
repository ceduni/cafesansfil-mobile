import 'package:app/screens/Login/components/my_button.dart';
import 'package:app/screens/Login/components/my_textfield.dart';
import 'package:app/screens/Login/post_login.dart';
import 'package:flutter/material.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _selectedRole = 0; // 0 = Volunteer, 1 = Admin

  void _login() async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      // Check if the selected role is either Admin (2) or Volunteer (0)

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        // Appel de la méthode de login qui stocke le token
        await Provider.of<AuthProvider>(context, listen: false)
            .login(email, password);
        // Redirect based on user role
        if (_selectedRole == 0) {
          Provider.of<AuthProvider>(context, listen: false)
              .setTheUserRole('Bénévole');
        } else {
          Provider.of<AuthProvider>(context, listen: false)
              .setTheUserRole('Admin');
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PostLoginRedirectPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  void _selectRole(int index) {
    setState(() {
      _selectedRole = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset('images/logo.png', width: 200, height: 200),
            const SizedBox(height: 50),

            // Email textField
            MyTextField(
              hintText: "email",
              obscureText: false,
              controller: _emailController,
            ),

            const SizedBox(height: 20),

            // Password textField
            MyTextField(
              hintText: "Password",
              obscureText: true,
              controller: _passwordController,
            ),

            const SizedBox(height: 20),

            Text('choose account the Type'),

            const SizedBox(height: 20),

            ToggleSwitch(
              minWidth: 90.0,
              cornerRadius: 20.0,
              activeBgColors: [
                const [Color.fromARGB(255, 138, 199, 249)],
                const [Color.fromARGB(255, 138, 199, 249)]
              ],
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.white,
              inactiveFgColor: Colors.black,
              initialLabelIndex: _selectedRole,
              totalSwitches: 2,
              labels: ['Volunteer', 'Admin'],
              radiusStyle: true,
              onToggle: (index) {
                setState(() {
                  _selectedRole = index!; // Set selected account type
                });
                //_selectRole(index!);
                print('switched to: $index');
              },
            ),

            const SizedBox(height: 35),

            // Login Button
            MyButton(
              text: "Login",
              onTap: _login,
            ),
          ],
        ),
      ),
    );
  }
}
