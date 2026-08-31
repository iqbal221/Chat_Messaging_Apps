import 'package:ChatVani/features/auth/presentation/screens/login_screen.dart';
import 'package:ChatVani/features/auth/presentation/screens/registration_screen.dart';
import 'package:ChatVani/features/contacts/presentation/screens/add_new_contact.dart';
import 'package:ChatVani/features/chat/presentation/screens/chat_screen.dart';
import 'package:ChatVani/features/contacts/presentation/screens/contact_screen.dart';
import 'package:ChatVani/features/home/presentation/screens/home_screen.dart';
import 'package:ChatVani/features/auth/presentation/screens/input_phone_screen.dart';
import 'package:ChatVani/core/screens/main_nav_bar.dart';
import 'package:ChatVani/features/profiles/presentation/screens/new_profile.dart';
import 'package:ChatVani/features/auth/presentation/screens/otp_verify.dart';
import 'package:ChatVani/features/profiles/presentation/screens/profile_screen.dart';
import 'package:ChatVani/features/chat/presentation/screens/recent_chat_contact_screen.dart';
import 'package:ChatVani/features/profiles/presentation/screens/update_profile.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> routes(RouteSettings settings) {
    Widget widget = SizedBox();

    if (settings.name == HomeScreen.name) {
      widget = HomeScreen();
    } else if (settings.name == PhoneNumberScreen.name) {
      widget = PhoneNumberScreen();
    } else if (settings.name == OtpVerifyScreen.name) {
      final args = settings.arguments as Map?;
      final phone = args?['phoneNumber'] ?? '';
      widget = OtpVerifyScreen(phoneNumber: phone);
    } else if (settings.name == ProfileScreen.name) {
      widget = ProfileScreen();
    } else if (settings.name == NewUserProfileScreen.name) {
      widget = NewUserProfileScreen();
    } else if (settings.name == MainNavBarScreen.name) {
      widget = MainNavBarScreen(initialIndex: 1);
    } else if (settings.name == UpdateUserProfileScreen.name) {
      widget = UpdateUserProfileScreen();
    } else if (settings.name == ContactScreen.name) {
      widget = ContactScreen();
    } else if (settings.name == AddNewContactScreen.name) {
      widget = AddNewContactScreen();
    } else if (settings.name == RegisterScreen.name) {
      widget = RegisterScreen();
    } else if (settings.name == LoginScreen.name) {
      widget = LoginScreen();
    } else if (settings.name == ChatScreen.name) {
      final args = settings.arguments as Map?;
      widget = ChatScreen(
        receiverId: args?['receiverId'] ?? '',
        receiverName: args?['receiverName'] ?? '',
        receiverImage: args?['receiverImage'] ?? '',
      );
    } else if (settings.name == RecentChatScreen.name) {
      widget = RecentChatScreen();
    }
    return MaterialPageRoute(builder: (ctx) => widget);
  }
}
