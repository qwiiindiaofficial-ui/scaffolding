import 'dart:convert';
import 'package:flutter/material.dart';

// No Hive imports or annotations are needed anymore.

class Transporter {
  // All fields remain the same
  final String id;
  String name;
  String contactPerson;
  String phone;
  String email;
  List<Vehicle> vehicles;
  List<Driver> drivers;

  // 1. Create a private constructor that accepts all fields, including the ID.
  Transporter._private({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.vehicles,
    required this.drivers,
  });

  // 2. The main public constructor now uses the private one, generating a NEW id.
  // This is used when creating a brand-new transporter.
  factory Transporter({
    required String name,
    required String contactPerson,
    required String phone,
    required String email,
    List<Vehicle>? vehicles,
    List<Driver>? drivers,
  }) {
    return Transporter._private(
      id: UniqueKey().toString(), // Generates a new unique ID
      name: name,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      vehicles: vehicles ?? [],
      drivers: drivers ?? [],
    );
  }

  // --- THIS IS THE CRITICAL FIX ---
  // 3. The fromJson factory now also uses the private constructor, but it
  // passes the ID from the saved JSON data, preserving it.
  factory Transporter.fromJson(Map<String, dynamic> json) {
    return Transporter._private(
      id: json['id'], // Use the saved ID from JSON
      name: json['name'],
      contactPerson: json['contactPerson'],
      phone: json['phone'],
      email: json['email'],
      vehicles:
          (json['vehicles'] as List).map((v) => Vehicle.fromJson(v)).toList(),
      drivers:
          (json['drivers'] as List).map((d) => Driver.fromJson(d)).toList(),
    );
  }

  // The toJson method remains the same
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
        'email': email,
        'vehicles': vehicles.map((v) => v.toJson()).toList(),
        'drivers': drivers.map((d) => d.toJson()).toList(),
      };
}

// ... (Vehicle, Driver, and DrivingLicense classes are unchanged) ...
class Vehicle {
  final String id;
  String vehicleNumber;
  String vehicleType;
  String capacity;

  Vehicle({
    required this.vehicleNumber,
    required this.vehicleType,
    required this.capacity,
  }) : id = UniqueKey().toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
        'capacity': capacity,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        vehicleNumber: json['vehicleNumber'],
        vehicleType: json['vehicleType'],
        capacity: json['capacity'],
      );
}

class Driver {
  final String id;
  String name;
  String phone;
  DrivingLicense license;

  Driver({
    required this.name,
    required this.phone,
    required this.license,
  }) : id = UniqueKey().toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'license': license.toJson(),
      };

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        name: json['name'],
        phone: json['phone'],
        license: DrivingLicense.fromJson(json['license']),
      );
}

class DrivingLicense {
  String licenseNumber;
  DateTime expiryDate;

  DrivingLicense({
    required this.licenseNumber,
    required this.expiryDate,
  });

  Map<String, dynamic> toJson() => {
        'licenseNumber': licenseNumber,
        // Convert DateTime to a string format for JSON
        'expiryDate': expiryDate.toIso8601String(),
      };

  factory DrivingLicense.fromJson(Map<String, dynamic> json) => DrivingLicense(
        licenseNumber: json['licenseNumber'],
        // Parse the string back to a DateTime object
        expiryDate: DateTime.parse(json['expiryDate']),
      );
}
