import 'package:karate_club_app/src/models/db/database_helper.dart';
import 'package:karate_club_app/src/models/member.dart';
import 'package:sqflite/sqflite.dart';

class MemberRepository {
  final DatabaseHelper dbHelper;

  MemberRepository(this.dbHelper);

  // Create a new member
  Future<int> insertMember(Member member) async {
    final db = await dbHelper.database;
    return await db.insert('members', member.toMap());
  }

  // Get all members
  Future<List<Member>> getAllMembers(
      {int offset = 0, int limit = 5, String name = ''}) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: name.isNotEmpty ? 'first_name LIKE ? OR last_name LIKE ?' : null,
      whereArgs: name.isNotEmpty ? ['%$name%', '%$name%'] : null,
      limit: limit,
      offset: offset,
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  // Get a member by ID
  Future<Member?> getMemberById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }

  // Update a member
  Future<int> updateMember(Member member) async {
    final db = await dbHelper.database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // Delete a member
  Future<int> deleteMember(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalCountOfMembers() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM members',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> addPayment(int memberId, int month) async {
    final db = await dbHelper.database;
    await db.insert(
      'payments',
      {'member_id': memberId, 'month': month},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<int>> getPaymentsForMember(int memberId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    return maps.map((map) => map['month'] as int).toList();
  }
}
