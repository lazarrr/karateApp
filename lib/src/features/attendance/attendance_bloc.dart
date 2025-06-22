import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_event.dart';
import 'package:karate_club_app/src/features/attendance/attendance_bloc_state.dart';
import 'package:karate_club_app/src/features/attendance/attendance_repository.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceInitial()) {
    on<FetchPresentMembers>(_onFetchPresentMembers);
    on<FetchAbsentMembers>(_onFetchAbsentMembers);
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
      emit(AttendanceLoaded(members));
    } catch (e) {
      emit(AttendanceError('Failed to load members'));
    }
  }
}
