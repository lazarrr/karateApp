import 'package:karate_club_app/src/models/db/database_helper.dart';
import 'package:karate_club_app/src/models/turnament.dart';
import 'package:sqflite/sqflite.dart';

class TournamentsRepository {
  final DatabaseHelper dbHelper;
  TournamentsRepository(this.dbHelper);

  /* ─────────────────────────────  CRUD  ───────────────────────────── */

  /// Add a new tournament
  Future<int> insertTournament(Tournament tournament) async {
    final db = await dbHelper.database;
    return await db.insert('tournaments', tournament.toMap());
  }

  /// List tournaments with optional name/location search + pagination
  Future<List<Tournament>> getAllTournaments(
      {int offset = 0, int limit = 8, String term = ''}) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'tournaments',
      where: term.isNotEmpty ? 'name LIKE ? OR location LIKE ?' : null,
      whereArgs: term.isNotEmpty ? ['%$term%', '%$term%'] : null,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(Tournament.fromMap).toList();
  }

  /// Update an existing tournament
  Future<int> updateTournament(Tournament tournament) async {
    final db = await dbHelper.database;
    return await db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  /// Delete a tournament
  Future<int> deleteTournament(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Count all tournaments (useful for pagination)
  Future<int> getTotalCountOfTournaments() async {
    final db = await dbHelper.database;
    final res = await db.rawQuery('SELECT COUNT(*) AS count FROM tournaments');
    return Sqflite.firstIntValue(res) ?? 0;
  }
}
