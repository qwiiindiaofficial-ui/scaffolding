// lib/screens/home/Staff Management/AttendeanceSetting.dart
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';
import 'package:scaffolding_sale/utils/colors.dart';

class AttendanceSettingsScreen extends StatefulWidget {
  const AttendanceSettingsScreen({super.key});
  @override
  _AttendanceSettingsScreenState createState() =>
      _AttendanceSettingsScreenState();
}

class _AttendanceSettingsScreenState extends State<AttendanceSettingsScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);
  List<bool> _workingDays = [
    true,
    true,
    true,
    true,
    true,
    true,
    false
  ]; // Mon to Sun
  String _locationMode = 'Manually';
  bool _attendanceViewEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    if (settings != null) {
      setState(() {
        _startTime = settings.startTime;
        _endTime = settings.endTime;
        _workingDays = settings.workingDays;
        _locationMode = settings.locationMode;
        _attendanceViewEnabled = settings.allowStaffView;
      });
    }
  }

  Future<void> _saveSettings() async {
    final settings = AttendanceSettings(
      startTime: _startTime,
      endTime: _endTime,
      workingDays: _workingDays,
      locationMode: _locationMode,
      allowStaffView: _attendanceViewEnabled,
    );
    await SettingsService.saveSettings(settings);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings Saved!')));
    Navigator.pop(context);
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Attendance Settings',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shift Timings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: () => _selectTime(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'From', border: OutlineInputBorder()),
                    child: Text(_startTime.format(context)),
                  ),
                )),
                const SizedBox(width: 16),
                const Text('To'),
                const SizedBox(width: 16),
                Expanded(
                    child: InkWell(
                  onTap: () => _selectTime(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'To', border: OutlineInputBorder()),
                    child: Text(_endTime.format(context)),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Working Days',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return GestureDetector(
                  onTap: () => setState(
                      () => _workingDays[index] = !_workingDays[index]),
                  child: buildDayButton(days[index], _workingDays[index]),
                );
              }),
            ),
            // ... Other settings UI...
            const SizedBox(height: 340),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.kSecondaryThemeColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 170),
                ),
                child: const Text('Done',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDayButton(String day, bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(day,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      ),
    );
  }
}
