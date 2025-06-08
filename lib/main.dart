import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/core/main_navigation.dart';
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

  runApp(
    MultiProvider(
      providers: [
        Provider<MemberRepository>.value(value: memberRepo),
        BlocProvider<MembersBloc>(
          create: (context) => MembersBloc(
            context.read<MemberRepository>(),
          )..add(LoadMembers()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Karate Club',
      home: MainNavigation(),
    );
  }
}
