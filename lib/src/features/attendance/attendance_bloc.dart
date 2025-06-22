import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_event.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_state.dart';
import 'package:karate_club_app/src/features/attendance/attendance_repository.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    on<FetchPresentMembers>(_onFetchPresentMembers);
    on<FetchAbsentMembers>(_onFetchAbsentMembers);
    on<GetTotalNumberOfPresentMembers>(_onGetTotalNumberOfPresentMembers);
    on<GetTotalNumberOfAbsentMembers>(_onGetTotalNumberOfAbsentMembers);
    on<AddAttendance>(_onAddAttendance);
  }

  Future<void> _onGetTotalNumberOfAbsentMembers(
    GetTotalNumberOfAbsentMembers event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final count = await repository.getTotalNumberOfAbsentMembers();
      emit(TotalAbsentMembersLoaded(count));
    } catch (e) {
      emit(AttendanceError('Failed to load total absent members'));
    }
  }

  Future<void> _onGetTotalNumberOfPresentMembers(
    GetTotalNumberOfPresentMembers event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final count = await repository.getTotalNumberOfPresentMembers();
      emit(TotalPresentMembersLoaded(count));
    } catch (e) {
      emit(AttendanceError('Failed to load total present members'));
    }
  }

  Future<void> _onFetchPresentMembers(
    FetchPresentMembers event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final members = await repository.fetchPresentMembers(
        limit: event.limit,
        offset: event.offset,
      );
      emit(AttendanceLoaded(members));
    } catch (e) {
      emit(AttendanceError('Failed to load members'));
    }
  }

  Future<void> _onFetchAbsentMembers(
    FetchAbsentMembers event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final members = await repository.fetchAbsentMembers(
        limit: event.limit,
        offset: event.offset,
      );
      emit(AbsentMembersLoaded(members));
    } catch (e) {
      emit(AttendanceError('Failed to load members'));
    }
  }

  Future<void> _onAddAttendance(
    AddAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      await repository.markMemberPresent(event.memberId);
      emit(AttendanceAdded());
    } catch (e) {
      emit(AttendanceError('Failed to add attendance'));
    }
  }
}
