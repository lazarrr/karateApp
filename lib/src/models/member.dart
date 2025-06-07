import 'package:karate_club_app/src/models/db/database_helper.dart';

class Member {
  int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String beltColor;
  final DateTime joinDate;
  bool isActive;
  DateTime? lastPaymentDate;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.beltColor,
    required this.joinDate,
    this.isActive = true,
    this.lastPaymentDate,
  });

  // Convert a Member into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': DatabaseHelper.formatDate(dateOfBirth),
      'belt_color': beltColor,
      'join_date': DatabaseHelper.formatDate(joinDate),
      'is_active': isActive ? 1 : 0,
      'last_payment_date': lastPaymentDate != null
          ? DatabaseHelper.formatDate(lastPaymentDate!)
          : null,
    };
  }

  Member copyWith({
    int? id,
    String? name,
    String? beltColor,
    int? age,
    DateTime? joinDate,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: name ?? this.firstName,
      beltColor: beltColor ?? this.beltColor,
      dateOfBirth: dateOfBirth,
      lastName: lastName ?? this.lastName,
      isActive: isActive,
      lastPaymentDate: lastPaymentDate,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  // Create a Member from a Map
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      dateOfBirth: DatabaseHelper.parseDate(map['date_of_birth']),
      beltColor: map['belt_color'],
      joinDate: DatabaseHelper.parseDate(map['join_date']),
      isActive: map['is_active'] == 1,
      lastPaymentDate: map['last_payment_date'] != null
          ? DatabaseHelper.parseDate(map['last_payment_date'])
          : null,
    );
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
