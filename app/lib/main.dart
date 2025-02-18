import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import 'package:app/preferences.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/routes.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/language_provider.dart';
import 'package:app/provider/order_provider.dart';
import 'package:app/provider/navbar_provider.dart';
import 'package:app/provider/period_selector_provider.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/provider/volunteer_provider.dart';
import 'package:app/provider/message_provider.dart';
import 'package:app/splash_screen.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before async calls

    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MultiProvider(
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
            ChangeNotifierProvider(create: (context) => BottomNavProvider()),
        ],
        child: FutureBuilder(
            future: _initializeApp(),
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AnimatedLoadingScreen(); 
                } else {
                    return const _AppWrapper();
                }
            }));
    }

    /// Perform any necessary initialization before showing the app
    Future<void> _initializeApp() async {
        await Future.delayed(const Duration(milliseconds: 3000));
        await Preferences.init(); // Initialize shared preferences
    }
}

class _AppWrapper extends StatelessWidget {
    const _AppWrapper();

    @override
    Widget build(BuildContext context) {
        return Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
            return MaterialApp(
                theme: ThemeData(
                    brightness: Brightness.light,
                    primaryColor: const Color.fromARGB(255, 138, 199, 249)
                ),
                supportedLocales: L10n.all,
                locale: languageProvider.getactualLanguage(), //en, fr or es  language
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                debugShowCheckedModeBanner: false,
                initialRoute: '/login',
                routes: getAppRoutes(),
            );
        },
        );
    }
}
