// lib/staff_management/features/holiday_list_page.dart
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class HolidayListPage extends StatefulWidget {
  const HolidayListPage({super.key});

  @override
  _HolidayListPageState createState() => _HolidayListPageState();
}

class _HolidayListPageState extends State<HolidayListPage> {
  List<Holiday> _holidays = [];

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    _holidays = await HolidayService.getHolidays();
    _holidays.sort((a, b) => a.date.compareTo(b.date));
    setState(() {});
  }

  void _addHoliday() async {
    final result = await showDialog<Holiday>(
        context: context, builder: (context) => const AddHolidayDialog());
    if (result != null) {
      await HolidayService.addHoliday(result);
      _loadHolidays();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Holiday List")),
      body: ListView.builder(
        itemCount: _holidays.length,
        itemBuilder: (context, index) {
          final holiday = _holidays[index];
          return ListTile(
            title: Text(holiday.title),
            trailing: Text(DateFormat.yMMMd().format(holiday.date)),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHoliday,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddHolidayDialog extends StatefulWidget {
  const AddHolidayDialog({super.key});
  @override
  _AddHolidayDialogState createState() => _AddHolidayDialogState();
}

class _AddHolidayDialogState extends State<AddHolidayDialog> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Holiday"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Holiday Name")),
          ListTile(
            title: Text("Date: ${DateFormat.yMMMd().format(_selectedDate)}"),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              final holiday = Holiday(
                  id: const Uuid().v4(),
                  title: _titleController.text,
                  date: _selectedDate);
              Navigator.pop(context, holiday);
            },
            child: const Text("Add")),
      ],
    );
  }
}
