class Tournament {
  final int id;
  final String name;
  final String location;
  final DateTime date;

  Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
  });

  Tournament copyWith({
    int? id,
    String? name,
    String? location,
    DateTime? date,
  }) =>
      Tournament(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        date: date ?? this.date,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date.toIso8601String(),
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'] as int,
      name: map['name'] as String,
      location: map['location'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }
}
