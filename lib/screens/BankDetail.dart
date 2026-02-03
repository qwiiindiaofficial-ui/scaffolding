import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bankdetail extends StatefulWidget {
  @override
  _BankdetailState createState() => _BankdetailState();
}

class _BankdetailState extends State<Bankdetail> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _bankDetailsController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bankDetailsController.text = prefs.getString('bankDetails') ?? '';
      _upiIdController.text = prefs.getString('upiId') ?? '';
    });
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bankDetails', _bankDetailsController.text.trim());
      await prefs.setString('upiId', _upiIdController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully')),
      );
    }
  }

  @override
  void dispose() {
    _bankDetailsController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Details'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _bankDetailsController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Bank Details',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                // validator: (value) {
                //   if (value == null || value.trim().isEmpty) {
                //     return 'Please enter bank details';
                //   }
                //   return null;
                // },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _upiIdController,
                decoration: InputDecoration(
                  labelText: 'UPI ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter UPI ID';
                  }
                  if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(value.trim())) {
                    return 'Enter valid UPI ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
