import 'package:karate_club_app/src/models/member.dart';

abstract class AttendanceState {
  var Attendance;
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Member> attendance;
  AttendanceLoaded(this.attendance);
}

class AbsentMembersLoaded extends AttendanceState {
  final List<Member> attendance;

  AbsentMembersLoaded(this.attendance);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}

class TotalPresentMembersLoaded extends AttendanceState {
  final int count;
  TotalPresentMembersLoaded(this.count);
}

class TotalAbsentMembersLoaded extends AttendanceState {
  final int count;
  TotalAbsentMembersLoaded(this.count);
}

class AttendanceAdded extends AttendanceState {
  AttendanceAdded();
}
