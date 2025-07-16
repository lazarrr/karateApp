import 'package:karate_club_app/src/models/turnament.dart';

/// Base class for all tournament states
abstract class TournamentsState {
  final List<Tournament> tournaments;
  TournamentsState(this.tournaments);
}

/* ─────────────  Common lifecycle states  ───────────── */

class TournamentsInitial extends TournamentsState {
  TournamentsInitial() : super(const []);
}

class TournamentsLoading extends TournamentsState {
  TournamentsLoading(super.current);
}

class TournamentsLoaded extends TournamentsState {
  TournamentsLoaded(super.tournaments);
}

/* ─────────────  Auxiliary states  ───────────── */

class TotalCountOfTournaments extends TournamentsState {
  final int count;
  TotalCountOfTournaments(this.count) : super(const []);
}

class TournamentsError extends TournamentsState {
  final String message;
  TournamentsError(this.message) : super(const []);
}
