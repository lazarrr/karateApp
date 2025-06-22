import 'package:karate_club_app/src/models/member.dart';

abstract class MembersEvent {}

class LoadMembers extends MembersEvent {
  final int offset;
  final int limit;
  final String name;

  LoadMembers({this.offset = 0, this.limit = 5, this.name = ''});
}

class GetTotalCountOfMembers extends MembersEvent {}

class AddMember extends MembersEvent {
  final Member member;
  AddMember(this.member);
}

class UpdateMember extends MembersEvent {
  final Member member;
  UpdateMember(this.member);
}

class DeleteMember extends MembersEvent {
  final int memberId;
  DeleteMember(this.memberId);
}
