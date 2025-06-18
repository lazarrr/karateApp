import 'package:flutter/material.dart';
import 'package:karate_club_app/src/features/attendance/attendance_page.dart';
import 'package:karate_club_app/src/features/members/members_page.dart';
import 'package:karate_club_app/src/models/member.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    MembersPage(),
    AttendancePage(
      members: [
        Member(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          beltColor: 'Black',
          dateOfBirth: DateTime(1998, 5, 20),
        ),
        Member(
          id: 2,
          firstName: 'Jane',
          lastName: 'Smith',
          beltColor: 'Blue',
          dateOfBirth: DateTime(2001, 8, 15),
        ),
        Member(
          id: 3,
          firstName: 'Bob',
          lastName: 'Johnson',
          beltColor: 'Red',
          dateOfBirth: DateTime(1993, 3, 10),
        ),
      ],
    ),
    // AttendancePage(),
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
