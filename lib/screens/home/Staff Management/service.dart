// lib/staff_management/staff_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Staff ka Data Model
class Staff {
  final String id;
  String name;
  String mobile;
  String address;
  String gender;
  String dob;
  String? photoPath;
  String? aadharPath;
  String designation;
  double expenseAllowance;
  double areaRate;
  String areaUnit;
  double timeRate;
  String timeUnit;

  Staff({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
    required this.gender,
    required this.dob,
    this.photoPath,
    this.aadharPath,
    required this.designation,
    required this.expenseAllowance,
    required this.areaRate,
    required this.areaUnit,
    required this.timeRate,
    required this.timeUnit,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'address': address,
        'gender': gender,
        'dob': dob,
        'photoPath': photoPath,
        'aadharPath': aadharPath,
        'designation': designation,
        'expenseAllowance': expenseAllowance,
        'areaRate': areaRate,
        'areaUnit': areaUnit,
        'timeRate': timeRate,
        'timeUnit': timeUnit,
      };

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
        id: json['id'],
        name: json['name'],
        mobile: json['mobile'],
        address: json['address'],
        gender: json['gender'],
        dob: json['dob'],
        photoPath: json['photoPath'],
        aadharPath: json['aadharPath'],
        designation: json['designation'],
        expenseAllowance: json['expenseAllowance'],
        areaRate: json['areaRate'],
        areaUnit: json['areaUnit'],
        timeRate: json['timeRate'],
        timeUnit: json['timeUnit'],
      );
}

// 2. Attendance Settings ka Data Model
class AttendanceSettings {
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<bool> workingDays; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
  String locationMode;
  bool allowStaffView;

  AttendanceSettings({
    required this.startTime,
    required this.endTime,
    required this.workingDays,
    required this.locationMode,
    required this.allowStaffView,
  });

  Map<String, dynamic> toJson() => {
        'startTime': '${startTime.hour}:${startTime.minute}',
        'endTime': '${endTime.hour}:${endTime.minute}',
        'workingDays': workingDays,
        'locationMode': locationMode,
        'allowStaffView': allowStaffView,
      };

  factory AttendanceSettings.fromJson(Map<String, dynamic> json) =>
      AttendanceSettings(
        startTime: TimeOfDay(
            hour: int.parse(json['startTime'].split(':')[0]),
            minute: int.parse(json['startTime'].split(':')[1])),
        endTime: TimeOfDay(
            hour: int.parse(json['endTime'].split(':')[0]),
            minute: int.parse(json['endTime'].split(':')[1])),
        workingDays: List<bool>.from(json['workingDays']),
        locationMode: json['locationMode'],
        allowStaffView: json['allowStaffView'],
      );
}

// 3. Attendance Status (Enum)
enum AttendanceStatus { Present, Absent, HalfDay, Holiday }

// 4. Staff ko manage karne wali Service Class
class StaffService {
  static const _staffKey = 'staff_list';

  static Future<void> addStaff(Staff staff) async {
    final prefs = await SharedPreferences.getInstance();
    final staffList = await getStaffList();
    staffList.add(staff);
    await prefs.setString(
        _staffKey, jsonEncode(staffList.map((s) => s.toJson()).toList()));
  }

  static Future<List<Staff>> getStaffList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_staffKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Staff.fromJson(json)).toList();
  }
}

// 5. Settings ko manage karne wali Service Class
class SettingsService {
  static const _settingsKey = 'attendance_settings';

  static Future<void> saveSettings(AttendanceSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  static Future<AttendanceSettings?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString == null) return null;
    return AttendanceSettings.fromJson(jsonDecode(jsonString));
  }
}

// 6. Attendance ko manage karne wali Service Class
class AttendanceService {
  static Future<void> saveAttendance(
      String staffId, DateTime date, AttendanceStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'attendance_${staffId}_${date.year}_${date.month}';
    final monthData =
        await getAttendanceForMonth(staffId, date.year, date.month);
    monthData[date.day.toString()] = status.index; // Store enum index
    await prefs.setString(key, jsonEncode(monthData));
  }

  static Future<Map<String, int>> getAttendanceForMonth(
      String staffId, int year, int month) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'attendance_${staffId}_${year}_${month}';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return {};
    return Map<String, int>.from(jsonDecode(jsonString));
  }
}
// lib/staff_management/staff_service.dart
// ... (Pichhla saara code Staff, StaffService, etc. waise ka waisa rahega)
// Hum bas neeche naye Models aur Services add kar rahe hain.

// ... (Pichhle code ko yahaan paste karein) ...

// 7. Holiday ka Data Model
class Holiday {
  final String id;
  String title;
  DateTime date;

  Holiday({required this.id, required this.title, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
      };

  factory Holiday.fromJson(Map<String, dynamic> json) => Holiday(
        id: json['id'],
        title: json['title'],
        date: DateTime.parse(json['date']),
      );
}

// 8. Leave Request ka Data Model
enum LeaveStatus { Pending, Approved, Rejected }

class LeaveRequest {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  LeaveStatus status;

  LeaveRequest({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.status = LeaveStatus.Pending,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'staffId': staffId,
        'staffName': staffName,
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
        'reason': reason,
        'status': status.index,
      };

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'],
        staffId: json['staffId'],
        staffName: json['staffName'],
        fromDate: DateTime.parse(json['fromDate']),
        toDate: DateTime.parse(json['toDate']),
        reason: json['reason'],
        status: LeaveStatus.values[json['status']],
      );
}

// 9. Holiday ko manage karne wali Service Class
class HolidayService {
  static const _holidayKey = 'holiday_list';

  static Future<void> addHoliday(Holiday holiday) async {
    final holidays = await getHolidays();
    holidays.add(holiday);
    await _saveHolidays(holidays);
  }

  static Future<List<Holiday>> getHolidays() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_holidayKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Holiday.fromJson(json)).toList();
  }

  static Future<void> _saveHolidays(List<Holiday> holidays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _holidayKey, jsonEncode(holidays.map((h) => h.toJson()).toList()));
  }
}

// 10. Leave ko manage karne wali Service Class
class LeaveService {
  static const _leaveKey = 'leave_requests';

  static Future<void> addLeaveRequest(LeaveRequest request) async {
    final requests = await getLeaveRequests();
    requests.add(request);
    await _saveLeaveRequests(requests);
  }

  static Future<void> updateLeaveRequestStatus(
      String requestId, LeaveStatus status) async {
    final requests = await getLeaveRequests();
    final index = requests.indexWhere((req) => req.id == requestId);
    if (index != -1) {
      requests[index].status = status;
      await _saveLeaveRequests(requests);
    }
  }

  static Future<List<LeaveRequest>> getLeaveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_leaveKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => LeaveRequest.fromJson(json)).toList();
  }

  static Future<void> _saveLeaveRequests(List<LeaveRequest> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _leaveKey, jsonEncode(requests.map((r) => r.toJson()).toList()));
  }
}
