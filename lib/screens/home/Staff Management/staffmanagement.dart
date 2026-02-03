// lib/screens/home/Staff Management/StaffManagement.dart
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';
import 'Add Staff.dart';
import 'Attendance.dart';
import 'AttendeanceSetting.dart';
import 'Attendence Management.dart';
import 'Name.dart'; // Yeh staff profile page hoga

class StaffManagement extends StatefulWidget {
  const StaffManagement({Key? key}) : super(key: key);

  @override
  _StaffManagementState createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  List<Staff> _staffList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final staffList = await StaffService.getStaffList();
    setState(() {
      _staffList = staffList;
      _isLoading = false;
    });
  }

  void _onPopupMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'Attendence Management':
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AttendenceManagement()));
        break;
      case 'Attendence Setting':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AttendanceSettingsScreen()));
        break;
      case 'Attendence':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Attendance()));
        break;
      case 'Add Staff':
        // Add Staff page par jaane aur wapas aane par list refresh karein
        Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddStaff()))
            .then((_) => _loadStaff());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Staff Management",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _onPopupMenuItemSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Attendence', child: Text("Attendence")),
              PopupMenuItem(
                  value: 'Attendence Setting',
                  child: Text("Attendence Setting")),
              PopupMenuItem(
                  value: 'Attendence Management',
                  child: Text("Attendence Management")),
              PopupMenuItem(value: 'Add Staff', child: Text("Add Staff")),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staffList.isEmpty
              ? const Center(
                  child: Text(
                      "No staff added yet. Click 'Add Staff' from the menu to begin."))
              : ListView.separated(
                  itemCount: _staffList.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Colors.grey),
                  itemBuilder: (context, index) {
                    final staff = _staffList[index];
                    return ListTile(
                      onTap: () {
                        // Staff profile page par navigate karein
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Name(staff: staff)));
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        radius: 25,
                        child: Text(
                          staff.name.isNotEmpty
                              ? staff.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(staff.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      subtitle: Text(staff.designation),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    );
                  },
                ),
    );
  }
}
