import 'package:flutter/material.dart';
import 'package:app/widgets/animated_logo.dart';

/// Custom Loading Screen with Beating & Fading Logo Animation
class AnimatedLoadingScreen extends StatelessWidget {
    const AnimatedLoadingScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return const MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    AnimatedBeatingLogo(),
                    SizedBox(height: 50),
                    Text("Ouverture des cafés...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
            ),
            ),
        ),
        );
    }
}
