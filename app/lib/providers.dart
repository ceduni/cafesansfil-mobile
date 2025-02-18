import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/cafe_provider.dart';
import 'package:app/provider/language_provider.dart';
import 'package:app/provider/order_provider.dart';
import 'package:app/provider/period_selector_provider.dart';
import 'package:app/provider/shift_provider.dart';
import 'package:app/provider/stock_provider.dart';
import 'package:app/provider/volunteer_provider.dart';
import 'package:app/provider/message_provider.dart';

/// Returns a list of providers used in the app.
List<ChangeNotifierProvider> getProviders() {
  return [
    ChangeNotifierProvider(create: (context) => LanguageProvider()),
    ChangeNotifierProvider(create: (context) => PeriodSelectorProvider()),
    ChangeNotifierProvider(create: (context) => OrderProvider()),
    ChangeNotifierProvider(create: (context) => StockProvider()),
    ChangeNotifierProvider(create: (context) => ShiftProvider()),
    ChangeNotifierProvider(create: (context) => VolunteerProvider()),
    ChangeNotifierProvider(create: (context) => CafeProvider()),
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => MessageProvider()),
  ];
}
