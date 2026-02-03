import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart'; // Add this to your pubspec.yaml for date formatting
import '../utils/colors.dart';

class ReminderSetting extends StatefulWidget {
  const ReminderSetting({Key? key}) : super(key: key);

  @override
  State<ReminderSetting> createState() => _ReminderSettingState();
}

class _ReminderSettingState extends State<ReminderSetting> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRepetition = 'Daily';
  DateTime? _selectedDate;

  // Function to open the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // User can't select past dates
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  ThemeColors.kPrimaryThemeColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    ThemeColors.kPrimaryThemeColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Using the theme color for consistency
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Reminder Setting',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Repetition', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedRepetition,
                  // Added "One Time" option
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    DropdownMenuItem(
                        value: 'One Time', child: Text('One Time')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedRepetition = value;
                      // If "One Time" is not selected, clear the date
                      if (value != 'One Time') {
                        _selectedDate = null;
                      }
                    });
                    // Open date picker if "One Time" is selected
                    if (value == 'One Time') {
                      _selectDate(context);
                    }
                  },
                ),
                // This widget appears to show the selected date for "One Time" reminders
                if (_selectedRepetition == 'One Time')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Select a date'
                                    // Using intl package for clean date formatting
                                    : DateFormat.yMMMMd()
                                        .format(_selectedDate!),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(Icons.calendar_today,
                                    color: ThemeColors.kPrimaryThemeColor),
                                onPressed: () => _selectDate(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Description (Optional)',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: "New reminder for payment",
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: 'Description',
                  ),
                  maxLines: 5,
                ),
                // Using SizedBox to push the button to the bottom
                const SizedBox(height: 150),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: "Reminder Added");
                      Navigator.pop(context);
                      // Add save logic here
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: ThemeColors.kSecondaryThemeColor,
                      // Making button width responsive
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
