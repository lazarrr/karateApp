import 'package:karate_club_app/src/models/member.dart';

class MembersRepository {
  final List<Member> _mockMembers = [
    Member(
      id: '1',
      name: 'John Doe',
      beltColor: 'Black',
      age: 25,
      joinDate: DateTime(2022, 1, 15),
    ),
    Member(
      id: '2',
      name: 'Jane Smith',
      beltColor: 'Brown',
      age: 18,
      joinDate: DateTime(2023, 3, 10),
    ),
    Member(
      id: '3',
      name: 'Mike Johnson',
      beltColor: 'Blue',
      age: 30,
      joinDate: DateTime(2021, 11, 5),
    ),
  ];

  Future<List<Member>> getMembers({
    int page = 1,
    int limit = 10,
    String? beltColor,
    bool? activeOnly,
    bool? paymentDue,
  }) {
    // TODO: implement getMembers
    throw UnimplementedError();
  }

  Future<List<Member>> getAllMembers() async {
    // Simulate network/database delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockMembers.toList();
  }

  Future<void> addMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockMembers.add(member);
  }

  Future<void> updateMember(Member updatedMember) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockMembers.indexWhere((m) => m.id == updatedMember.id);
    if (index != -1) {
      _mockMembers[index] = updatedMember;
    }
  }

  Future<void> deleteMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockMembers.removeWhere((member) => member.id == memberId);
  }

  // Optional: For search functionality
  Future<List<Member>> searchMembers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockMembers
        .where((member) =>
            member.name.toLowerCase().contains(query.toLowerCase()) ||
            member.beltColor.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
