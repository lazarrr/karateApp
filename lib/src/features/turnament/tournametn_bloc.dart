import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karate_club_app/src/features/turnament/tournament_bloc_event.dart';
import 'package:karate_club_app/src/features/turnament/tournament_bloc_state.dart';
import 'package:karate_club_app/src/features/turnament/tournament_repository.dart';

class TournamentsBloc extends Bloc<TournamentsEvent, TournamentsState> {
  final TournamentsRepository repository;

  TournamentsBloc(this.repository) : super(TournamentsInitial()) {
    on<LoadTournaments>(_onLoadTournaments);
    on<AddTournament>(_onAddTournament);
    on<UpdateTournament>(_onUpdateTournament);
    on<DeleteTournament>(_onDeleteTournament);
    on<GetTotalCountOfTournaments>(_onGetTotalCount);
    on<AddMembersToTournament>(_onAddMembersToTournament);
    on<GetMembersOfTournament>(_onGetMembersOfTournament);
    on<RemoveMembersFromTournament>(_onRemoveMembersFromTournament);
  }

  /* ──────────────────────────────  remove members from tournament  ───────────────────────── */
  Future<void> _onRemoveMembersFromTournament(
    RemoveMembersFromTournament event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      await repository.removeMembersFromTournament(
        event.tournamentId,
        event.membersIds,
      );
      emit(MembersAddedToTournament());
    } catch (e) {
      emit(TournamentsError('Failed to remove members from tournament'));
    }
  }

  /* ──────────────────────────────  get members of tournament  ───────────────────────── */

  Future<void> _onGetMembersOfTournament(
    GetMembersOfTournament event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      final members =
          await repository.getMembersOfTournament(event.tournamentId);
      emit(MembersOfTournamentLoaded(members));
    } catch (e) {
      emit(TournamentsError('Failed to load members of tournament'));
    }
  }

  /* ──────────────────────────────  add members to tournament  ───────────────────────── */

  Future<void> _onAddMembersToTournament(
    AddMembersToTournament event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      await repository.addMembersToTournament(
        event.tournamentId,
        event.membersIds,
      );
      emit(MembersAddedToTournament());
    } catch (e) {
      emit(TournamentsError('Failed to add members to tournament'));
    }
  }

  /* ──────────────────────────────  total count  ───────────────────────── */

  Future<void> _onGetTotalCount(
    GetTotalCountOfTournaments event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      final count = await repository.getTotalCountOfTournaments();
      emit(TotalCountOfTournaments(count));
    } catch (e) {
      emit(TournamentsError('Failed to load total count of tournaments'));
    }
  }

  /* ──────────────────────────────  load list  ─────────────────────────── */

  Future<void> _onLoadTournaments(
    LoadTournaments event,
    Emitter<TournamentsState> emit,
  ) async {
    emit(TournamentsLoading(state.tournaments)); // maintain current list
    try {
      final list = await repository.getAllTournaments(
        offset: event.offset,
        limit: event.limit,
        term: event.term,
      );
      emit(TournamentsLoaded(list));
    } catch (e) {
      emit(TournamentsError('Failed to load tournaments'));
    }
  }

  /* ──────────────────────────────  add  ──────────────────────────────── */

  Future<void> _onAddTournament(
    AddTournament event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      await repository.insertTournament(event.tournament);
      final list = await repository.getAllTournaments();
      emit(TournamentsLoaded(list));
    } catch (e) {
      emit(TournamentsError('Failed to add tournament'));
    }
  }

  /* ──────────────────────────────  update  ───────────────────────────── */

  Future<void> _onUpdateTournament(
    UpdateTournament event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      await repository.updateTournament(event.tournament);
      final list = await repository.getAllTournaments();
      emit(TournamentsLoaded(list));
    } catch (e) {
      emit(TournamentsError('Failed to update tournament'));
    }
  }

  /* ──────────────────────────────  delete  ───────────────────────────── */

  Future<void> _onDeleteTournament(
    DeleteTournament event,
    Emitter<TournamentsState> emit,
  ) async {
    try {
      await repository.deleteTournament(event.tournamentId);
      final list = await repository.getAllTournaments();
      emit(TournamentsLoaded(list));
    } catch (e) {
      emit(TournamentsError('Failed to delete tournament'));
    }
  }
}
