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
          name: 'John Doe',
          beltColor: 'Black',
          age: 25,
          joinDate: DateTime.now(),
        ),
        Member(
            id: 2,
            name: 'Jane Smith',
            beltColor: 'Blue',
            age: 22,
            joinDate: DateTime.now()),
        Member(
            id: 3,
            name: 'Bob Johnson',
            beltColor: 'Red',
            age: 30,
            joinDate: DateTime.now()),
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Attendance'),
        ],
      ),
    );
  }
}
