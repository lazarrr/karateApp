import 'package:karate_club_app/src/models/member.dart';

abstract class AttendanceState {
  var Attendance;
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Member> Attendance;
  AttendanceLoaded(this.Attendance);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}
