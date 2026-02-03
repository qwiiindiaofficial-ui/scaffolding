// In file: edit_profile_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _updatedData;

  // Controllers & State Variables
  late TextEditingController _gstLegalNameController;
  late TextEditingController _gstTradeNameController;
  late TextEditingController _gstAddressController;
  late TextEditingController _gstCompanyTypeController;
  late TextEditingController _gstStatusController;
  String? _gstCertificatePath;

  late TextEditingController _aadhaarNameController;
  late TextEditingController _aadhaarDobController;
  late TextEditingController _aadhaarAddressController;
  String? _aadhaarCardPath;

  String? _logoPath;
  String? _signaturePath;

  late String _selectedCateringOption;
  late TextEditingController
      _cateringRadiusController; // FIXED: Made it a proper controller

  late bool _isCertified;
  late TextEditingController _isoController;

  late TextEditingController _ewayIdController;
  late TextEditingController _ewayPassController;

  late Map<String, bool> _scopeOfWork;

  @override
  void initState() {
    super.initState();
    _updatedData = Map<String, dynamic>.from(widget.profileData);

    // GST
    _gstLegalNameController =
        TextEditingController(text: _updatedData['gst_legal_name'] ?? '');
    _gstTradeNameController =
        TextEditingController(text: _updatedData['gst_trade_name'] ?? '');
    _gstAddressController =
        TextEditingController(text: _updatedData['gst_address'] ?? '');
    _gstCompanyTypeController =
        TextEditingController(text: _updatedData['gst_company_type'] ?? '');
    _gstStatusController =
        TextEditingController(text: _updatedData['gst_status_text'] ?? '');
    _gstCertificatePath = _updatedData['gst_certificate'];

    // Aadhaar
    _aadhaarNameController =
        TextEditingController(text: _updatedData['aadhaar_name'] ?? '');
    _aadhaarDobController =
        TextEditingController(text: _updatedData['aadhaar_dob'] ?? '');
    _aadhaarAddressController =
        TextEditingController(text: _updatedData['aadhaar_address'] ?? '');
    _aadhaarCardPath = _updatedData['aadhaar_card'];

    // Images
    _logoPath = _updatedData['logo_path'];
    _signaturePath = _updatedData['signature_path'];

    // Other fields
    _selectedCateringOption = _updatedData['catering_option'] ?? '1';
    _cateringRadiusController = TextEditingController(
        text: _updatedData['catering_radius']?.toString() ?? '50'); // FIXED
    _isCertified = _updatedData['iso_certified'] ?? false;
    _isoController =
        TextEditingController(text: _updatedData['iso_number'] ?? '');
    _ewayIdController =
        TextEditingController(text: _updatedData['eway_bill_id'] ?? '');
    _ewayPassController =
        TextEditingController(text: _updatedData['eway_bill_password'] ?? '');
    final scope = _updatedData['scope_of_work'] ?? {};
    _scopeOfWork = {
      'sale': scope['sale'] ?? false,
      'rental': scope['rental'] ?? false,
      'contractor': scope['contractor'] ?? false,
      'service': scope['service'] ?? false
    };
  }

  @override
  void dispose() {
    // Dispose all controllers
    _gstLegalNameController.dispose();
    _gstTradeNameController.dispose();
    _gstAddressController.dispose();
    _gstCompanyTypeController.dispose();
    _gstStatusController.dispose();
    _aadhaarNameController.dispose();
    _aadhaarDobController.dispose();
    _aadhaarAddressController.dispose();
    _cateringRadiusController.dispose(); // FIXED: Added dispose
    _isoController.dispose();
    _ewayIdController.dispose();
    _ewayPassController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Update the map with all data
      _updatedData['gst_legal_name'] = _gstLegalNameController.text;
      _updatedData['gst_trade_name'] = _gstTradeNameController.text;
      _updatedData['gst_address'] = _gstAddressController.text;
      _updatedData['gst_company_type'] = _gstCompanyTypeController.text;
      _updatedData['gst_status_text'] = _gstStatusController.text;
      _updatedData['gst_certificate'] =
          _gstCertificatePath; // FIXED: This will now save properly

      _updatedData['aadhaar_name'] = _aadhaarNameController.text;
      _updatedData['aadhaar_dob'] = _aadhaarDobController.text;
      _updatedData['aadhaar_address'] = _aadhaarAddressController.text;
      _updatedData['aadhaar_card'] =
          _aadhaarCardPath; // FIXED: This will now save properly

      _updatedData['logo_path'] = _logoPath;
      _updatedData['signature_path'] = _signaturePath;

      _updatedData['catering_option'] = _selectedCateringOption;
      _updatedData['catering_radius'] =
          _cateringRadiusController.text; // FIXED: Now uses controller

      _updatedData['iso_certified'] = _isCertified;
      _updatedData['iso_number'] = _isoController.text;
      _updatedData['eway_bill_id'] = _ewayIdController.text;
      _updatedData['eway_bill_password'] = _ewayPassController.text;
      _updatedData['scope_of_work'] = _scopeOfWork;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('register_form_data', jsonEncode(_updatedData));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Updated Successfully!')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
            text: "Edit Profile", size: 18, color: Colors.white),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_updatedData['gst_status'] == 'registered')
                _buildGstSection()
              else
                _buildAadhaarSection(),
              _buildSectionTitle("Service Area"),
              _buildCateringSection(),
              _buildSectionTitle("Certifications"),
              _buildIsoSection(),
              if (_updatedData['gst_status'] == 'registered') ...[
                _buildSectionTitle("E-Way Bill Information"),
                _buildEwaySection(),
              ],
              _buildSectionTitle("Scope of Work"),
              _buildScopeOfWorkSection(),
              _buildSectionTitle("Company Files"),
              _buildImagePicker("Company Logo", _logoPath,
                  (path) => setState(() => _logoPath = path)),
              const SizedBox(height: 16),
              _buildImagePicker("Signature", _signaturePath,
                  (path) => setState(() => _signaturePath = path)),
              const SizedBox(height: 40),
              PrimaryButton(onTap: _saveProfile, text: "Save Changes"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  // === HELPER METHODS (Fully Implemented) ===

  Widget _buildGstSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("GST Information"),
          _buildReadOnlyInfo("GST Number", _updatedData['gst_number']),
          _buildReadOnlyInfo("Phone Number", _updatedData['phone']),
          _buildTextFormField(_gstLegalNameController, "Legal Name",
              isRequired: true),
          _buildTextFormField(_gstTradeNameController, "Trade Name"),
          _buildTextFormField(_gstAddressController, "Business Address",
              maxLines: 3, isRequired: true),
          _buildTextFormField(_gstCompanyTypeController, "Company Type"),
          _buildTextFormField(_gstStatusController, "GST Status Text"),
          const SizedBox(height: 8),
          _buildFilePicker("GST Certificate (PDF)", _gstCertificatePath,
              (path) => setState(() => _gstCertificatePath = path)),
        ],
      );

  Widget _buildAadhaarSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Aadhaar Information"),
          _buildReadOnlyInfo("Aadhaar Number", _updatedData['aadhaar_number']),
          _buildTextFormField(_aadhaarNameController, "Name as per Aadhaar",
              isRequired: true),
          _buildTextFormField(
              _aadhaarDobController, "Date of Birth (DD-MM-YYYY)",
              isRequired: true),
          _buildTextFormField(_aadhaarAddressController, "Address",
              maxLines: 3, isRequired: true),
          _buildReadOnlyInfo("Phone Number", _updatedData['phone']),
          const SizedBox(height: 8),
          _buildImagePicker("Aadhaar Card", _aadhaarCardPath,
              (path) => setState(() => _aadhaarCardPath = path)),
        ],
      );

  Widget _buildReadOnlyInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomText(text: label, size: 14, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        CustomText(
            text: value ?? 'Not available', size: 16, weight: FontWeight.w500),
        const SizedBox(height: 4),
        Divider(color: Colors.grey.shade300)
      ]),
    );
  }

  Widget _buildFilePicker(
      String title, String? currentFilePath, Function(String) onFileSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomText(text: title, weight: FontWeight.w500),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
            const SizedBox(width: 12),
            Expanded(
                child: CustomText(
                    text: currentFilePath != null
                        ? p.basename(currentFilePath)
                        : 'No file selected',
                    color: Colors.grey.shade800))
          ]),
        ),
        const SizedBox(height: 10),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text(currentFilePath == null ? "Select PDF" : "Change PDF"),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform
                  .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
              if (result != null && result.files.single.path != null) {
                onFileSelected(result.files.single
                    .path!); // FIXED: Callback will update state properly
              }
            },
          ),
        )
      ]),
    );
  }

  Widget _buildImagePicker(String title, String? currentImagePath,
      Function(String) onImageSelected) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(text: title, weight: FontWeight.w500),
      const SizedBox(height: 10),
      Center(
        child: Container(
          height: 150,
          width: 250,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: currentImagePath != null && File(currentImagePath).existsSync()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      Image.file(File(currentImagePath), fit: BoxFit.contain))
              : const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.grey, size: 50)),
        ),
      ),
      const SizedBox(height: 10),
      Center(
        child: OutlinedButton.icon(
          icon: const Icon(Icons.edit),
          label: Text("Change $title"),
          onPressed: () async {
            final String? croppedImagePath = await _pickAndCropImage();

            if (croppedImagePath != null) {
              onImageSelected(
                  croppedImagePath); // FIXED: Callback will update state properly
            }
          },
        ),
      )
    ]);
  }

  Future<String?> _pickAndCropImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarWidgetColor: Colors.white,
          toolbarColor: Colors.black,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile == null) return null;

    return croppedFile.path;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: CustomText(
          text: title,
          size: 18,
          weight: FontWeight.w600,
          color: ThemeColors.kPrimaryThemeColor),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      {bool isRequired = false,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      void Function(String?)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildCateringSection() {
    return Column(children: [
      RadioListTile<String>(
          title: const Text("Pan India"),
          value: '1',
          groupValue: _selectedCateringOption,
          onChanged: (value) =>
              setState(() => _selectedCateringOption = value!)),
      RadioListTile<String>(
          title: const Text("Domestic (within a radius)"),
          value: '2',
          groupValue: _selectedCateringOption,
          onChanged: (value) =>
              setState(() => _selectedCateringOption = value!)),
      if (_selectedCateringOption == '2')
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildTextFormField(_cateringRadiusController,
              "Radius in km", // FIXED: Now uses existing controller
              keyboardType: TextInputType.number),
        )
    ]);
  }

  Widget _buildIsoSection() {
    return Column(children: [
      SwitchListTile(
          title: const Text("ISO Certified?"),
          value: _isCertified,
          onChanged: (value) => setState(() => _isCertified = value)),
      if (_isCertified)
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTextFormField(_isoController, "ISO Number / Details"))
    ]);
  }

  Widget _buildEwaySection() {
    return Column(children: [
      _buildTextFormField(_ewayIdController, "E-Way Bill ID"),
      _buildTextFormField(_ewayPassController, "E-Way Bill Password",
          obscureText: true)
    ]);
  }

  Widget _buildScopeOfWorkSection() {
    return Column(
        children: _scopeOfWork.keys.map((key) {
      return CheckboxListTile(
        title: Text(key[0].toUpperCase() + key.substring(1)),
        value: _scopeOfWork[key],
        onChanged: (value) => setState(() => _scopeOfWork[key] = value!),
        controlAffinity: ListTileControlAffinity.leading,
      );
    }).toList());
  }
}
