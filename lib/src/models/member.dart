class Member {
  final int id;
  final String name;
  final String beltColor;
  final int age;
  final DateTime joinDate;

  Member({
    required this.id,
    required this.name,
    required this.beltColor,
    required this.age,
    required this.joinDate,
  });

  get isPresentToday => null;

  Member copyWith({
    int? id,
    String? name,
    String? beltColor,
    int? age,
    DateTime? joinDate,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      beltColor: beltColor ?? this.beltColor,
      age: age ?? this.age,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
