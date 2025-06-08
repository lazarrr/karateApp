import 'package:karate_club_app/src/models/db/database_helper.dart';

class Member {
  int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String beltColor;

  Member(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.dateOfBirth,
      required this.beltColor});

  // Convert a Member into a Map
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': DatabaseHelper.formatDate(dateOfBirth),
      'belt_color': beltColor
    };
  }

  Member copyWith(
      {int? id,
      String? firstName,
      String? lastName,
      required DateTime dateOfBirth,
      String? beltColor}) {
    return Member(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        beltColor: beltColor ?? this.beltColor,
        dateOfBirth: dateOfBirth);
  }

  // Create a Member from a Map
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
        id: map['id'],
        firstName: map['first_name'],
        lastName: map['last_name'],
        dateOfBirth: DatabaseHelper.parseDate(map['date_of_birth']),
        beltColor: map['belt_color']);
  }

  // Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get fullName => '$firstName $lastName';
}
