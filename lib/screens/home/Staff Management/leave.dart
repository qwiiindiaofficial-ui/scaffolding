// lib/staff_management/features/leave_request_page.dart
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';
import 'package:uuid/uuid.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  _LeaveRequestPageState createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  List<Staff> _staffList = [];
  Staff? _selectedStaff;
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    _staffList = await StaffService.getStaffList();
    setState(() {});
  }

  void _submitLeaveRequest() {
    if (_selectedStaff == null) return;
    final request = LeaveRequest(
      id: const Uuid().v4(),
      staffId: _selectedStaff!.id,
      staffName: _selectedStaff!.name,
      fromDate: _fromDate,
      toDate: _toDate,
      reason: _reasonController.text,
    );
    LeaveService.addLeaveRequest(request);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request submitted!")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Leaves")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // DropdownButtonFormField<Staff>(
            //   value: _selectedStaff,
            //   hint: const Text("Select Staff"),
            //   items: _staffList
            //       .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
            //       .toList(),
            //   onChanged: (val) => setState(() => _selectedStaff = val),
            // ),
            // TextFormField(
            //     controller: _reasonController,
            //     decoration:
            //         const InputDecoration(labelText: "Reason for Leave")),
            // ElevatedButton(
            //     onPressed: _submitLeaveRequest,
            //     child: const Text("Apply for Leave")),
            // const Divider(height: 40),
            const Text("Pending Requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: FutureBuilder<List<LeaveRequest>>(
                future: LeaveService.getLeaveRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final requests = snapshot.data!
                      .where((r) => r.status == LeaveStatus.Pending)
                      .toList();
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return Card(
                        child: ListTile(
                          title: Text(req.staffName),
                          subtitle: Text(req.reason),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () {
                                    LeaveService.updateLeaveRequestStatus(
                                        req.id, LeaveStatus.Approved);
                                    setState(() {});
                                  }),
                              IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    LeaveService.updateLeaveRequestStatus(
                                        req.id, LeaveStatus.Rejected);
                                    setState(() {});
                                  }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
