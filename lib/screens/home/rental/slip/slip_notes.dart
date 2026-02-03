import 'package:flutter/material.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class SlipNotes extends StatelessWidget {
  const SlipNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Slip Notes",
          color: ThemeColors.kWhiteTextColor,
        ),
        iconTheme: IconThemeData(
          color:
              ThemeColors.kWhiteTextColor, // Sets the back arrow color to white
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          // This is a sample note tile that includes an image
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
                    // Handles errors if the image fails to load
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade300,
                        child: Icon(Icons.image_not_supported,
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
                        text: 'Site Note new',
                        weight: FontWeight.bold,
                        size: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      const CustomText(
                        text: 'hnewfw',
                        color: Colors.black54,
                        size: 14,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: 'August 3, 2025',
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
          // You can add more note tiles here
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add a new note
        },
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
