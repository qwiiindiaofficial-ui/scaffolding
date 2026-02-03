import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/ReminderSetting.dart';
import 'package:url_launcher/url_launcher.dart'; // For making phone calls
import 'package:scaffolding_sale/utils/colors.dart'; // Assuming your color file path

// 1. Dummy Data Model
// 1. Dummy Data Model
class PartyReminder {
  final String partyName;
  final String phoneNumber;
  final String description;
  final DateTime reminderDate;

  // 💥 NEW: To track if the user has clicked on the reminder
  bool isSeen;

  PartyReminder({
    required this.partyName,
    required this.phoneNumber,
    required this.description,
    required this.reminderDate,
    this.isSeen = false, // Default to false (unseen)
  });
}

// ...
class TodaysRemindersScreen extends StatefulWidget {
  const TodaysRemindersScreen({Key? key}) : super(key: key);

  @override
  State<TodaysRemindersScreen> createState() => _TodaysRemindersScreenState();
}

// ... (Previous imports and class definitions)

class _TodaysRemindersScreenState extends State<TodaysRemindersScreen> {
  DateTime _selectedDate = DateTime.now();

  // 2. Dummy Data List (Dates adjusted to Today for better testing)
  final List<PartyReminder> _allReminders = [
    PartyReminder(
      partyName: 'Sharma Constructions',
      phoneNumber: '9876543210',
      description: 'Follow up for pending payment of invoice #INV-007.',
      reminderDate: DateTime.now(), // Today
    ),
    PartyReminder(
      partyName: 'Gupta Builders',
      phoneNumber: '9988776655',
      description:
          'Confirm delivery schedule for new scaffolding order.Confirm delivery schedule for new scaffolding order.Confirm delivery schedule for new scaffolding order.Confirm delivery schedule for new scaffolding order.',
      reminderDate: DateTime.now(), // Today
    ),
    PartyReminder(
      partyName: 'Verma & Sons',
      phoneNumber: '9123456789',
      description: 'Call regarding the rental agreement renewal.',
      reminderDate: DateTime.now().add(Duration(days: 1)), // Tomorrow
    ),
    PartyReminder(
      partyName: 'Singh Contractors',
      phoneNumber: '9898989898',
      description: 'Finalize quote for the upcoming bridge project.',
      reminderDate: DateTime.now().add(Duration(days: 1)), // Tomorrow
    ),
    PartyReminder(
      partyName: 'Delhi Metro Project',
      phoneNumber: '8877665544',
      description: 'Site visit scheduled at 11 AM.',
      reminderDate: DateTime.now(), // Today
    ),
  ];

  List<PartyReminder> _filteredReminders = [];

  // ... (initState, _filterRemindersForSelectedDate, _selectDate functions are unchanged)

  // Function to show reminder details in a dialog
  void _showReminderDetails(BuildContext context, PartyReminder reminder) {
    // 💥 NEW: Mark the reminder as seen when the details dialog is opened
    setState(() {
      reminder.isSeen = true;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(reminder.partyName),
              const Spacer(),
              TextButton(
                child: const Text('Add Reminder'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const ReminderSetting();
                  }));
                },
              ),
            ],
          ),
          content: Text(reminder.description),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(
              width: 100,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.call, color: Colors.white),
              label: const Text('Call', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () async {
                // Uses url_launcher to make the call
                final Uri phoneUri =
                    Uri(scheme: 'tel', path: reminder.phoneNumber);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Could not place the call.')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _filterRemindersForSelectedDate();
  }

  // 💥 यहाँ फ़ंक्शन को पेस्ट करें 💥
  void _filterRemindersForSelectedDate() {
    setState(() {
      _filteredReminders = _allReminders.where((reminder) {
        return reminder.reminderDate.year == _selectedDate.year &&
            reminder.reminderDate.month == _selectedDate.month &&
            reminder.reminderDate.day == _selectedDate.day;
      }).toList();
    });
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024), // आपकी ज़रूरत के हिसाब से बदलें
      lastDate: DateTime(2026), // आपकी ज़रूरत के हिसाब से बदलें
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterRemindersForSelectedDate(); // नई तारीख के लिए रिमाइंडर फ़िल्टर करें
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders', style: TextStyle(color: Colors.white)),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 3. Date Selector UI (Unchanged)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd()
                      .format(_selectedDate), // e.g., August 3, 2025
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.kPrimaryThemeColor,
                  ),
                  child: const Text('Change Date',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // 4. List of Reminders
          Expanded(
            child: _filteredReminders.isEmpty
                ? Center(
                    child: Text(
                      'No reminders for this date.',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _filteredReminders[index];

                      // 💥 NEW: Styling based on the 'isSeen' state
                      final bool isUnseen = !reminder.isSeen;
                      final Color cardColor = isUnseen
                          ? ThemeColors.kPrimaryThemeColor.withOpacity(0.1)
                          : Colors.white; // Light highlight for unseen
                      final Color textColor = isUnseen
                          ? Colors.black
                          : Colors.grey.shade600; // Duller text for seen

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        // 💥 NEW: Apply color based on isUnseen
                        color: cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUnseen
                                ? ThemeColors.kPrimaryThemeColor
                                : Colors.grey, // Duller avatar for seen
                            child:
                                const Icon(Icons.business, color: Colors.white),
                          ),
                          title: Text(reminder.partyName,
                              style: TextStyle(
                                  fontWeight: isUnseen
                                      ? FontWeight.bold
                                      : FontWeight
                                          .normal, // Bold title for unseen
                                  color: textColor)),
                          subtitle: Text(
                            isUnseen
                                ? 'Tap to see details and call'
                                : 'Seen', // Show "Seen" text
                            style: TextStyle(
                                color: isUnseen
                                    ? Colors.red
                                    : Colors
                                        .grey), // Red for unseen status, grey for seen
                          ),
                          trailing:
                              Icon(Icons.arrow_forward_ios, color: textColor),
                          onTap: () {
                            _showReminderDetails(context, reminder);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
