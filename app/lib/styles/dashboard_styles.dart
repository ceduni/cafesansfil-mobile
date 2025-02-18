import 'package:flutter/material.dart';
import 'package:app/config.dart';

// Global Text Styles
class AppStyles {
  static const TextStyle dashboardTitle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle whiteBoldText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

// Global Container Styles
class AppContainers {
  static BoxDecoration metricBox = BoxDecoration(
    color: Config.specialBlueLighter,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration buttonContainer = BoxDecoration(
    color: Config.specialBlue,
    borderRadius: BorderRadius.circular(30),
  );
}
