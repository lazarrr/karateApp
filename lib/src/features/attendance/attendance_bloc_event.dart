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
  final String name;
  FetchPresentMembers(this.offset, this.limit, [this.name = '']);
}

class FetchAbsentMembers extends AttendanceEvent {
  final int offset;
  final int limit;
  final String name;
  FetchAbsentMembers(this.offset, this.limit, [this.name = '']);
}

class FetchAttendanceForMonth extends AttendanceEvent {
  final int memberId;
  final DateTime month;
  FetchAttendanceForMonth(this.memberId, this.month);
}

class GetTotalNumberOfPresentMembers extends AttendanceEvent {}

class GetTotalNumberOfAbsentMembers extends AttendanceEvent {}

class AddAttendance extends AttendanceEvent {
  final int memberId;
  AddAttendance(this.memberId);
}

class RemoveAttendance extends AttendanceEvent {
  final int memberId;
  RemoveAttendance(this.memberId);
}
