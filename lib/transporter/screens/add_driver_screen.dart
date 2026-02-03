import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transporter_models.dart';
import '../services/transporter_service.dart';

class AddDriverScreen extends StatefulWidget {
  final String transporterId;
  const AddDriverScreen({super.key, required this.transporterId});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  DateTime? _selectedExpiryDate;

  // Vehicle numbers list
  final List<String> _vehicleNumbers = ['DL12345'];
  String? _selectedVehicle;

  void _saveDriver() {
    if (_formKey.currentState!.validate()) {
      final newDriver = Driver(
        name: _nameController.text,
        phone: _phoneController.text,
        license: DrivingLicense(
          licenseNumber: _licenseNumberController.text,
          expiryDate: _selectedExpiryDate!,
        ),
        // Agar driver model me vehicle field hai to use bhi pass karo
        // vehicleNumber: _selectedVehicle,
      );

      TransporterService()
          .addDriverToTransporter(widget.transporterId, newDriver);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Driver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Driver Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _licenseNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Driving License Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),

              // Vehicle dropdown
              DropdownButtonFormField<String>(
                value: _selectedVehicle,
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
                items: _vehicleNumbers
                    .map((vehicle) => DropdownMenuItem(
                          value: vehicle,
                          child: Text(vehicle),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedVehicle = val;
                  });
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _licenseExpiryController,
                decoration: const InputDecoration(
                    labelText: 'License Expiry Date',
                    suffixIcon: Icon(Icons.calendar_month)),
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050));
                  if (picked != null) {
                    setState(() {
                      _selectedExpiryDate = picked;
                      _licenseExpiryController.text =
                          DateFormat.yMMMd().format(picked);
                    });
                  }
                },
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                  onPressed: _saveDriver, child: const Text('Save Driver')),
            ],
          ),
        ),
      ),
    );
  }
}
