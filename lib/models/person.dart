// lib/models/person.dart
import '../database_helper.dart';

class Person {
  final int? id;
  final String name;
  final int age;

  Person({this.id, required this.name, required this.age});

  // Convert a Person into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnAge: age,
    };
  }

  // Extract a Person object from a Map.
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map[DatabaseHelper.columnId],
      name: map[DatabaseHelper.columnName],
      age: map[DatabaseHelper.columnAge],
    );
  }
}
