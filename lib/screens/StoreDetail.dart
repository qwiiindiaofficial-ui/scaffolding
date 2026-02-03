import 'package:flutter/material.dart';

class StoreDetail extends StatelessWidget {
  final String? ticketName;

  StoreDetail({this.ticketName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Store Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Store Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Pal Scaffolding',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
