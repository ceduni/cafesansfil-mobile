import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool isAdmin = false; // Default role (Volunteer)
  late AnimationController _controller;
  late Animation<Color?> _backgroundAnimation;
  late Animation<Color?> _textFieldBorderAnimation;
  late Animation<Color?> _buttonColorAnimation;

  // ✅ Add controllers for TextField inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Animation Controller for smooth transitions
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Background Color Animation
    _backgroundAnimation = ColorTween(
      begin: Colors.grey.shade50,
      end: Colors.blueGrey.shade900,
    ).animate(_controller);

    // TextField Border Animation
    _textFieldBorderAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(_controller);

    // Button Color Animation
    _buttonColorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.blueAccent,
    ).animate(_controller);
  }

  // Toggle role and animate transition
  void _toggleRole(bool value) {
    setState(() {
      isAdmin = value;
      if (isAdmin) {
        _controller.forward(); // Animate to Admin mode
      } else {
        _controller.reverse(); // Animate back to Volunteer mode
      }
    });
  }

  // Login Function
  void _login() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please fill in all fields.");
      return;
    }

    if (isAdmin) {
      if (email == "admin@example.com" && password == "admin123") {
        _showSnackbar("Admin login successful! Redirecting...");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, "/home");
        });
      } else {
        _showSnackbar("Invalid admin credentials.");
      }
    } else {
      if (email == "volunteer@example.com" && password == "volunteer123") {
        _showSnackbar("Volunteer login successful! Redirecting...");
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, "/home");
        });
      } else {
        _showSnackbar("Invalid volunteer credentials.");
      }
    }
  }

  // ✅ Show Snackbar for errors & success messages
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundAnimation.value,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Animated Logo Glow Effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.blueGrey.shade800 : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isAdmin ? Colors.blueGrey : Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 3,
                      )
                    ],
                  ),
                  child: Image.asset('images/logo.png', width: 120, height: 120),
                ),

                const SizedBox(height: 50),

                // TextField with Animated Borders
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _emailController, // Capture user input
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: isAdmin ? Colors.white : Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _textFieldBorderAnimation.value!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isAdmin ? Colors.blueAccent : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: isAdmin ? Colors.white : Colors.black),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field with Animated Borders
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _passwordController, // Capture password input
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: isAdmin ? Colors.white : Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _textFieldBorderAnimation.value!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isAdmin ? Colors.blueAccent : Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: TextStyle(color: isAdmin ? Colors.white : Colors.black),
                  ),
                ),

                const SizedBox(height: 30),

                // Role Selection Switch (Sliding Thumb)
                FlutterSwitch(
                  width: 160.0,
                  height: 55.0,
                  toggleSize: 40.0,
                  value: isAdmin,
                  borderRadius: 30.0,
                  padding: 8.0,
                  activeText: "Admin",
                  inactiveText: "Volunteer",
                  activeTextColor: Colors.white,
                  inactiveTextColor: Colors.black,
                  showOnOff: true,
                  activeIcon: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 28), // Admin Icon
                  inactiveIcon: Icon(Icons.coffee_rounded, color: Colors.black, size: 28), // Volunteer Icon
                  activeColor: Colors.blueGrey.shade800,
                  inactiveColor: Colors.brown.shade200, // More natural coffee color
                  onToggle: (val) {
                    setState(() {
                      isAdmin = val;
                    });
                  },
                ),


                const SizedBox(height: 40),

                // Animated Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColorAnimation.value,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _login, // Trigger login function
                  child: Text(
                    isAdmin ? "Login as Admin" : "Login as Volunteer",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
