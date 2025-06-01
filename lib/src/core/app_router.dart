import 'package:flutter/material.dart';
import 'package:karate_club_app/src/features/members/members_page.dart';

class AppRouter {
  static const String members = '/members';
  static const String attendance = '/attendance';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case members:
        return MaterialPageRoute(builder: (_) => MembersPage());
      case attendance:
      // return MaterialPageRoute(builder: (_) => AttendancePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
