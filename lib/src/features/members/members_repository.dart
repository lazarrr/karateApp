import 'package:karate_club_app/src/models/db/database_helper.dart';
import 'package:karate_club_app/src/models/member.dart';

class MemberRepository {
  final DatabaseHelper dbHelper;

  MemberRepository(this.dbHelper);

  // Create a new member
  Future<int> insertMember(Member member) async {
    final db = await dbHelper.database;
    return await db.insert('members', member.toMap());
  }

  // Get all members
  Future<List<Member>> getAllMembers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('members');
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

  // Search members by name
  Future<List<Member>> searchMembers(String query) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'first_name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  // Filter members by belt color
  Future<List<Member>> filterByBelt(String beltColor) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'members',
      where: 'belt_color = ?',
      whereArgs: [beltColor],
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }
}
