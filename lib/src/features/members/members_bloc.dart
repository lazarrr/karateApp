import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/members/members_bloc_event.dart';
import 'package:karate_club_app/src/features/members/members_bloc_state.dart';
import 'package:karate_club_app/src/features/members/members_repository.dart';

class MembersBloc extends Bloc<MembersEvent, MembersState> {
  final MemberRepository repository;

  MembersBloc(this.repository) : super(MembersInitial([])) {
    on<LoadMembers>(_onLoadMembers);
    on<AddMember>(_onAddMember);
    on<UpdateMember>(_onUpdateMember);
    on<DeleteMember>(_onDeleteMember);
    on<GetTotalCountOfMembers>(getTotalCountOfMembers);
  }

  Future<void> getTotalCountOfMembers(
    GetTotalCountOfMembers event,
    Emitter<MembersState> emit,
  ) async {
    try {
      final count = await repository.getTotalCountOfMembers();
      emit(TotalCountOfMembers(count));
    } catch (e) {
      emit(MembersError('Failed to load total count of members'));
    }
  }

  Future<void> _onLoadMembers(
    LoadMembers event,
    Emitter<MembersState> emit,
  ) async {
    emit(MembersLoading([]));
    try {
      final members = await repository.getAllMembers(
        offset: event.offset,
        limit: event.limit,
        name: event.name,
      );
      emit(MembersLoaded(members));
    } catch (e) {
      emit(MembersError('Failed to load members'));
    }
  }

  Future<void> _onAddMember(
    AddMember event,
    Emitter<MembersState> emit,
  ) async {
    try {
      await repository.insertMember(event.member);
      final members = await repository.getAllMembers();
      emit(MembersLoaded(members));
    } catch (e) {
      emit(MembersError('Failed to add member'));
    }
  }

  Future<void> _onUpdateMember(
    UpdateMember event,
    Emitter<MembersState> emit,
  ) async {
    try {
      await repository.updateMember(event.member);
      final members = await repository.getAllMembers();
      emit(MembersLoaded(members));
    } catch (e) {
      emit(MembersError('Failed to update member'));
    }
  }

  Future<void> _onDeleteMember(
    DeleteMember event,
    Emitter<MembersState> emit,
  ) async {
    try {
      await repository.deleteMember(event.memberId);
      final members = await repository.getAllMembers();
      emit(MembersLoaded(members));
    } catch (e) {
      emit(MembersError('Failed to delete member'));
    }
  }
}
