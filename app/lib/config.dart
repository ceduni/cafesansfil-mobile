import 'package:flutter/material.dart';

class Config {
  // Prevent instantiation.
  Config._();

  /// The IP address for local development.
  static const String ipAddress = "192.168.68.58";
  // static const String ipAdrress = "10.51.227.175";

  /// The base URL for local API requests.
  static const String baseUrl = "http://$ipAddress:3000/api/v1";

  /// The public Web API URL.
  static const String apiUrl = "https://cafesansfil-api-r0kj.onrender.com/api";

  /// The cafe's display name.
  static const String cafeName = "Tore et fraction";

  /// The cafe's slug used in URLs.
  static const String cafeSlug = "tore-et-fraction";

  /// A special blue color for UI elements.
  static const Color specialBlue = Colors.lightBlue;

  /// A lighter shade of special blue.
  static final Color specialBlueLighter = Colors.blue;

  /// Oldest year used to retrieve data.
  static final int firstYear = DateTime.now().year - 10;
}

//admin.cafekine@umontreal.ca
//benevole.cafekine@umontreal.ca
//Cafepass1 (mdp)