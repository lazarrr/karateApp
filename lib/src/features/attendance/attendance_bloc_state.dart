import 'package:karate_club_app/src/models/member.dart';

abstract class AttendanceState {
  // ignore: prefer_typing_uninitialized_variables
  final List<Member> attendance;
  AttendanceState(this.attendance);
}

class AttendanceInitial extends AttendanceState {
  AttendanceInitial(super.attendance);
}

class AttendanceLoading extends AttendanceState {
  AttendanceLoading(super.attendance);
}

class AttendanceLoaded extends AttendanceState {
  AttendanceLoaded(super.attendance);
}

class AbsentMembersLoaded extends AttendanceState {
  AbsentMembersLoaded(super.attendance);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message) : super([]);
}

class TotalPresentMembersLoaded extends AttendanceState {
  final int count;
  TotalPresentMembersLoaded(this.count) : super([]);
}

class TotalAbsentMembersLoaded extends AttendanceState {
  final int count;
  TotalAbsentMembersLoaded(this.count) : super([]);
}

class AttendanceAdded extends AttendanceState {
  AttendanceAdded(super.attendance);
}

class AttendanceRemoved extends AttendanceState {
  AttendanceRemoved(super.attendance);
}
