import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_event.dart';
import 'package:karate_club_app/src/features/attendance/attendance_page.dart';
import 'package:karate_club_app/src/features/members/members_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const MembersPage(),
    const AttendancePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            context.read<AttendanceBloc>().add(FetchAbsentMembers(0, 5));
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Članovi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Prisustva'),
        ],
      ),
    );
  }
}
