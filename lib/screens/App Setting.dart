import 'package:flutter/material.dart';

// Assuming ThemeColors is defined in this file. If not, import it.
class ThemeColors {
  static const Color kSecondaryThemeColor = Colors.teal;
}

class AppSetting extends StatefulWidget {
  @override
  _AppSettingState createState() => _AppSettingState();
}

class _AppSettingState extends State<AppSetting> {
  final _formKey = GlobalKey<FormState>();

  // State variables for each setting
  String? _selectedLanguage = 'English'; // Default language
  bool? _borrowItems = true; // Default No
  bool? _enableMinDays = true; // Default No
  bool? _monthlyWeeklyBills = true; // Default No
  bool? _enableGst = true; // Default No
  bool? _enableMixedBilling = true; // Default No
  bool? _showOneDayDiscount = true; // Default No
  bool? _enable30DaysMonth = true; // Default No
  bool? _sequentialAccountNumbers = true; // Default No
  bool? _showChallanNumber = true; // Default No

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "App Setting",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Select Language ---
                const Text('Select Language',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Radio<String>(
                      activeColor: Colors.teal,
                      value: 'Hindi',
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    Text('Hindi'),
                    Spacer(),
                    Radio<String>(
                      activeColor: Colors.teal,
                      value: 'English',
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    Text('English'),
                    Spacer(),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Punjabi',
                      activeColor: Colors.teal,
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    Text('Punjabi'),
                    Spacer(),
                    Radio<String>(
                      activeColor: Colors.teal,
                      value: 'Hinglish',
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    Text('Hinglish'),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 16),

                // Helper Widget for Yes/No questions
                _buildYesNoQuestion(
                  question:
                      'Do you borrow items from other stores when\nyou do not have enough stock?',
                  groupValue: _borrowItems,
                  onChanged: (value) {
                    setState(() {
                      _borrowItems = value;
                    });
                  },
                ),
                _buildYesNoQuestion(
                  question: 'Enable min days feature?',
                  groupValue: _enableMinDays,
                  onChanged: (value) {
                    setState(() {
                      _enableMinDays = value;
                    });
                  },
                ),
                _buildYesNoQuestion(
                  question: 'Monthly/Weekly Bills',
                  groupValue: _monthlyWeeklyBills,
                  onChanged: (value) {
                    setState(() {
                      _monthlyWeeklyBills = value;
                    });
                  },
                ),

                _buildYesNoQuestion(
                  question:
                      'Enable mixed type billing (SQFT and PER\nITEM both)?',
                  groupValue: _enableMixedBilling,
                  onChanged: (value) {
                    setState(() {
                      _enableMixedBilling = value;
                    });
                  },
                ),
                _buildYesNoQuestion(
                  question: 'Show one day discount on remaining items?',
                  groupValue: _showOneDayDiscount,
                  onChanged: (value) {
                    setState(() {
                      _showOneDayDiscount = value;
                    });
                  },
                ),
                _buildYesNoQuestion(
                  question: 'Enable 30 days month feature',
                  groupValue: _enable30DaysMonth,
                  onChanged: (value) {
                    setState(() {
                      _enable30DaysMonth = value;
                    });
                  },
                ),

                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle the save logic here
                      // For example, print out the selected values

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Settings Saved!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: ThemeColors.kSecondaryThemeColor,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A reusable widget for creating the Yes/No questions to reduce code duplication
  Widget _buildYesNoQuestion({
    required String question,
    required bool? groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio<bool>(
              activeColor: Colors.teal,
              value: true,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const Text('Yes'),
            SizedBox(width: 80),
            Radio<bool>(
              activeColor: Colors.teal,
              value: false,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            const Text('No'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
