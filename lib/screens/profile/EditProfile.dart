import 'dart:io';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/new%20account.dart';
import 'package:scaffolding_sale/utils/colors.dart';
// Corrected the import path to a likely location
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Your existing AadhaarDetailsWidget (no changes needed here)
class AadhaarDetailsWidget extends StatefulWidget {
  const AadhaarDetailsWidget({super.key});

  @override
  State<AadhaarDetailsWidget> createState() => _AadhaarDetailsWidgetState();
}

class _AadhaarDetailsWidgetState extends State<AadhaarDetailsWidget> {
  bool _showMore = false;
  final TextEditingController _mobileController =
      TextEditingController(text: "9871227048");
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickFromCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('File'),
            onTap: () {
              Navigator.pop(context);
              _pickFromFile();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Name", "Amar Pal"),
                      _buildDetailRow("Father's Name", "S/O: Surendra Pal"),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    InkWell(
                      onTap: _showPickerOptions,
                      child: Container(
                        height: 160,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade300,
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  height: 160,
                                  width: 140,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person,
                                        size: 52, color: Colors.grey.shade700),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _buildDetailRow("Address",
                "C-294, sudama puri, biharipura, VTC: Ghaziabad, PO: Ghaziabad, Sub District: Ghaziabad, District: Ghaziabad, State: Uttar Pradesh, PIN Code: 201001"),
            _buildMobileNumberField(),
            InkWell(
              onTap: () => setState(() => _showMore = !_showMore),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_showMore ? "Show Less" : "Show More",
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                    Icon(_showMore ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blue),
                  ],
                ),
              ),
            ),
            if (_showMore) ...[
              _buildDetailRow("Aadhaar Number", "9682 6712 2227"),
              _buildDetailRow("VID", "9132 2562 0469 7545"),
              _buildDetailRow("Date of Birth", "17/06/1988"),
              _buildDetailRow("Gender", "MALE"),
              _buildDetailRow("Issue Date", "06/07/2014"),
              _buildDetailRow("Details as on", "27/03/2025"),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNumberField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mobile Number",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                hintText: "Enter mobile number", counterText: ""),
            maxLength: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter mobile number';
              }
              if (value.length != 10) {
                return 'Mobile number must be 10 digits';
              }
              return null;
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          TextFormField(
            readOnly: true,
            maxLines: value.contains("C-294") ? 4 : 1,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _msmeController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController ownerContactController = TextEditingController();

  final TextEditingController _gstLegalNameController = TextEditingController();
  final TextEditingController _gstTradeNameController = TextEditingController();
  final TextEditingController _gstAddressController = TextEditingController();
  final TextEditingController _gstCompanyTypeController =
      TextEditingController();
  final TextEditingController _gstCompanyNBa = TextEditingController();
  final TextEditingController _gstStatusController = TextEditingController();

  final TextEditingController _aadhaarDobController = TextEditingController();
  final TextEditingController _aadhaarNameController = TextEditingController();
  final TextEditingController _aadhaarAddressController =
      TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();

  String? _captchaImage, _captchaCookie;
  bool _isLoading = false;
  Map<String, dynamic> gstData = {};
  bool showApiData = false;
  bool showAadhaarData = false;
  final Map<String, String> aadhaarData = {
    "dob": "19/01/2006",
    "name": "Mayank Bajaj",
    "address":
        "E-170, ENTIRE THIRD FLOOR, SITUATED IN THE, ABADI OF D/S QTRS, Patel Nagar West, PO: Patel Nagar, DIST: Central Delhi,\nDelhi - 110008"
  };

  File? profileImage, gstCertificate, aadharCard, panCard;
  File? msmeCertificate; // New state variable for MSME certificate

  final ImagePicker _picker = ImagePicker();
  String selectedValue = "1";
  bool isScaffoldingId = false;
  String? _selectedDesignation;
  List<Map<String, dynamic>> contactsList = [];

  final List<DropdownMenuItem<String>> designationItems = [
    const DropdownMenuItem(
        value: 'Owner',
        child: Text('Company Owner', style: TextStyle(color: Colors.green))),
    const DropdownMenuItem(value: 'Accountant', child: Text('Accountant')),
    const DropdownMenuItem(
        value: 'Project Manager', child: Text('Project Manager')),
    const DropdownMenuItem(
        value: 'General Manager', child: Text('General Manager')),
    const DropdownMenuItem(
        value: 'Store Manager', child: Text('Store Manager')),
    const DropdownMenuItem(
        value: 'site engineer', child: Text('Site Engineer')),
    const DropdownMenuItem(
        value: 'Site Supervisor', child: Text('Site Supervisor')),
    const DropdownMenuItem(
        value: 'Property Owner',
        child: Text('Property Owner', style: TextStyle(color: Colors.red))),
    const DropdownMenuItem(
        value: 'Project Incharge', child: Text('Project Incharge')),
    const DropdownMenuItem(value: 'Others', child: Text('Others')),
  ];

  Future<void> _openContactList() async {
    if (await FlutterContacts.requestPermission()) {
      try {
        List<Contact> contacts = await FlutterContacts.getContacts(
            withProperties: true, withPhoto: false);
        if (!mounted) return;
        Contact? selectedContact = await showDialog<Contact>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              TextEditingController searchController = TextEditingController();
              List<Contact> filteredContacts = contacts;

              void filterContacts(String query) {
                setState(() {
                  filteredContacts = contacts
                      .where((contact) =>
                          contact.displayName
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          contact.phones.any((p) => p.number.contains(query)))
                      .toList();
                });
              }

              return AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Contact"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: "Search by name or number",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onChanged: filterContacts,
                    ),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  height: 500,
                  child: filteredContacts.isEmpty
                      ? const Center(child: Text("No contacts found"))
                      : ListView.builder(
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                  child: Text(contact.displayName.isNotEmpty
                                      ? contact.displayName[0]
                                      : "?")),
                              title: Text(contact.displayName),
                              subtitle: Text(contact.phones.isNotEmpty
                                  ? contact.phones.first.number
                                  : "No Phone Number"),
                              onTap: () => Navigator.pop(context, contact),
                            );
                          },
                        ),
                ),
              );
            },
          ),
        );

        if (selectedContact != null && selectedContact.phones.isNotEmpty) {
          setState(() {
            _controller.text =
                selectedContact.phones.first.number.replaceAll(' ', '');
            nameController.text = selectedContact.displayName;
          });
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to load contacts: $e")));
      }
    }
  }

  void _showPickerOptions({required Function(File) onFilePicked}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) onFilePicked(File(pickedFile.path));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile =
                  await _picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) onFilePicked(File(pickedFile.path));
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('File'),
            onTap: () async {
              Navigator.pop(context);
              final result = await FilePicker.platform.pickFiles();
              if (result != null) onFilePicked(File(result.files.single.path!));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCaptcha() async {
    setState(() => _isLoading = true);
    try {
      const url = "https://services.gst.gov.in/services/captcha?rnd=1";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final base64Image = base64Encode(response.bodyBytes);
        final cookieHeader = response.headers['set-cookie'];
        String captchaCookie = '';
        if (cookieHeader != null) {
          final cookies = cookieHeader.split(';');
          for (var cookie in cookies) {
            if (cookie.trim().startsWith("CaptchaCookie")) {
              captchaCookie = cookie.split('=')[1];
              break;
            }
          }
        }
        setState(() {
          _captchaImage = base64Image;
          _captchaCookie = captchaCookie;
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch captcha.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchGstDetails(
      String gstNumber, String captcha) async {
    setState(() => _isLoading = true);
    try {
      const url =
          "https://services.gst.gov.in/services/api/search/taxpayerDetails";
      final payload = {"gstin": gstNumber, "captcha": captcha};
      final headers = {
        "cookie": "CaptchaCookie=$_captchaCookie",
        "Content-Type": "application/json"
      };
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('errorCode')) {
          if (data['errorCode'] == "SWEB_9035")
            Fluttertoast.showToast(msg: "Invalid GST Number.");
          else if (data['errorCode'] == "SWEB_9000")
            Fluttertoast.showToast(msg: "Invalid Captcha.");
          return null;
        } else {
          Fluttertoast.showToast(msg: "GST Data Fetched Successfully");
          return data;
        }
      } else {
        Fluttertoast.showToast(msg: "Failed to fetch GST details.");
        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _showGstCaptchaDialog() async {
    await _fetchCaptcha();
    String captchaInput = '';
    return await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        String? captchaImage = _captchaImage;
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("GST Captcha Verification"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              if (captchaImage != null)
                Image.memory(base64Decode(captchaImage!), height: 60),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                      decoration: const InputDecoration(
                          labelText: 'Enter Captcha',
                          border: OutlineInputBorder()),
                      onChanged: (val) => captchaInput = val),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: "Refresh Captcha",
                  onPressed: () async {
                    setStateDialog(() => isLoading = true);
                    await _fetchCaptcha();
                    setStateDialog(() {
                      captchaImage = _captchaImage;
                      isLoading = false;
                    });
                  },
                ),
              ]),
              if (isLoading)
                const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: CircularProgressIndicator()),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () async {
                  if (captchaInput.isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter captcha");
                    return;
                  }
                  setStateDialog(() => isLoading = true);
                  final data =
                      await _fetchGstDetails(_controller.text, captchaInput);
                  setStateDialog(() => isLoading = false);
                  if (data != null) Navigator.pop(context, data);
                },
                child: const Text("Verify"),
              ),
            ],
          );
        });
      },
    );
  }

  Future<bool> _showAadhaarOtpDialog() async {
    _aadhaarOtpController.clear();
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("OTP Verification"),
            content: TextField(
                controller: _aadhaarOtpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                    labelText: "Enter 6-digit OTP",
                    border: OutlineInputBorder())),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  if (_aadhaarOtpController.text == "640532") {
                    Fluttertoast.showToast(msg: " Verified Successfully");
                    Navigator.pop(context, true);
                  } else {
                    Fluttertoast.showToast(msg: "Invalid OTP");
                  }
                },
                child: const Text("Verify"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickContact() async {
    Permission.contacts.request();
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        if (fullContact?.phones.isNotEmpty == true) {
          if (fullContact!.phones.length > 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Phone Number'),
                  content: Container(
                    width: double.minPositive,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: fullContact.phones.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(fullContact.phones[index].number),
                          onTap: () {
                            String cleanNumber = fullContact
                                .phones[index].number
                                .replaceAll(RegExp(r'[^\d]'), '');
                            if (cleanNumber.length > 10) {
                              cleanNumber = cleanNumber
                                  .substring(cleanNumber.length - 10);
                            }
                            setState(() {
                              ownerContactController.text = cleanNumber;
                            });

                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            String cleanNumber = fullContact.phones.first.number
                .replaceAll(RegExp(r'[^\d]'), '');
            if (cleanNumber.length > 10) {
              cleanNumber = cleanNumber.substring(cleanNumber.length - 10);
              setState(() {
                ownerContactController.text = cleanNumber;
              });
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing contacts: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> savePartyData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> partiesJsonList = prefs.getStringList('parties_list') ?? [];

    Map<String, dynamic> partyData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'register_type': selectedValue,
      'is_scaffolding_id': isScaffoldingId,
      'gst_number': selectedValue == '1' ? _controller.text : null,
      'aadhar_number': selectedValue == '2' ? _controller.text : null,
      'scaffolding_id':
          (selectedValue == '3' && isScaffoldingId) ? _controller.text : null,
      'mobile_number':
          (selectedValue == '3' && !isScaffoldingId) ? _controller.text : null,
      'name': nameController.text,
      'owner_contact_number': ownerContactController.text,
      'email': emailController.text,
      'designation': _selectedDesignation,
      'contacts': contactsList,
      'msme_number': _msmeController.text,
      'pan_number': _panController.text,
      'profile_image': profileImage?.path,
      'gst_certificate': gstCertificate?.path,
      'aadhar_card': aadharCard?.path,
      'pan_card': panCard?.path,
      'msme_certificate': msmeCertificate?.path,
      'gst_data': gstData,
      'gst_legal_name': _gstLegalNameController.text,
      'gst_trade_name': _gstTradeNameController.text,
      'gst_address': _gstAddressController.text,
      'gst_company_type': _gstCompanyTypeController.text,
      'gst_status': _gstStatusController.text,
      'aadhaar_dob': _aadhaarDobController.text,
      'aadhaar_name': _aadhaarNameController.text,
      'aadhaar_address': _aadhaarAddressController.text,
      'created_at': DateTime.now().toIso8601String(),
    };

    partiesJsonList.add(jsonEncode(partyData));
    await prefs.setStringList('parties_list', partiesJsonList);
    return partyData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
        title: const Text('Add Party', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showPickerOptions(
                      onFilePicked: (file) =>
                          setState(() => profileImage = file)),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.black54)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: 'Register Type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0))),
                value: selectedValue,
                items: const [
                  DropdownMenuItem(value: '1', child: Text('GST Registered')),
                  DropdownMenuItem(value: '2', child: Text('Unregistered')),
                  DropdownMenuItem(value: '3', child: Text('Already a User?')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                    showApiData = false;
                    showAadhaarData = false;
                    _controller.clear();
                    nameController.clear();
                    _gstLegalNameController.clear();
                    _gstTradeNameController.clear();
                    _gstAddressController.clear();
                    _gstCompanyTypeController.clear();
                    _gstStatusController.clear();
                    _aadhaarDobController.clear();
                    _aadhaarNameController.clear();
                    _aadhaarAddressController.clear();
                    gstData = {};
                  });
                },
              ),
              const SizedBox(height: 16),
              if (selectedValue == "3")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomText(text: "Mobile Number"),
                    Radio<bool>(
                        value: false,
                        groupValue: isScaffoldingId,
                        onChanged: (v) => setState(() => isScaffoldingId = v!)),
                    const SizedBox(width: 20),
                    const CustomText(text: "Scaffolding ID"),
                    Radio<bool>(
                        value: true,
                        groupValue: isScaffoldingId,
                        onChanged: (v) => setState(() => isScaffoldingId = v!)),
                  ],
                ),
              Text(
                selectedValue == "1"
                    ? "GST Number"
                    : selectedValue == "2"
                        ? "Aadhaar Card Number"
                        : isScaffoldingId
                            ? "Scaffolding ID"
                            : 'Mobile Number',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              RegisterField(
                hint: selectedValue == "1"
                    ? 'Enter GST Number'
                    : selectedValue == "2"
                        ? 'Enter Aadhaar Number'
                        : isScaffoldingId
                            ? 'Enter Scaffolding ID'
                            : 'Enter Mobile Number',
                controller: _controller,
                keyboardType: selectedValue != "1"
                    ? TextInputType.number
                    : TextInputType.text,
                suffixIcon: (selectedValue == "3" && !isScaffoldingId)
                    ? IconButton(
                        onPressed: _openContactList,
                        icon: const Icon(Icons.contact_page_outlined))
                    : null,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (selectedValue != '1')
                    TextButton.icon(
                        onPressed: () =>
                            Fluttertoast.showToast(msg: "Scan/Upload Tapped"),
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text("Scan / Upload")),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      if (_controller.text.isEmpty) {
                        Fluttertoast.showToast(
                            msg: selectedValue == "1"
                                ? "Enter GST Number"
                                : "Enter Aadhaar Number");
                        return;
                      }
                      if (selectedValue == "1") {
                        final data = await _showGstCaptchaDialog();
                        if (data != null) {
                          setState(() {
                            gstData = data;
                            showApiData = true;
                            showAadhaarData = false;
                            print(data.toString());
                            _gstLegalNameController.text = data['lgnm'] ?? '';
                            _gstTradeNameController.text =
                                data['tradeNam'] ?? '';
                            _gstAddressController.text =
                                data['pradr']?['adr'] ?? '';
                            _gstCompanyTypeController.text = data['ctb'] ?? '';
                            _gstCompanyNBa.text = data['nba'].toString() ?? '';
                            _gstStatusController.text = data['sts'] ?? '';
                            nameController.text = data['lgnm'] ?? '';
                          });
                        }
                      } else if (selectedValue == "2" || selectedValue == "3") {
                        final verified = await _showAadhaarOtpDialog();
                        if (verified) {
                          setState(() {
                            showAadhaarData = true;
                            showApiData = false;
                            _aadhaarDobController.text = aadhaarData["dob"]!;
                            _aadhaarNameController.text = aadhaarData["name"]!;
                            _aadhaarAddressController.text =
                                aadhaarData["address"]!;
                            nameController.text = aadhaarData["name"]!;
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.verified_user_outlined),
                    label: const Text("Verify"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (showAadhaarData &&
                  (selectedValue == "2" || selectedValue == "3")) ...[
                const Text("Verified Aadhaar Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const AadhaarDetailsWidget()
              ],
              if (showApiData && gstData.isNotEmpty) ...[
                const Text("Verified GST Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                RegisterField(
                    hint: "GST Status",
                    controller: _gstStatusController,
                    enabled: false),
                const SizedBox(height: 10),
                RegisterField(
                    hint: "Legal Name",
                    controller: _gstLegalNameController,
                    enabled: false),
                const SizedBox(height: 10),
                RegisterField(
                    hint: "Trade Name",
                    controller: _gstTradeNameController,
                    enabled: false),
                const SizedBox(height: 10),
                TextFormField(
                    controller: _gstAddressController,
                    enabled: false,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)))),
                const SizedBox(height: 10),
                RegisterField(
                    hint: "Company Type",
                    controller: _gstCompanyTypeController,
                    enabled: false),
                const SizedBox(height: 16),
                // RegisterField(
                //     maxLines: 3,
                //     hint: "Company Details",
                //     controller: _gstCompanyNBa,
                //     enabled: false),
                // const SizedBox(height: 16),
              ],
              if (!showApiData && !showAadhaarData || selectedValue == "3") ...[
                RegisterField(hint: 'Name', controller: nameController),
                const SizedBox(height: 10)
              ],
              RegisterField(
                suffixIcon: InkWell(
                    onTap: _pickContact, child: Icon(Icons.contact_emergency)),
                hint: 'Owner Contact Number',
                controller: ownerContactController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    hintText: 'Select Designation',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 13)),
                value: _selectedDesignation,
                items: designationItems,
                onChanged: (value) =>
                    setState(() => _selectedDesignation = value),
                isExpanded: true,
                validator: (value) =>
                    value == null ? 'Please select a designation' : null,
              ),
              const SizedBox(height: 10),
              RegisterField(
                suffixIcon: Icon(
                  Icons.done,
                  color: ThemeColors.kPrimaryThemeColor,
                ),
                hint: 'Email Address',
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  // This is a standard regular expression for email validation.
                  final bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value);

                  if (!emailValid) {
                    return 'Please enter a valid email address';
                  }

                  return null; // Return null if the input is valid
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildUploadBox(
                      title: selectedValue == "1"
                          ? 'G.S.T Certificate'
                          : "Aadhaar Card",
                      imageFile:
                          selectedValue == "1" ? gstCertificate : aadharCard,
                      onTap: () => _showPickerOptions(
                        onFilePicked: (file) => setState(() {
                          if (selectedValue == "1")
                            gstCertificate = file;
                          else
                            aadharCard = file;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: selectedValue == "1"
                        ? _buildUploadBox(
                            title: "MSME Certificate",
                            imageFile: msmeCertificate,
                            onTap: () => _showPickerOptions(
                                onFilePicked: (file) =>
                                    setState(() => msmeCertificate = file)),
                          )
                        : _buildUploadBox(
                            title: "PAN Card",
                            imageFile: panCard,
                            onTap: () => _showPickerOptions(
                                onFilePicked: (file) =>
                                    setState(() => panCard = file)),
                          ),
                  ),
                ],
              ),
              if (selectedValue == "2") ...[
                const SizedBox(height: 16),
                const Text("PAN Number",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                RegisterField(
                    hint: 'Enter PAN Number', controller: _panController),
              ],
              const SizedBox(height: 30),
              PrimaryButton(
                onTap: () async {
                  if (_selectedDesignation == null) {
                    Fluttertoast.showToast(msg: "Please select a designation");
                    return;
                  }
                  if (_controller.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Please enter the primary ID (GST/Aadhaar/etc)");
                    return;
                  }
                  if (nameController.text.isEmpty &&
                      !showApiData &&
                      !showAadhaarData) {
                    Fluttertoast.showToast(msg: "Please enter a name");
                    return;
                  }

                  final newPartyData = await savePartyData();

                  if (mounted) {
                    Fluttertoast.showToast(msg: "Party Added Successfully");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewAccountScreen(
                          accountType: "Sale",
                        ),
                      ),
                    );
                  }
                },
                text: "Create Party & Proceed",
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox(
      {required String title,
      required File? imageFile,
      required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(imageFile,
                      height: 150, width: double.infinity, fit: BoxFit.cover),
                )
              : DottedBorder(
                  color: Colors.grey.shade600,
                  strokeWidth: 1.5,
                  dashPattern: const [6, 4],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              color: Colors.grey.shade700, size: 40),
                          const SizedBox(height: 8),
                          Text("Tap to upload",
                              style: TextStyle(color: Colors.grey.shade700)),
                        ]),
                  ),
                ),
        ),
      ],
    );
  }
}
