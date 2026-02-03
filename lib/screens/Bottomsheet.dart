import 'dart:ui';

import 'package:flutter/material.dart';

class Bottomsheet extends StatelessWidget {
  const Bottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AC No: 94 (8744990555)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'GC-12 Apartment Owners Association, Same\n8744990555,8383052169',
                style: const TextStyle(fontSize: 14.0),
              ),
              Divider(),
              const SizedBox(height: 16.0),
              _buildListItem(
                  icon: Icons.attach_money_outlined,
                  label: 'View Payment',
                  color: Colors.green),
              _buildListItem(
                  icon: Icons.broken_image_outlined,
                  label: 'Lost or damaged',
                  color: Colors.red),
              _buildListItem(
                  icon: Icons.receipt_long,
                  label: 'Other charges',
                  color: Colors.blue),
              _buildListItem(
                  icon: Icons.delivery_dining,
                  label: 'Transport',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.settings_suggest,
                  label: 'Service Area',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.edit,
                  label: 'Account notes',
                  color: Colors.black),
              Divider(),
              _buildListItem(
                  icon: Icons.edit, label: 'Edit Bill', color: Colors.black),
              _buildListItem(
                  icon: Icons.star_border,
                  label: 'View/Edit Rate',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.percent_outlined,
                  label: 'One Day Discount Setting',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'View bill till Today',
                  color: Colors.teal),
              Divider(),
              _buildListItem(
                  icon: Icons.calendar_today,
                  label: 'View bill till a date',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.receipt,
                  label: 'Performa Invoice',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.receipt_long,
                  label: 'Create/View/ledger Bills',
                  color: Colors.red),
              // _buildListItem(
              //     icon: Icons.print, label: 'Print Bill', color: Colors.black),
              _buildListItem(
                  icon: Icons.notifications_active_outlined,
                  label: 'Reminders',
                  color: Colors.black),
              const SizedBox(height: 16.0),
              const ListTile(
                leading: Icon(Icons.check_circle),
                title: Text(
                  'You Can Buy From Another Vender',
                ),
              ),
              _buildListItem(
                  icon: Icons.receipt, label: 'Slips', color: Colors.black),
              Divider(),
              _buildListItem(
                  icon: Icons.lock_outline,
                  label: 'Close Account',
                  color: Colors.black),
              _buildListItem(
                  icon: Icons.delete, label: 'Delete', color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(
      {required IconData icon, required String label, required Color color}) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
    );
  }
}
