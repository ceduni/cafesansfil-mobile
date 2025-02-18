import 'package:app/screens/article/article.dart';
import 'package:flutter/material.dart';

import 'package:app/screens/login/login_page.dart';
import 'package:app/screens/setting/settings_page.dart';
import 'package:app/screens/dashboard/cafe_page_select.dart';
import 'package:app/root_page.dart';

/// Defines all named routes in the app.
Map<String, WidgetBuilder> getAppRoutes() {
    return {
        '/settings': (context) => const SettingsPage(),
        '/home': (context) => const RootPage(),
        '/login': (context) => const LoginPage(),
        '/articles': (context) => const Article(),
        '/select_cafe': (context) => const SelectCafePage(),
    };
}
