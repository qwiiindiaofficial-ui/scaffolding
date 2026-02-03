import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Review extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Review', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              // Handle call button press
            },
          ),
          IconButton(
            icon: Image.asset('images/whatsapp.png'),
            onPressed: () {
              // Handle WhatsApp button press
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          padding:
              const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // 1 column
            childAspectRatio: 1 / 0.3, // Adjust aspect ratio for a taller tile
          ),
          itemCount: 0, // 6 review tiles
          itemBuilder: (context, index) {
            return ReviewTile(); // Use ReviewTile widget
          },
        ),
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 4.0), // Add vertical margin for space between tiles
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: Colors.black38, // Set your desired border color here
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.person,
                  color: Colors.white), // Add an icon for the avatar
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Mayank',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      const IconTheme(
                        data: IconThemeData(color: Colors.yellow),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star),
                            Icon(Icons.star),
                            Icon(Icons.star),
                            Icon(Icons.star),
                            Icon(Icons.star),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Reviewed on 2022-08-23',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                  ),
                  const SizedBox(height: 5),
                  const Divider(),
                  const Text('Good'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
