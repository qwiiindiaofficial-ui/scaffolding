// lib/screens/home/Staff Management/Attendance.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

enum AttendanceType { Present, Absent, HalfDay, Holiday, NightShift, Overtime }

class OvertimeData {
  TimeOfDay? inTime;
  TimeOfDay? outTime;

  OvertimeData({this.inTime, this.outTime});

  String get duration {
    if (inTime == null || outTime == null) return "N/A";
    final inMinutes = inTime!.hour * 60 + inTime!.minute;
    final outMinutes = outTime!.hour * 60 + outTime!.minute;
    final diff = outMinutes - inMinutes;
    if (diff < 0) return "Invalid";
    final hours = diff ~/ 60;
    final mins = diff % 60;
    return "${hours}h ${mins}m";
  }
}

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  List<Staff> _staffList = [];
  Staff? _selectedStaff;
  DateTime _selectedMonth = DateTime.now();
  Map<String, List<AttendanceType>> _attendanceData = {};
  Map<String, OvertimeData> _overtimeData = {};
  Map<String, int> _amountData = {"5": 500, "12": -200};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final staff = await StaffService.getStaffList();
    setState(() {
      _staffList = staff;
      if (_staffList.isNotEmpty) {
        _selectedStaff = _staffList.first;
        _loadAttendance();
      } else {
        _isLoading = false;
      }
    });
  }

  Future<void> _loadAttendance() async {
    if (_selectedStaff == null) return;
    setState(() => _isLoading = true);
    // Convert old data format to new multi-status format
    final data = await AttendanceService.getAttendanceForMonth(
        _selectedStaff!.id, _selectedMonth.year, _selectedMonth.month);

    Map<String, List<AttendanceType>> converted = {};
    data.forEach((key, value) {
      converted[key] = [AttendanceType.values[value]];
    });

    setState(() {
      _attendanceData = converted;
      _isLoading = false;
    });
  }

  void _changeMonth(int monthIncrement) {
    setState(() {
      _selectedMonth = DateTime(
          _selectedMonth.year, _selectedMonth.month + monthIncrement, 1);
      _loadAttendance();
    });
  }

  void _showAttendanceSheet(int day) {
    final currentStatuses =
        _attendanceData[day.toString()] ?? [AttendanceType.Absent];
    final currentOvertime = _overtimeData[day.toString()] ?? OvertimeData();
    List<AttendanceType> tempStatuses = List.from(currentStatuses);
    OvertimeData tempOvertime = OvertimeData(
      inTime: currentOvertime.inTime,
      outTime: currentOvertime.outTime,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Day $day - ${DateFormat('MMMM yyyy').format(_selectedMonth)}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Select Status(es):",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AttendanceType.values.map((type) {
                  final isSelected = tempStatuses.contains(type);
                  return FilterChip(
                    label: Text(type.name),
                    selected: isSelected,
                    selectedColor: _getColorForType(type).withOpacity(0.7),
                    onSelected: (selected) async {
                      setModalState(() {
                        if (selected) {
                          if (type == AttendanceType.Absent) {
                            tempStatuses.clear();
                          } else {
                            tempStatuses.remove(AttendanceType.Absent);
                          }
                          tempStatuses.add(type);
                        } else {
                          tempStatuses.remove(type);
                        }
                        if (tempStatuses.isEmpty)
                          tempStatuses.add(AttendanceType.Absent);
                      });

                      // If Overtime is selected, show time pickers
                      if (selected && type == AttendanceType.Overtime) {
                        final inTime = await showTimePicker(
                          context: context,
                          initialTime: tempOvertime.inTime ?? TimeOfDay.now(),
                          helpText: "Select In Time",
                        );
                        if (inTime != null) {
                          final outTime = await showTimePicker(
                            context: context,
                            initialTime:
                                tempOvertime.outTime ?? TimeOfDay.now(),
                            helpText: "Select Out Time",
                          );
                          if (outTime != null) {
                            setModalState(() {
                              tempOvertime.inTime = inTime;
                              tempOvertime.outTime = outTime;
                            });
                          }
                        }
                      }
                    },
                  );
                }).toList(),
              ),

              // Show overtime details if selected
              if (tempStatuses.contains(AttendanceType.Overtime)) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Overtime Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple)),
                          TextButton.icon(
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text("Edit Time"),
                            onPressed: () async {
                              final inTime = await showTimePicker(
                                context: context,
                                initialTime:
                                    tempOvertime.inTime ?? TimeOfDay.now(),
                                helpText: "Select In Time",
                              );
                              if (inTime != null) {
                                final outTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      tempOvertime.outTime ?? TimeOfDay.now(),
                                  helpText: "Select Out Time",
                                );
                                if (outTime != null) {
                                  setModalState(() {
                                    tempOvertime.inTime = inTime;
                                    tempOvertime.outTime = outTime;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("In Time",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                tempOvertime.inTime?.format(context) ??
                                    "Not Set",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.purple),
                          Column(
                            children: [
                              const Text("Out Time",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                tempOvertime.outTime?.format(context) ??
                                    "Not Set",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Duration: ${tempOvertime.duration}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _attendanceData[day.toString()] = tempStatuses;
                      if (tempStatuses.contains(AttendanceType.Overtime)) {
                        _overtimeData[day.toString()] = tempOvertime;
                      } else {
                        _overtimeData.remove(day.toString());
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Save",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(AttendanceType type) {
    switch (type) {
      case AttendanceType.Present:
        return Colors.green;
      case AttendanceType.Absent:
        return Colors.red;
      case AttendanceType.HalfDay:
        return Colors.orange;
      case AttendanceType.Holiday:
        return Colors.grey;
      case AttendanceType.NightShift:
        return Colors.indigo;
      case AttendanceType.Overtime:
        return Colors.purple;
    }
  }

  Map<String, dynamic> _calculateSummary() {
    Map<String, int> counts = {};
    int totalAmount = 0;
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;

    for (var type in AttendanceType.values) {
      counts[type.name] = 0;
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final statuses = _attendanceData[i.toString()] ?? [AttendanceType.Absent];
      for (var status in statuses) {
        counts[status.name] = (counts[status.name] ?? 0) + 1;
      }
      if (_amountData.containsKey(i.toString())) {
        totalAmount += _amountData[i.toString()]!;
      }
    }

    return {...counts, "totalAmount": totalAmount};
  }

  Future<void> _downloadReport() async {
    if (_selectedStaff == null) return;
    final pdf = pw.Document();
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final summary = _calculateSummary();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Text("ATTENDANCE REPORT",
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                      "${_selectedStaff!.name} • ${DateFormat.yMMMM().format(_selectedMonth)}",
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.white)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Daily data - 4 columns including overtime
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("Day",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("Status",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("OT Time",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text("Amount",
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8))),
                  ],
                ),
                ...List.generate(daysInMonth, (i) {
                  final day = i + 1;
                  final statuses = _attendanceData[day.toString()] ??
                      [AttendanceType.Absent];
                  final statusText =
                      statuses.map((e) => e.name.substring(0, 3)).join(", ");
                  final overtime = _overtimeData[day.toString()];
                  String otText = "-";
                  if (overtime?.inTime != null && overtime?.outTime != null) {
                    otText =
                        "${overtime!.inTime!.format(context)}-${overtime.outTime!.format(context)} (${overtime.duration})";
                  }
                  final amount = _amountData[day.toString()];
                  final amountText = amount == null
                      ? "-"
                      : (amount > 0 ? "+$amount" : "$amount");

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text("$day",
                              style: const pw.TextStyle(fontSize: 7))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(statusText,
                              style: const pw.TextStyle(fontSize: 7))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(otText,
                              style: const pw.TextStyle(fontSize: 6))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(amountText,
                              style: const pw.TextStyle(fontSize: 7))),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Divider(),

            // Summary
            pw.Text("MONTHLY SUMMARY",
                style:
                    pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 15,
              runSpacing: 4,
              children: [
                ...AttendanceType.values.map((type) => pw.Text(
                    "${type.name}: ${summary[type.name]}",
                    style: const pw.TextStyle(fontSize: 8))),
                pw.Text(
                  "Total Amount: ${summary['totalAmount'] >= 0 ? '+${summary['totalAmount']}' : summary['totalAmount']}",
                  style:
                      pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final filePath =
        "${outputDir.path}/Attendance_${_selectedStaff!.name}_${DateFormat.yMMM().format(_selectedMonth)}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstDayWeekday =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday;
    final summary = _calculateSummary();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text("Attendance",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: _downloadReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Staff Selection Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: DropdownButtonFormField<Staff>(
                      value: _selectedStaff,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Select Staff",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _staffList
                          .map((staff) => DropdownMenuItem(
                              value: staff, child: Text(staff.name)))
                          .toList(),
                      onChanged: (staff) {
                        if (staff != null) {
                          setState(() => _selectedStaff = staff);
                          _loadAttendance();
                        }
                      },
                    ),
                  ),

                  // Month Navigation
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          DateFormat.yMMMM().format(_selectedMonth),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Calendar Grid
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: daysInMonth + firstDayWeekday - 1,
                      itemBuilder: (context, index) {
                        if (index < firstDayWeekday - 1) return Container();
                        final day = index - firstDayWeekday + 2;
                        final statuses = _attendanceData[day.toString()] ??
                            [AttendanceType.Absent];

                        return GestureDetector(
                          onTap: () => _showAttendanceSheet(day),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: statuses.length == 1
                                    ? [
                                        _getColorForType(statuses[0]),
                                        _getColorForType(statuses[0])
                                      ]
                                    : [
                                        _getColorForType(statuses[0]),
                                        _getColorForType(statuses.last)
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    '$day',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // Show OT indicator
                                if (statuses
                                        .contains(AttendanceType.Overtime) &&
                                    _overtimeData[day.toString()] != null)
                                  Positioned(
                                    right: 2,
                                    top: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.access_time,
                                        size: 10,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Monthly Summary",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...AttendanceType.values.map((type) =>
                                _buildSummaryChip(
                                    type.name,
                                    summary[type.name] ?? 0,
                                    _getColorForType(type))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Amount",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                "${summary['totalAmount'] >= 0 ? '+' : ''}${summary['totalAmount']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: summary['totalAmount'] >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        "$label: $count",
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
