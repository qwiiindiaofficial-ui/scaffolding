import 'package:flutter/material.dart';
import '../models/transporter_models.dart';
import '../services/transporter_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final String transporterId;
  const AddVehicleScreen({super.key, required this.transporterId});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _capacityController = TextEditingController();
  String? _selectedVehicleType;
  final List<String> _vehicleTypes = [
    'Truck',
    'Eicher',
    'Tata Ace',
    'Pickup Van',
    'Trailer',
    'Others',
  ];

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      final newVehicle = Vehicle(
        vehicleNumber: _vehicleNumberController.text,
        vehicleType: _selectedVehicleType!,
        capacity: _capacityController.text,
      );
      TransporterService()
          .addVehicleToTransporter(widget.transporterId, newVehicle);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  maxLength: 11,
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Vehicle Number (e.g., DL1AB1234)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                hint: const Text('Select Vehicle Type'),
                items: _vehicleTypes
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedVehicleType = value),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                      labelText: 'Capacity (e.g., 10 Ton)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 32),
              ElevatedButton(
                  onPressed: _saveVehicle, child: const Text('Save Vehicle')),
            ],
          ),
        ),
      ),
    );
  }
}
