import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transporter_models.dart';

class TransporterService {
  static const _kTransportersKey = 'transporters_data';

  // Helper method to get the list from storage
  Future<List<Transporter>> getTransporters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transportersString = prefs.getString(_kTransportersKey);

    if (transportersString != null) {
      final List<dynamic> decodedJson = jsonDecode(transportersString);
      return decodedJson.map((json) => Transporter.fromJson(json)).toList();
    }
    return [];
  }

  // Helper method to save the list to storage
  Future<void> _saveTransporters(List<Transporter> transporters) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      transporters.map((transporter) => transporter.toJson()).toList(),
    );
    await prefs.setString(_kTransportersKey, encodedData);
  }

  Future<void> addTransporter(Transporter transporter) async {
    final transporters = await getTransporters();
    transporters.add(transporter);
    await _saveTransporters(transporters);
  }

  Future<void> addVehicleToTransporter(
      String transporterId, Vehicle vehicle) async {
    final transporters = await getTransporters();
    final transporterIndex =
        transporters.indexWhere((t) => t.id == transporterId);
    if (transporterIndex != -1) {
      transporters[transporterIndex].vehicles.add(vehicle);
      await _saveTransporters(transporters);
    }
  }

  Future<void> addDriverToTransporter(
      String transporterId, Driver driver) async {
    final transporters = await getTransporters();
    final transporterIndex =
        transporters.indexWhere((t) => t.id == transporterId);
    if (transporterIndex != -1) {
      transporters[transporterIndex].drivers.add(driver);
      await _saveTransporters(transporters);
    }
  }
}
