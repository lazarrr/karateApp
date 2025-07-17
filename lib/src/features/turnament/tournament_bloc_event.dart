import 'package:karate_club_app/src/models/turnament.dart';

/// Base class for all tournament‑related events
abstract class TournamentsEvent {}

/// Load a (paged) list of tournaments, optionally filtered by name/location
class LoadTournaments extends TournamentsEvent {
  final int offset;
  final int limit;
  final String term; // search term for name or location

  LoadTournaments({
    this.offset = 0,
    this.limit = 5,
    this.term = '',
  });
}

/// Ask the repository for the total number of tournaments
class GetTotalCountOfTournaments extends TournamentsEvent {}

/// Insert a new tournament
class AddTournament extends TournamentsEvent {
  final Tournament tournament;
  AddTournament(this.tournament);
}

class AddMembersToTournament extends TournamentsEvent {
  final List<int> membersIds;
  final int tournamentId;

  AddMembersToTournament(this.membersIds, this.tournamentId);
}

class RemoveMembersFromTournament extends TournamentsEvent {
  final List<int> membersIds;
  final int tournamentId;

  RemoveMembersFromTournament(this.membersIds, this.tournamentId);
}

/// Update an existing tournament
class UpdateTournament extends TournamentsEvent {
  final Tournament tournament;
  UpdateTournament(this.tournament);
}

/// Delete a tournament by its ID
class DeleteTournament extends TournamentsEvent {
  final int tournamentId;
  DeleteTournament(this.tournamentId);
}

class GetMembersOfTournament extends TournamentsEvent {
  final int tournamentId;

  GetMembersOfTournament(this.tournamentId);
}
