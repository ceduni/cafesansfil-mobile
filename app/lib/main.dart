import 'dart:ui';

import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/language_provider.dart';
import 'package:app/provider/order_provider.dart';
import 'package:app/provider/period_selector_provider.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/provider/volunteer_provider.dart';
import 'package:app/root_page.dart';
import 'package:app/screens/others%20screens/cafe_page_select.dart';
import 'package:app/screens/setting%20options/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/screens/Login/login_page.dart';
import 'package:app/provider/message_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => PeriodSelectorProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => StockProvider()),
        ChangeNotifierProvider(create: (context) => ShiftProvider()),
        ChangeNotifierProvider(create: (context) => VolunteerProvider()),
        ChangeNotifierProvider(create: (context) => CafeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color.fromARGB(255, 138, 199, 249),
          ),
          supportedLocales: L10n.all,
          locale: languageProvider.getactualLanguage(), //en, fr or es  language
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          debugShowCheckedModeBanner: false,
          home: const LoginPage(),
          routes: {
            '/settings': (context) => const SettingsPage(),
            '/home': (context) => const RootPage(),
            '/login': (context) => const LoginPage(),
            '/select_cafe': (context) => const SelectCafePage(),
          },
        );
      },
    );
  }
}
