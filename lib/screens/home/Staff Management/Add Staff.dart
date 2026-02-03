// lib/screens/home/Staff Management/Add Staff.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/service.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';
import 'package:uuid/uuid.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({super.key});

  @override
  State<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  // Controllers for all fields
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _expenseController = TextEditingController();
  final _areaRateController = TextEditingController();
  final _areaUnitController = TextEditingController();
  final _timeRateController = TextEditingController();
  final _timeUnitController = TextEditingController();

  String _gender = 'Female';
  String? _selectedDesignation;
  File? _photo;
  File? _aadhar;

  Future<void> _pickImage(ImageSource source, Function(File) onPicked) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        onPicked(File(pickedFile.path));
      });
    }
  }

  Future<void> _saveStaffProfile() async {
    if (_nameController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _selectedDesignation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Name, Mobile, and Designation are required.')));
      return;
    }

    final newStaff = Staff(
      id: const Uuid().v4(),
      name: _nameController.text,
      mobile: _mobileController.text,
      address: _addressController.text,
      gender: _gender,
      dob: _dobController.text,
      photoPath: _photo?.path,
      aadharPath: _aadhar?.path,
      designation: _selectedDesignation!,
      expenseAllowance: double.tryParse(_expenseController.text) ?? 0.0,
      areaRate: double.tryParse(_areaRateController.text) ?? 0.0,
      areaUnit: _areaUnitController.text,
      timeRate: double.tryParse(_timeRateController.text) ?? 0.0,
      timeUnit: _timeUnitController.text,
    );

    await StaffService.addStaff(newStaff);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Staff Profile Saved!')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    //... dispose all other controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dropdown items
    final List<DropdownMenuItem<String>> designationItems = [
      'Store Manager',
      'Site Supervisor',
      'Accountant',
      'Driver',
      'Labour',
      'Karigar',
      'Builder',
      'Owner'
    ]
        .map((String value) =>
            DropdownMenuItem<String>(value: value, child: Text(value)))
        .toList();

    // UI code almost same as yours, just connected with controllers
    // For brevity, only showing the main structure. You can use your existing UI code
    // and just replace TextEditingController() with the controllers defined above.

    return Scaffold(
      backgroundColor: ThemeColors.kWhiteTextColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title:
            CustomText(text: "Add Staff", color: ThemeColors.kWhiteTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const CustomText(
                  text: "Personal Detail", size: 18, weight: FontWeight.w500),
              const SizedBox(height: 26),
              const CustomText(text: "Name", weight: FontWeight.w600),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: RegisterField(
                          hint: "Name", controller: _nameController)),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_sharp),
                    onPressed: () => _pickImage(
                        ImageSource.gallery, (file) => _photo = file),
                  )
                ],
              ),
              //... other fields like mobile, address with their controllers
              const SizedBox(height: 10),
              const CustomText(text: "Mobile No.", weight: FontWeight.w600),
              const SizedBox(height: 8),
              RegisterField(
                  hint: "Mobile Number", controller: _mobileController),

              const SizedBox(height: 10),
              const CustomText(text: "Address", weight: FontWeight.w600),
              const SizedBox(height: 8),
              RegisterField(hint: "Address", controller: _addressController),

              const SizedBox(height: 10),
              const CustomText(
                  text: "Gender", size: 18, weight: FontWeight.w500),
              Row(
                children: <Widget>[
                  Radio<String>(
                      value: 'Female',
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v!)),
                  const CustomText(text: "Female"),
                  Radio<String>(
                      value: 'Male',
                      groupValue: _gender,
                      onChanged: (v) => setState(() => _gender = v!)),
                  const CustomText(text: "Male"),
                ],
              ),

              const SizedBox(height: 10),
              const CustomText(
                  text: "D.O.B", size: 18, weight: FontWeight.w500),
              const SizedBox(height: 10),
              RegisterField(hint: "DD/MM/YYYY", controller: _dobController),

              const SizedBox(height: 10),
              const CustomText(text: "Aadhar Upload", weight: FontWeight.w600),
              Row(
                children: [
                  Expanded(
                      child: RegisterField(
                          hint: "Aadhar",
                          enabled: false,
                          controller: TextEditingController(
                              text: _aadhar?.path.split('/').last))),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_sharp),
                    onPressed: () => _pickImage(
                        ImageSource.gallery, (file) => _aadhar = file),
                  )
                ],
              ),

              const SizedBox(height: 20),
              const CustomText(
                  text: "Professional Data", size: 20, weight: FontWeight.w700),
              const SizedBox(height: 10),
              const CustomText(text: "Designation", weight: FontWeight.w600),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Select Designation',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                value: _selectedDesignation,
                items: designationItems,
                onChanged: (value) =>
                    setState(() => _selectedDesignation = value),
                isExpanded: true,
              ),

              // ... Other fields like expense allowance, wage calculation etc.
              const SizedBox(height: 10),
              const CustomText(
                  text: "Expenses Allowance", weight: FontWeight.w600),
              const SizedBox(height: 10),
              RegisterField(
                  hint: "Expenses Allowance",
                  controller: _expenseController,
                  keyboardType: TextInputType.number),

              const SizedBox(height: 30),
              PrimaryButton(onTap: _saveStaffProfile, text: "Save Profile"),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
