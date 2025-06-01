import 'package:karate_club_app/src/models/member.dart';

abstract class MembersEvent {}

class LoadMembers extends MembersEvent {}

class AddMember extends MembersEvent {
  final Member member;
  AddMember(this.member);
}

class UpdateMember extends MembersEvent {
  final Member member;
  UpdateMember(this.member);
}

class DeleteMember extends MembersEvent {
  final String memberId;
  DeleteMember(this.memberId);
}
