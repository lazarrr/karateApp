import 'package:karate_club_app/src/models/member.dart';

abstract class AttendanceEvent {}

class LoadAttendance extends AttendanceEvent {}

class AddMember extends AttendanceEvent {
  final Member member;
  AddMember(this.member);
}

class FetchPresentMembers extends AttendanceEvent {
  final int offset;
  final int limit;
  FetchPresentMembers(this.offset, this.limit);
}

class FetchAbsentMembers extends AttendanceEvent {
  final int offset;
  final int limit;
  FetchAbsentMembers(this.offset, this.limit);
}

class GetTotalNumberOfPresentMembers extends AttendanceEvent {}

class GetTotalNumberOfAbsentMembers extends AttendanceEvent {}
