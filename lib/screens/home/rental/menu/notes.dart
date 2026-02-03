import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/AddNote.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class Notes extends StatelessWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddNotePage();
                }));
              },
              // Added a white color to the icon to match the title
              icon: Icon(Icons.add, color: ThemeColors.kWhiteTextColor))
        ],
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Account Notes",
          color: ThemeColors.kWhiteTextColor,
        ),
        // Ensures the back button (if present) is also white
        iconTheme: IconThemeData(
          color: ThemeColors.kWhiteTextColor,
        ),
      ),
      // Replaced the empty state Center widget with a ListView
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // Sample Note Tile for "Account Notes"
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image on the left
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    // !! IMPORTANT: Replace with your actual image asset path !!
                    'images/file.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    // Shows a placeholder if the image fails to load
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.receipt_long,
                            color: Colors.grey.shade600),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Text content on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: 'New Note',
                        weight: FontWeight.bold,
                        size: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      const CustomText(
                        text: '',
                        color: Colors.black54,
                        size: 14,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: 'Oct 5, 2025',
                          color: Colors.grey.shade600,
                          size: 12,
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
    );
  }
}
