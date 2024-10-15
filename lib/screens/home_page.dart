// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/person_provider.dart';
import '../models/person.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  // For query by ID
  final TextEditingController _queryIdController = TextEditingController();
  String _queryResult = '';

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _nameController.dispose();
    _ageController.dispose();
    _idController.dispose();
    _queryIdController.dispose();
    super.dispose();
  }

  // Insert a new person
  void _insertPerson(BuildContext context) async {
    String name = _nameController.text.trim();
    int? age = int.tryParse(_ageController.text.trim());
    if (name.isEmpty || age == null) {
      _showSnackBar(context, 'Please enter a valid name and age.');
      return;
    }

    await Provider.of<PersonProvider>(context, listen: false)
        .addPerson(name, age);
    _showSnackBar(context, 'Inserted $name, Age: $age');
    _nameController.clear();
    _ageController.clear();
  }

  // Update a person
  void _updatePerson(BuildContext context) async {
    int? id = int.tryParse(_idController.text.trim());
    String name = _nameController.text.trim();
    int? age = int.tryParse(_ageController.text.trim());
    if (id == null || name.isEmpty || age == null) {
      _showSnackBar(context, 'Please enter valid ID, name, and age.');
      return;
    }

    await Provider.of<PersonProvider>(context, listen: false)
        .updatePerson(id, name, age);
    _showSnackBar(context, 'Updated ID $id to $name, Age: $age');
    _idController.clear();
    _nameController.clear();
    _ageController.clear();
  }

  // Delete a person
  void _deletePerson(BuildContext context) async {
    int? id = int.tryParse(_idController.text.trim());
    if (id == null) {
      _showSnackBar(context, 'Please enter a valid ID.');
      return;
    }

    await Provider.of<PersonProvider>(context, listen: false).deletePerson(id);
    _showSnackBar(context, 'Deleted person with ID: $id');
    _idController.clear();
  }

  // Delete all persons
  void _deleteAllPersons(BuildContext context) async {
    await Provider.of<PersonProvider>(context, listen: false).deleteAllPersons();
    _showSnackBar(context, 'Deleted all records.');
  }

  // Query person by ID
  void _queryById(BuildContext context) async {
    int? id = int.tryParse(_queryIdController.text.trim());
    if (id == null) {
      _showSnackBar(context, 'Please enter a valid ID.');
      return;
    }

    Person? person =
        await Provider.of<PersonProvider>(context, listen: false)
            .getPersonById(id);
    setState(() {
      if (person != null) {
        _queryResult = 'ID: ${person.id}, Name: ${person.name}, Age: ${person.age}';
      } else {
        _queryResult = 'No record found with ID: $id';
      }
    });
    _queryIdController.clear();
  }

  // Helper method to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Show dialog for editing
  void _showEditDialog(BuildContext context, Person person) {
    final TextEditingController editNameController =
        TextEditingController(text: person.name);
    final TextEditingController editAgeController =
        TextEditingController(text: person.age.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: editAgeController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                String newName = editNameController.text.trim();
                int? newAge = int.tryParse(editAgeController.text.trim());
                if (newName.isEmpty || newAge == null) {
                  _showSnackBar(context, 'Please enter valid name and age.');
                  return;
                }

                await Provider.of<PersonProvider>(context, listen: false)
                    .updatePerson(person.id!, newName, newAge);
                _showSnackBar(context, 'Updated to $newName, Age: $newAge');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog for deletion
  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Person'),
          content: Text('Are you sure you want to delete person with ID: $id?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await Provider.of<PersonProvider>(context, listen: false)
                    .deletePerson(id);
                _showSnackBar(context, 'Deleted person with ID: $id');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Build the list of persons
  Widget _buildPersonList() {
    return Consumer<PersonProvider>(
      builder: (context, provider, child) {
        if (provider.persons.isEmpty) {
          return const Center(child: Text('No records found.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.persons.length,
          itemBuilder: (context, index) {
            Person person = provider.persons[index];
            return ListTile(
              leading: CircleAvatar(child: Text(person.id.toString())),
              title: Text(person.name),
              subtitle: Text('Age: ${person.age}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      _showEditDialog(context, person);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, person.id!);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQFlite Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PersonProvider>(context, listen: false).fetchPersons();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Insert Section
            const Text(
              'Insert New Person',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () => _insertPerson(context),
              child: const Text('Insert'),
            ),
            const Divider(),

            // Update/Delete Section
            const Text(
              'Update/Delete Person',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'New Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'New Age'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updatePerson(context),
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _deletePerson(context),
                    child: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Query Section
            const Text(
              'Query Person by ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _queryIdController,
              decoration: const InputDecoration(labelText: 'ID'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () => _queryById(context),
              child: const Text('Query'),
            ),
            Text(
              _queryResult,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const Divider(),

            // Delete All Section
            ElevatedButton(
              onPressed: () => _deleteAllPersons(context),
              child: const Text('Delete All Records'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
            const Divider(),

            // Display List of Persons
            const Text(
              'All Persons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildPersonList(),
          ],
        ),
      ),
    );
  }
}
