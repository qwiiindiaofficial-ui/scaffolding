import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class ManagePolicy extends StatefulWidget {
  const ManagePolicy({Key? key}) : super(key: key);

  @override
  State<ManagePolicy> createState() => _ManagePolicyState();
}

class _ManagePolicyState extends State<ManagePolicy> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Manage Policy',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  fillColor: Colors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  hintText: 'Type your policy here...',
                ),
                maxLines: 7,
              ),
              Spacer(),
              // const SizedBox(height: 572),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Expenese2(),
                      ),
                    );*/
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: ThemeColors
                        .kSecondaryThemeColor, // Change to your theme color
                    padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 170),
                  ),
                  child: Text('Send', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
