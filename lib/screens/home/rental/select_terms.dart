import 'package:flutter/material.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class TermsSelectionScreen extends StatefulWidget {
  final bool editable;
  const TermsSelectionScreen({super.key, required this.editable});

  @override
  _TermsSelectionScreenState createState() => _TermsSelectionScreenState();
}

class _TermsSelectionScreenState extends State<TermsSelectionScreen> {
  final List<Map<String, dynamic>> terms = [
    {
      'title': 'Privacy Policy',
      'subtitle': 'Learn how we handle your data',
      'content': 'This is the full content of the Privacy Policy.',
      'isSelected': false,
      'lastUpdated': "12-4-2024",
    },
    {
      'title': 'User Agreement',
      'subtitle': 'Terms for using our services',
      'content': 'This is the full content of the User Agreement.',
      'isSelected': false,
      'lastUpdated': "12-4-2024",
    },
    {
      'title': 'Refund Policy',
      'subtitle': 'Information on refunds and returns',
      'content': 'This is the full content of the Refund Policy.',
      'isSelected': false,
      'lastUpdated': "12-4-2024",
    },
    {
      'title': 'Content Policy',
      'subtitle': 'Guidelines for posting content',
      'content': 'This is the full content of the Content Policy.',
      'isSelected': false,
      'lastUpdated': "12-4-2024",
    },
  ];

  // Method to show the full term content in a dialog box
  void _showFullTerm(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Text(content, style: TextStyle(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to add a new term
  void _addNewTerm() {
    String newTitle = '';
    String newSubtitle = '';
    String newContent = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Term'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  onChanged: (value) {
                    newTitle = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Subtitle'),
                  onChanged: (value) {
                    newSubtitle = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  onChanged: (value) {
                    newContent = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (newTitle.isNotEmpty && newContent.isNotEmpty) {
                  setState(() {
                    terms.add({
                      'title': newTitle,
                      'subtitle': newSubtitle,
                      'content': newContent,
                      'isSelected': false,
                      'lastUpdated': DateTime.now(),
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add',
                  style: TextStyle(color: ThemeColors.kPrimaryThemeColor)),
            ),
          ],
        );
      },
    );
  }

  // Method to update an existing term
  void _editTerm(int index) {
    String updatedTitle = terms[index]['title'];
    String updatedSubtitle = terms[index]['subtitle'];
    String updatedContent = terms[index]['content'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Term'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: TextEditingController(text: updatedTitle),
                  onChanged: (value) {
                    updatedTitle = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Subtitle'),
                  controller: TextEditingController(text: updatedSubtitle),
                  onChanged: (value) {
                    updatedSubtitle = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  controller: TextEditingController(text: updatedContent),
                  onChanged: (value) {
                    updatedContent = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  terms[index] = {
                    'title': updatedTitle,
                    'subtitle': updatedSubtitle,
                    'content': updatedContent,
                    'isSelected': terms[index]['isSelected'],
                    'lastUpdated': DateTime.now(),
                  };
                });
                Navigator.of(context).pop();
              },
              child: Text('Save',
                  style: TextStyle(color: ThemeColors.kPrimaryThemeColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [IconButton(onPressed: _addNewTerm, icon: Icon(Icons.add))],
        title: CustomText(
          text: "Terms & Conditions",
          color: Colors.white,
          size: 20,
          weight: FontWeight.normal,
        ),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: terms.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: widget.editable
                        ? Checkbox(
                            activeColor: Colors.teal,
                            value: terms[index]['isSelected'],
                            onChanged: (bool? value) {
                              setState(() {
                                terms[index]['isSelected'] = value ?? false;
                              });
                            },
                          )
                        : null,
                    title: Text(
                      terms[index]['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      widget.editable
                          ? terms[index]['subtitle']
                          : 'Last Updated: ${terms[index]['lastUpdated']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility, color: Colors.teal),
                          onPressed: () {
                            _showFullTerm(
                                terms[index]['title'], terms[index]['content']);
                          },
                        ),
                        widget.editable
                            ? IconButton(
                                icon: Icon(Icons.edit, color: Colors.teal),
                                onPressed: () {
                                  _editTerm(index);
                                },
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            PrimaryButton(onTap: () {}, text: "Save Selected Terms"),
          ],
        ),
      ),
    );
  }
}
