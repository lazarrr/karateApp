import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/core/main_navigation.dart';
import 'package:karate_club_app/src/features/members/members_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Karate Member Management',
      home: BlocProvider(
        create: (context) =>
            MembersBloc(MembersRepository())..add(LoadMembers()),
        child: const MainNavigation(),
      ),
    );
  }
}
