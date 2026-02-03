import 'package:flutter/material.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class ScheduledVisitsPage extends StatelessWidget {
  final List<Map<String, String>> visits = [
    {
      'site': 'Alpha Construction Site',
      'date': '20-03-2025',
      'time': '10:00 AM',
      'contact': 'Rahul Sharma',
      'phone': '+91 9876543210',
    },
    {
      'site': 'Beta Infra Project',
      'date': '22-03-2025',
      'time': '02:00 PM',
      'contact': 'Priya Verma',
      'phone': '+91 8765432109',
    },
    {
      'site': 'Gamma Towers',
      'date': '25-03-2025',
      'time': '11:30 AM',
      'contact': 'Amit Khanna',
      'phone': '+91 7654321098',
    },
  ];

  ScheduledVisitsPage({super.key});

  void _showVisitDetails(BuildContext context, Map<String, String> visit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: visit['site']!,
                size: 18,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              CustomText(text: 'Date: ${visit['date']}', size: 14),
              CustomText(text: 'Time: ${visit['time']}', size: 14),
              CustomText(text: 'Contact: ${visit['contact']}', size: 14),
              CustomText(text: 'Phone: ${visit['phone']}', size: 14),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.kPrimaryThemeColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const CustomText(text: 'Close', color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
            color: Colors.white,
            text: 'Scheduled Visits',
            size: 18,
            weight: FontWeight.w600),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: CustomText(
                  text: visit['site']!, size: 16, weight: FontWeight.w500),
              subtitle: CustomText(
                  text: '${visit['date']} | ${visit['time']}', size: 14),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showVisitDetails(context, visit),
            ),
          );
        },
      ),
    );
  }
}
