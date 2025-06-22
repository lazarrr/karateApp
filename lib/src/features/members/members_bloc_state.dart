import 'package:karate_club_app/src/models/member.dart';

abstract class MembersState {
  final List<Member> members;
  MembersState(this.members);
}

class MembersInitial extends MembersState {
  MembersInitial(super.members);
}

class MembersLoading extends MembersState {
  MembersLoading(super.members);
}

class MembersLoaded extends MembersState {
  MembersLoaded(super.members);
}

class TotalCountOfMembers extends MembersState {
  final int count;
  TotalCountOfMembers(this.count) : super([]);
}

class MembersError extends MembersState {
  final String message;
  MembersError(this.message) : super([]);
}
