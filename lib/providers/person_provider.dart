// lib/providers/person_provider.dart

import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/person.dart';

class PersonProvider with ChangeNotifier {
  List<Person> _persons = [];

  List<Person> get persons => _persons;

  // Fetch all persons from the database
  Future<void> fetchPersons() async {
    final data = await DatabaseHelper.instance.queryAllRows();
    _persons = data.map((item) => Person.fromMap(item)).toList();
    notifyListeners();
  }

  // Add a new person
  Future<void> addPerson(String name, int age) async {
    Person person = Person(name: name, age: age);
    int id = await DatabaseHelper.instance.insert(person.toMap());
    person = Person(id: id, name: name, age: age);
    _persons.add(person);
    notifyListeners();
  }

  // Update a person
  Future<void> updatePerson(int id, String name, int age) async {
    Person person = Person(id: id, name: name, age: age);
    await DatabaseHelper.instance.update(person.toMap());
    int index = _persons.indexWhere((p) => p.id == id);
    if (index != -1) {
      _persons[index] = person;
      notifyListeners();
    }
  }

  // Delete a person
  Future<void> deletePerson(int id) async {
    await DatabaseHelper.instance.delete(id);
    _persons.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // Delete all persons
  Future<void> deleteAllPersons() async {
    await DatabaseHelper.instance.deleteAll();
    _persons.clear();
    notifyListeners();
  }

  // Query person by ID
  Future<Person?> getPersonById(int id) async {
    final data = await DatabaseHelper.instance.queryById(id);
    if (data != null) {
      return Person.fromMap(data);
    }
    return null;
  }
}
