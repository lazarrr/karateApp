import 'package:karate_club_app/src/models/member.dart';

abstract class MembersState {
  var members;
}

class MembersInitial extends MembersState {}

class MembersLoading extends MembersState {}

class MembersLoaded extends MembersState {
  final List<Member> members;
  MembersLoaded(this.members);
}

class MembersError extends MembersState {
  final String message;
  MembersError(this.message);
}
