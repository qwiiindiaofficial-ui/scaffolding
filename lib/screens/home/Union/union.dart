// screens/home/Unionpage.dart

import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart'; // Assuming this has CustomText, RegisterField, ThemeColors etc.
import 'package:scaffolding_sale/screens/home/Union/NewStaff.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';
// Updated import: NewStaff ke badle PostEditorPage use karein
import 'package:intl/intl.dart';

class Unionpage extends StatefulWidget {
  const Unionpage({super.key});

  @override
  _UnionpageState createState() => _UnionpageState();
}

class _UnionpageState extends State<Unionpage> {
  // Format timestamp to 12-hour clock (AM/PM)
  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy h:mm a').format(timestamp);
  }

  // **EDIT/CREATE के लिए नेविगेशन फ़ंक्शन**
  void _navigateAndRefresh({Post? postToEdit, int? indexToEdit}) async {
    // Wait for the PostEditorPage to be closed
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostEditorPage(
          existingPost: postToEdit,
          postIndex: indexToEdit,
        ),
      ),
    );
    // After it's closed, rebuild this page to show new data
    setState(() {});
  }

  // **DELETE फ़ंक्शन**
  // Unionpage.dart में अपडेटेड _deletePost फ़ंक्शन

// **DELETE फ़ंक्शन**
  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.'),
          actions: <Widget>[
            // No/Cancel Button
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog बंद करें
              },
            ),
            // Yes/Delete Button
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Dialog बंद करें
                Navigator.of(context).pop();

                // पोस्ट डिलीट करें
                setState(() {
                  PostService.posts.removeAt(index);
                });

                // सक्सेस मैसेज दिखाएँ
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post deleted successfully!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

// ... बाकी UnionpageState क्लास का कोड वैसा ही रहेगा।

  @override
  Widget build(BuildContext context) {
    // Access the posts from our "session"
    final posts = PostService.posts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Union",
          color: ThemeColors.kWhiteTextColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // "Add" Button (अब यह _navigateAndRefresh को बिना किसी argument के कॉल करेगा)
          InkWell(
            onTap: _navigateAndRefresh,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: ThemeColors.kSecondaryThemeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: CustomText(
                    text: "Add Post",
                    size: 12,
                    color: ThemeColors.kWhiteTextColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RegisterField(
              hint: "Search Area..",
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: posts.isEmpty
                  ? const Center(
                      child: CustomText(
                        text: "No Posts Yet",
                        size: 16,
                        color: Colors.grey,
                      ),
                    )
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // **Header with Edit/Delete Menu**
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.business,
                                          color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "Pal Scaffolding",
                                          size: 15,
                                          weight: FontWeight.bold,
                                          color: ThemeColors.kPrimaryThemeColor,
                                        ),
                                        Text(
                                          _formatTimestamp(post.timestamp),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),

                                    // **Edit and Delete Menu Button**
                                    PopupMenuButton<String>(
                                      onSelected: (String result) {
                                        if (result == 'edit') {
                                          _navigateAndRefresh(
                                              postToEdit: post,
                                              indexToEdit: index);
                                        } else if (result == 'delete') {
                                          _deletePost(index);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Show post text
                                CustomText(
                                  text: post.text,
                                  size: 15,
                                  height: 1.4,
                                ),
                                const SizedBox(height: 12),

                                // Show image if it exists
                                if (post.image != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      post.image!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
