import 'package:flutter/material.dart';
import 'package:scaffolding_sale/widgets/button.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, String>> users = []; // List to store user details
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? phoneNumber;
  String? details;
  String? selectedRole;

  final roles = ['Admin', 'Editor', 'Viewer']; // Predefined roles
  int? editingIndex; // Index of the user being edited

  void saveUser() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        if (editingIndex == null) {
          // Add new user
          users.add({
            'name': name!,
            'phoneNumber': phoneNumber!,
            'details': details!,
            'role': selectedRole!,
          });
        } else {
          // Update existing user
          users[editingIndex!] = {
            'name': name!,
            'phoneNumber': phoneNumber!,
            'details': details!,
            'role': selectedRole!,
          };
          editingIndex = null; // Reset after editing
        }
      });

      Navigator.of(context).pop(); // Close the modal
    }
  }

  void openUserForm({int? index}) {
    if (index != null) {
      // Populate fields for editing
      final user = users[index];
      name = user['name'];
      phoneNumber = user['phoneNumber'];
      details = user['details'];
      selectedRole = user['role'];
      editingIndex = index;
    } else {
      // Reset fields for adding new user
      name = null;
      phoneNumber = null;
      details = null;
      selectedRole = null;
      editingIndex = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  editingIndex == null ? 'Add User' : 'Edit User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter a name' : null,
                  onSaved: (value) => name = value,
                ),
                TextFormField(
                  initialValue: phoneNumber,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.length != 10
                      ? 'Enter a valid 10-digit number'
                      : null,
                  onSaved: (value) => phoneNumber = value,
                ),
                TextFormField(
                  initialValue: details,
                  decoration: InputDecoration(labelText: 'Details'),
                  maxLines: 3,
                  onSaved: (value) => details = value,
                ),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: roles
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  validator: (value) => value == null ? 'Select a role' : null,
                  onChanged: (value) => selectedRole = value,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveUser,
                  child:
                      Text(editingIndex == null ? 'Add User' : 'Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                users.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Manage Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        'No users added yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(user['name']!),
                          subtitle:
                              Text('${user['phoneNumber']} - ${user['role']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => openUserForm(index: index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteUser(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 16),
            PrimaryButton(
                onTap: () {
                  openUserForm();
                },
                text: "Add User"),
          ],
        ),
      ),
    );
  }
}
