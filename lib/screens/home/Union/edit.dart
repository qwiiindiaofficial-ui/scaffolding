// In file: edit_party_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPartyScreen extends StatefulWidget {
  final Map<String, dynamic> initialPartyData;
  const EditPartyScreen({super.key, required this.initialPartyData});

  @override
  State<EditPartyScreen> createState() => _EditPartyScreenState();
}

class _EditPartyScreenState extends State<EditPartyScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late Map<String, dynamic> _updatedData;

  late TextEditingController _gstLegalNameController;
  late TextEditingController _gstTradeNameController;
  late TextEditingController _gstAddressController;
  late TextEditingController _msmeController;
  late TextEditingController _aadhaarNameController;
  late TextEditingController _aadhaarDobController;
  late TextEditingController _aadhaarAddressController;
  late TextEditingController _panController;
  late TextEditingController _designationController;
  String? _profileImagePath,
      _gstCertificatePath,
      _aadhaarCardPath,
      _panCardPath;
  late List<Map<String, dynamic>> _contacts;
  late List<GlobalKey<FormState>> _contactFormKeys;

  @override
  void initState() {
    super.initState();
    _updatedData = Map<String, dynamic>.from(widget.initialPartyData);

    _gstLegalNameController =
        TextEditingController(text: _updatedData['gst_legal_name'] ?? '');
    _gstTradeNameController =
        TextEditingController(text: _updatedData['gst_trade_name'] ?? '');
    _gstAddressController =
        TextEditingController(text: _updatedData['gst_address'] ?? '');
    _msmeController =
        TextEditingController(text: _updatedData['msme_number'] ?? '');
    _aadhaarNameController = TextEditingController(
        text: _updatedData['aadhaar_name'] ?? _updatedData['name'] ?? '');
    _aadhaarDobController =
        TextEditingController(text: _updatedData['aadhaar_dob'] ?? '');
    _aadhaarAddressController =
        TextEditingController(text: _updatedData['aadhaar_address'] ?? '');
    _panController =
        TextEditingController(text: _updatedData['pan_number'] ?? '');
    _designationController =
        TextEditingController(text: _updatedData['designation'] ?? '');
    _profileImagePath = _updatedData['profile_image'];
    _gstCertificatePath = _updatedData['gst_certificate'];
    _aadhaarCardPath = _updatedData['aadhar_card'];
    _panCardPath = _updatedData['pan_card'];
    _contacts = (_updatedData['contacts'] as List? ?? []).map((contact) {
      var phones = contact['phones'];
      contact['phones'] = phones is List
          ? List<String>.from(phones.map((p) => p.toString()))
          : <String>[''];
      return Map<String, dynamic>.from(contact);
    }).toList();
    _contactFormKeys =
        List.generate(_contacts.length, (index) => GlobalKey<FormState>());
  }

  @override
  void dispose() {
    _gstLegalNameController.dispose();
    _gstTradeNameController.dispose();
    _gstAddressController.dispose();
    _msmeController.dispose();
    _aadhaarNameController.dispose();
    _aadhaarDobController.dispose();
    _aadhaarAddressController.dispose();
    _panController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _saveParty() async {
    bool isMainFormValid = _formKey.currentState!.validate();
    bool areContactsValid =
        _contactFormKeys.every((key) => key.currentState!.validate());

    if (!isMainFormValid || !areContactsValid) return;

    _formKey.currentState!.save();
    for (var key in _contactFormKeys) {
      key.currentState!.save();
    }

    _updatedData['gst_legal_name'] = _gstLegalNameController.text;
    _updatedData['gst_trade_name'] = _gstTradeNameController.text;
    _updatedData['gst_address'] = _gstAddressController.text;
    _updatedData['msme_number'] = _msmeController.text;
    _updatedData['aadhaar_name'] = _aadhaarNameController.text;
    _updatedData['name'] = _aadhaarNameController.text;
    _updatedData['aadhaar_dob'] = _aadhaarDobController.text;
    _updatedData['aadhaar_address'] = _aadhaarAddressController.text;
    _updatedData['pan_number'] = _panController.text;
    _updatedData['designation'] = _designationController.text;
    _updatedData['profile_image'] = _profileImagePath;
    _updatedData['gst_certificate'] = _gstCertificatePath;
    _updatedData['aadhar_card'] = _aadhaarCardPath;
    _updatedData['pan_card'] = _panCardPath;
    _updatedData['contacts'] = _contacts;

    final prefs = await SharedPreferences.getInstance();
    List<String>? partiesJsonList = prefs.getStringList('parties_list');
    if (partiesJsonList != null) {
      List<Map<String, dynamic>> partiesList = partiesJsonList
          .map((p) => jsonDecode(p) as Map<String, dynamic>)
          .toList();
      int partyIndex =
          partiesList.indexWhere((p) => p['id'] == _updatedData['id']);
      if (partyIndex != -1) {
        partiesList[partyIndex] = _updatedData;
        List<String> updatedPartiesJsonList =
            partiesList.map((p) => jsonEncode(p)).toList();
        await prefs.setStringList('parties_list', updatedPartiesJsonList);
        Fluttertoast.showToast(msg: "Customer details updated successfully");
        if (mounted) Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Error: Could not find customer to update");
      }
    }
  }

  void _addContact() {
    setState(() {
      _contacts.add({
        'name': '',
        'designation': '',
        'email': '',
        'phones': ['']
      });
      _contactFormKeys.add(GlobalKey<FormState>());
    });
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
      _contactFormKeys.removeAt(index);
    });
  }

  void _addPhoneToContact(int contactIndex) {
    setState(() {
      (_contacts[contactIndex]['phones'] as List).add('');
    });
  }

  void _removePhoneFromContact(int contactIndex, int phoneIndex) {
    setState(() {
      (_contacts[contactIndex]['phones'] as List).removeAt(phoneIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    String? primaryContact = _updatedData['is_scaffolding_id'] == true
        ? _updatedData['scaffolding_id']
        : _updatedData['mobile_number'];

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
            text: "Edit Customer", size: 18, color: Colors.white),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_updatedData['register_type'] == '1') ...[
                _buildSectionTitle("GST Information"),
                _buildReadOnlyInfo("GST Number", _updatedData['gst_number']),
                _buildTextFormField(
                    controller: _gstLegalNameController, label: "Legal Name"),
                _buildTextFormField(
                    controller: _gstTradeNameController, label: "Trade Name"),
                _buildTextFormField(
                    controller: _gstAddressController,
                    label: "Address",
                    maxLines: 3),
                _buildReadOnlyInfo("Mobile Number", primaryContact),
                _buildTextFormField(
                    controller: _msmeController, label: "MSME Number"),
                _buildFilePicker("GST Certificate (PDF)", _gstCertificatePath,
                    (path) => setState(() => _gstCertificatePath = path)),
              ],
              if (_updatedData['register_type'] == '2') ...[
                _buildSectionTitle("Aadhaar Information"),
                _buildReadOnlyInfo(
                    "Aadhaar Number", _updatedData['aadhar_number']),
                _buildTextFormField(
                    controller: _aadhaarNameController, label: "Name"),
                _buildTextFormField(
                    controller: _aadhaarDobController, label: "Date of Birth"),
                _buildTextFormField(
                    controller: _aadhaarAddressController,
                    label: "Address",
                    maxLines: 3),
                _buildReadOnlyInfo("Mobile Number", primaryContact),
                _buildSectionTitle("Profile Image"),
                _buildImagePicker("Profile Image", _profileImagePath,
                    (path) => setState(() => _profileImagePath = path)),
                _buildTextFormField(
                    controller: _panController, label: "PAN Number"),
                _buildImagePicker("Aadhaar Card", _aadhaarCardPath,
                    (path) => setState(() => _aadhaarCardPath = path)),
                _buildImagePicker("PAN Card", _panCardPath,
                    (path) => setState(() => _panCardPath = path)),
              ],
              _buildSectionTitle("Additional Information"),
              _buildTextFormField(
                  controller: _designationController, label: "Designation"),
              _buildSectionTitle("Contact Persons"),
              _buildContactsSection(),
              const SizedBox(height: 30),
              PrimaryButton(onTap: _saveParty, text: "Save Changes"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // === HELPER METHODS (Fully Implemented) ===

  Widget _buildReadOnlyInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomText(text: label, size: 14, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        CustomText(
            text: value ?? '9599734137', size: 16, weight: FontWeight.w500),
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
                setState(() => onFileSelected(result.files.single.path!));
              }
            },
          ),
        )
      ]),
    );
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

  Widget _buildTextFormField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    void Function(String?)? onSaved,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildImagePicker(String title, String? currentImagePath,
      Function(String) onImageSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomText(text: title, weight: FontWeight.w500),
        const SizedBox(height: 10),
        Center(
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8)),
            child: currentImagePath != null &&
                    File(currentImagePath).existsSync()
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
              final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() => onImageSelected(image.path));
              }
            },
          ),
        )
      ]),
    );
  }

  Widget _buildContactsSection() {
    return Column(
      children: [
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _contactFormKeys[index],
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                              text: "Contact ${index + 1}",
                              weight: FontWeight.bold,
                              color: ThemeColors.kPrimaryThemeColor),
                          IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _removeContact(index)),
                        ],
                      ),
                      _buildTextFormField(
                          label: "Name",
                          initialValue: _contacts[index]['name'],
                          isRequired: true,
                          onSaved: (value) => _contacts[index]['name'] = value),
                      _buildTextFormField(
                          label: "Designation",
                          initialValue: _contacts[index]['designation'],
                          onSaved: (value) =>
                              _contacts[index]['designation'] = value),
                      _buildTextFormField(
                          label: "Email",
                          initialValue: _contacts[index]['email'],
                          onSaved: (value) => _contacts[index]['email'] = value,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 8),
                      const CustomText(text: "Phone Numbers", size: 14),
                      ..._buildPhoneFields(index),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Phone"),
                            onPressed: () => _addPhoneToContact(index)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Add Contact Person"),
          onPressed: _addContact,
          style: OutlinedButton.styleFrom(
              side: BorderSide(color: ThemeColors.kPrimaryThemeColor),
              foregroundColor: ThemeColors.kPrimaryThemeColor),
        ),
      ],
    );
  }

  List<Widget> _buildPhoneFields(int contactIndex) {
    List<String> phones =
        List<String>.from(_contacts[contactIndex]['phones'] ?? ['']);
    if (phones.isEmpty) phones.add('');

    return List<Widget>.generate(phones.length, (phoneIndex) {
      // 2. Use a TextEditingController for each field to allow dynamic updates
      final phoneController = TextEditingController(text: phones[phoneIndex]);

      // When saving, we need to read from the controller
      _contacts[contactIndex]['phones'][phoneIndex] = phoneController.text;

      return Row(
        children: [
          Expanded(
            child: _buildTextFormField(
              controller: phoneController, // Use the controller
              label: "Phone ${phoneIndex + 1}",
              onSaved: (value) {
                // The value is now saved from the controller
                _contacts[contactIndex]['phones'][phoneIndex] = value ?? '';
              },
              keyboardType: TextInputType.phone,
            ),
          ),
          // 3. Add the new icon button to open the contact picker
          IconButton(
            icon: Icon(Icons.contact_phone_outlined,
                color: ThemeColors.kPrimaryThemeColor),
            tooltip: "Select from Contacts",
            onPressed: () async {
              if (await FlutterContacts.requestPermission()) {
                Contact? contact = await FlutterContacts.openExternalPick();
                if (contact != null && contact.phones.isNotEmpty) {
                  setState(() {
                    // Update the controller's text, which rebuilds the field
                    phoneController.text = contact.phones.first.number;
                  });
                }
              } else {
                Fluttertoast.showToast(
                    msg: "Permission denied to read contacts");
              }
            },
          ),
          if (phones.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: () =>
                  _removePhoneFromContact(contactIndex, phoneIndex),
            ),
        ],
      );
    });
  }
}
