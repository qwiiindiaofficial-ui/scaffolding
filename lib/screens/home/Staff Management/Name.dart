// lib/screens/home/Staff Management/Name.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';

class Name extends StatelessWidget {
  final Staff staff;
  const Name({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(staff.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: staff.photoPath != null
                    ? FileImage(File(staff.photoPath!))
                    : null,
                child: staff.photoPath == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Designation', staff.designation),
                    _buildDetailRow('Mobile', staff.mobile),
                    _buildDetailRow('Address', staff.address),
                    _buildDetailRow('Gender', staff.gender),
                    _buildDetailRow('Date of Birth', staff.dob),
                    _buildDetailRow(
                        'Expense Allowance', '₹${staff.expenseAllowance}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
