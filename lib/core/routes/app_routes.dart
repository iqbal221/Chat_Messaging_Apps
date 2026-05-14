import 'package:chat_messaging/core/screens/home_screen.dart';
import 'package:chat_messaging/core/screens/input_phone_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> routes(RouteSettings settings) {
    Widget widget = SizedBox();

    if (settings.name == HomeScreen.name) {
      widget = HomeScreen();
    } else if (settings.name == PhoneNumberScreen.name) {
      widget = PhoneNumberScreen();
    }

    return MaterialPageRoute(builder: (ctx) => widget);
  }
}
