import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/main_screen.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/edit_event_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String createEvent = '/create-event';
  static const String eventDetail = '/event-detail';
  static const String editEvent = '/edit-event';

  static Route<dynamic> generate(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case register:
        page = const RegisterScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case main:
        page = const MainScreen();
        break;
      case createEvent:
        page = const CreateEventScreen();
        break;
      case eventDetail:
        final event = settings.arguments as EventModel;
        page = EventDetailScreen(event: event);
        break;
      case editEvent:
        final event = settings.arguments as EventModel;
        page = EditEventScreen(event: event);
        break;
      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
