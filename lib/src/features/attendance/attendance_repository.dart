import 'package:karate_club_app/src/models/db/database_helper.dart';
import 'package:karate_club_app/src/models/member.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceRepository {
  final DatabaseHelper dbHelper;

  AttendanceRepository(this.dbHelper);

  Future<int> getTotalNumberOfPresentMembers() async {
    final currentDate = DateTime.now();
    final db = await dbHelper.database;
    return await db.query(
      'attendance',
      where: 'date = ? and status = 1',
      whereArgs: [currentDate.toIso8601String().split('T').first],
    ).then((value) => value.map((row) => row['member_id']).toSet().length);
  }

  Future<int> getTotalNumberOfAbsentMembers() async {
    final currentDate = DateTime.now();
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM members m
      LEFT JOIN attendance a
        ON m.id = a.member_id AND a.date = ?
      WHERE a.status IS NULL OR a.status = 0
    ''', [currentDate.toIso8601String().split('T').first]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Member>> fetchPresentMembers(
      {int limit = 5, int offset = 0}) async {
    final currentDate = DateTime.now();
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT m.*
      FROM members m
      INNER JOIN attendance a
        ON m.id = a.member_id
      WHERE a.date = ? AND a.status = 1
      LIMIT ? OFFSET ?
    ''', [currentDate.toIso8601String().split('T').first, limit, offset]);

    return result.map((row) => Member.fromMap(row)).toList();
  }

  Future<List<Member>> fetchAbsentMembers(
      {int limit = 5, int offset = 0}) async {
    final currentDate = DateTime.now();
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
      SELECT m.*
      FROM members m
      LEFT JOIN attendance a
        ON m.id = a.member_id
      WHERE (a.date is null OR a.date = ? ) AND (a.status is NULL OR a.status = 0)
      LIMIT ? OFFSET ?
    ''', [currentDate.toIso8601String().split('T').first, limit, offset]);
    return result.map((row) => Member.fromMap(row)).toList();
  }
}
