import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/core/main_navigation.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_repository.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_repository.dart';
import 'package:karate_club_app/src/models/db/database_helper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper.instance;
  final memberRepo = MemberRepository(dbHelper);
  final attendanceRepo = AttendanceRepository(dbHelper);

  runApp(
    MultiProvider(
      providers: [
        Provider<MemberRepository>.value(value: memberRepo),
        Provider<AttendanceRepository>.value(value: attendanceRepo),
        BlocProvider<MembersBloc>(
          create: (context) => MembersBloc(
            context.read<MemberRepository>(),
          )..add(LoadMembers()),
        ),
        BlocProvider<AttendanceBloc>(
            create: (context) => AttendanceBloc(
                  context.read<AttendanceRepository>(),
                )),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Karate Club',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent, // 👈 one‑liner
      ),
      home: Stack(
        children: [
          // ❶ WHITE “canvas” – drawn first
          Positioned.fill(
            child: Container(color: Colors.white),
          ),

          // ❷ Your logo – drawn on top of the white canvas
          Positioned.fill(
            child: Image.asset(
              'assets/logo.jpeg',
              fit: BoxFit.fitWidth, // keep if you want the full logo in view
              alignment: Alignment.center, // optional: pin it to the top
            ),
          ),

          // ❸ Main content – drawn last
          const MainNavigation(),
        ],
      ),
    );
  }
}
