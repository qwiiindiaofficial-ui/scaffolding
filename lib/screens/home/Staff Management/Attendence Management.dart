// lib/screens/home/Staff Management/AttendenceManagement.dart
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/holiday.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/leave.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/selfie.dart';

class AttendenceManagement extends StatelessWidget {
  const AttendenceManagement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Attendence Management",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildMenuOption(
              context,
              icon: Icons.camera_alt_outlined,
              title: 'Selfie Attendance',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SelfieAttendancePage())),
            ),
            const Divider(),
            _buildMenuOption(
              context,
              icon: Icons.textsms_outlined,
              title: 'Leaves Management', // Renamed for clarity
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LeaveRequestPage())),
            ),
            const Divider(),
            _buildMenuOption(
              context,
              icon: Icons.featured_play_list_sharp,
              title: 'Holiday List',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HolidayListPage())),
            ),
            const Divider(),
            // Leaves Details ke liye abhi koi page nahi banaya, aap bana sakte hain
            // iska logic LeaveService se data fetch karke dikhana hoga.
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.teal.shade50,
          child: Icon(icon, size: 25, color: Colors.teal),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
