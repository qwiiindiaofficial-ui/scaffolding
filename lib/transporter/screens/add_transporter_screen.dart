import 'package:flutter/material.dart';
import '../models/transporter_models.dart';
import '../services/transporter_service.dart';

class AddTransporterScreen extends StatefulWidget {
  const AddTransporterScreen({super.key});

  @override
  State<AddTransporterScreen> createState() => _AddTransporterScreenState();
}

class _AddTransporterScreenState extends State<AddTransporterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  void _saveTransporter() {
    if (_formKey.currentState!.validate()) {
      final newTransporter = Transporter(
        name: _nameController.text,
        contactPerson: _contactPersonController.text,
        phone: _phoneController.text,
        email: _emailController.text,
      );
      TransporterService().addTransporter(newTransporter);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Transporter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Transporter Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _contactPersonController,
                  decoration:
                      const InputDecoration(labelText: 'Contact Person'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saveTransporter,
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Save Transporter'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
