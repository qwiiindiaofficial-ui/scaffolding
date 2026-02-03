import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/auth/register/radiusdialoge.dart';
import 'package:scaffolding_sale/screens/auth/register/scanner.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:http/http.dart' as http;

// Import the new QR scanner screen

class RegisterForm extends StatefulWidget {
  final String phone;
  const RegisterForm({super.key, required this.phone});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  XFile? _selectedImage;
  File? signature;

  final ImagePicker _picker = ImagePicker();

  String? _selectedCateringOption;
  int _selectedRadius = 25;

  bool isCertified = false;
  final Map<int, bool> _selectedValues = {
    1: false,
    2: false,
    3: false,
    4: false,
  };

  // ISO, E-Way Bill fields
  final TextEditingController _isoController = TextEditingController();
  final TextEditingController _ewayIdController = TextEditingController();
  final TextEditingController _ewayPassController = TextEditingController();

  List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Daman and Diu',
    'Lakshadweep',
    'Delhi',
    'Puducherry',
  ];

  Future<void> _pickFromFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      print('Picked file: ${result.files.single.path}');
    }
  }

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      print('Picked image from camera: ${pickedFile.path}');
    }
  }

  Future<void> _pickSignatureFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final croppedImage = await _cropImage(image.path, "Crop Signature");
      if (croppedImage != null) {
        setState(() {
          signature = File(croppedImage.path);
        });
      }
    }
  }

  Future<void> _pickAndCropLogo() async {
    final XFile? original =
        await _picker.pickImage(source: ImageSource.gallery);
    if (original == null) return;
    final CroppedFile? cropped = await _cropImage(original.path, "Crop Logo");
    if (cropped == null) return;
    setState(() {
      _selectedImage = XFile(cropped.path);
    });
  }

  Future<CroppedFile?> _cropImage(String sourcePath, String title) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true),
        IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false),
      ],
      compressQuality: 100,
      maxWidth: 300,
      maxHeight: 300,
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickFromCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickSignatureFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('File'),
            onTap: () {
              Navigator.pop(context);
              _pickFromFile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Hand Signature'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    insetPadding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      width: MediaQuery.of(context).size.width,
                      child: const HandSignatureDialog(),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  // GST Section
  Map<String, dynamic> gstData = {};
  final TextEditingController _gstController = TextEditingController();
  bool showApiData = false;
  String? _status = 'registered';

  // Aadhaar Section
  bool showAadhaarData = false;
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _aadhaarOtpController = TextEditingController();
  final Map<String, String> aadhaarData = {
    "dob": "19/01/2006",
    "name": "Mayank Bajaj",
    "address":
        "E-170, ENTIRE THIRD FLOOR, SITUATED IN THE, ABADI OF D/S QTRS, Patel Nagar West, PO: Patel Nagar, DIST: Central Delhi,\nDelhi - 110008"
  };

  // GST Captcha
  String? _captchaImage;
  String? _captchaCookie;
  bool _isLoading = false;

  // GST Data Controllers
  final TextEditingController _gstLegalNameController = TextEditingController();
  final TextEditingController _gstTradeNameController = TextEditingController();
  final TextEditingController _gstAddressController = TextEditingController();
  final TextEditingController _gstCompanyTypeController =
      TextEditingController();
  final TextEditingController _gstStatusController = TextEditingController();

  // Aadhaar Data Controllers
  final TextEditingController _aadhaarDobController = TextEditingController();
  final TextEditingController _aadhaarNameController = TextEditingController();
  final TextEditingController _aadhaarAddressController =
      TextEditingController();

  // ----- NEW: Aadhaar QR Scan Method -----
  Future<void> _scanAadhaarQr() async {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => Container()),
    );

    Future.delayed(Duration(seconds: 7), () {
      Navigator.pop(context);
    });

    Fluttertoast.showToast(msg: "Aadhaar Verified Successfully via QR");
    setState(() {
      showAadhaarData = true;
      showApiData = false; // Hide GST data if it was shown
      _aadhaarDobController.text = aadhaarData["dob"]!;
      _aadhaarNameController.text = aadhaarData["name"]!;
      _aadhaarAddressController.text = aadhaarData["address"]!;
      _aadhaarController.text = "xxxx-xxxx-1234"; // Dummy number
    });
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
        "Content-Type": "application/json",
      };
      final response = await http.post(Uri.parse(url),
          headers: headers, body: jsonEncode(payload));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('errorCode')) {
          if (data['errorCode'] == "SWEB_9035") {
            Fluttertoast.showToast(msg: "Invalid GST Number.");
          } else if (data['errorCode'] == "SWEB_9000") {
            Fluttertoast.showToast(msg: "Invalid Captcha.");
          }
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
    return null;
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
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                      onChanged: (val) => captchaInput = val,
                    ),
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
                    final data = await _fetchGstDetails(
                        _gstController.text, captchaInput);
                    setStateDialog(() => isLoading = false);
                    if (data != null) Navigator.pop(context, data);
                  },
                  child: const Text("Verify"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _showAadhaarOtpDialog() async {
    _aadhaarOtpController.clear();
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Aadhaar OTP Verification"),
            content: TextField(
              controller: _aadhaarOtpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                  labelText: "Enter 6-digit OTP", border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                onPressed: () {
                  if (_aadhaarOtpController.text == "409590") {
                    Fluttertoast.showToast(
                        msg: "Aadhaar Verified Successfully");
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

  Map<String, dynamic> collectFormData() {
    return {
      "phone": widget.phone,
      "gst_status": _status,
      "gst_number": _gstController.text,
      "aadhaar_number": _aadhaarController.text,
      "gst_legal_name": _gstLegalNameController.text,
      "gst_trade_name": _gstTradeNameController.text,
      "gst_address": _gstAddressController.text,
      "gst_company_type": _gstCompanyTypeController.text,
      "gst_status_text": _gstStatusController.text,
      "gst_api_data": gstData,
      "aadhaar_dob": _aadhaarDobController.text,
      "aadhaar_name": _aadhaarNameController.text,
      "aadhaar_address": _aadhaarAddressController.text,
      "logo_path": _selectedImage?.path,
      "catering_option": _selectedCateringOption,
      "catering_radius": _selectedRadius,
      "iso_certified": isCertified,
      "iso_number": _isoController.text,
      "eway_bill_id": _ewayIdController.text,
      "eway_bill_password": _ewayPassController.text,
      "scope_of_work": {
        "sale": _selectedValues[1] ?? false,
        "rental": _selectedValues[2] ?? false,
        "contractor": _selectedValues[3] ?? false,
        "service": _selectedValues[4] ?? false,
      },
      "signature_path": signature?.path,
    };
  }

  Future<void> createCompanyAndProfile(Map<String, dynamic> data) async {
    try {
      final appController = AppController.to;
      final authUser = appController.authService.currentUser;

      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      final companyName = data['gst_legal_name'] ?? data['aadhaar_name'] ?? 'Company';
      final gstNumber = data['gst_number'] ?? '';

      final company = await appController.companyService.createCompany(
        name: companyName,
        gstNumber: gstNumber.isNotEmpty ? gstNumber : null,
        billingAddress: data['gst_address'] ?? data['aadhaar_address'] ?? '',
        phone: '+91${widget.phone}',
        ownerName: data['aadhaar_name'],
        businessType: data['gst_company_type'],
      );

      await appController.authService.createUserProfile(
        userId: authUser.id,
        companyId: company['id'],
        phoneNumber: '+91${widget.phone}',
        fullName: data['aadhaar_name'],
        role: 'admin',
      );

      await appController.loadUserProfile(authUser.id);
    } catch (e) {
      throw Exception('Failed to create company: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kWhiteTextColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
            text: "Create Company",
            size: 18,
            color: ThemeColors.kWhiteTextColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                      labelText: 'GST Status',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  items: const [
                    DropdownMenuItem(
                        value: 'registered',
                        child: CustomText(text: "GST Registered", size: 16)),
                    DropdownMenuItem(
                        value: 'unregistered',
                        child: CustomText(text: "GST Unregistered", size: 16)),
                  ],
                  onChanged: (value) => setState(() {
                    _status = value;
                    showApiData = false;
                    showAadhaarData = false;
                    gstData.clear();
                    _gstController.clear();
                    _aadhaarController.clear();
                    _gstLegalNameController.clear();
                    _gstTradeNameController.clear();
                    _gstAddressController.clear();
                    _gstCompanyTypeController.clear();
                    _gstStatusController.clear();
                    _aadhaarDobController.clear();
                    _aadhaarNameController.clear();
                    _aadhaarAddressController.clear();
                  }),
                  validator: (value) =>
                      value == null ? 'Please select GST status' : null,
                ),
                const SizedBox(height: 16),
                if (_status == "registered") ...[
                  CustomText(text: "GST Number", weight: FontWeight.w500),
                  const SizedBox(height: 8),
                  RegisterField(
                    hint: "Enter your GST Number",
                    controller: _gstController,
                    validator: (val) => (_status == 'registered' &&
                            (val == null || val.isEmpty))
                        ? "GST Number required"
                        : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text("Verify GST"),
                      onPressed: () async {
                        if (_gstController.text.isEmpty) {
                          Fluttertoast.showToast(msg: "Enter GST Number");
                          return;
                        }
                        final data = await _showGstCaptchaDialog();
                        if (data != null) {
                          setState(() {
                            gstData = data;
                            showApiData = true;
                            showAadhaarData = false;
                            _gstLegalNameController.text = data['lgnm'] ?? '';
                            _gstTradeNameController.text =
                                data['tradeNam'] ?? '';
                            _gstAddressController.text =
                                data['pradr']?['adr'] ?? '';
                            _gstCompanyTypeController.text = data['ctb'] ?? '';
                            _gstStatusController.text = data['sts'] ?? '';
                          });
                        }
                      },
                    ),
                  ),
                ],
                CustomText(
                    text: "Aadhaar Verification", weight: FontWeight.w500),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RegisterField(
                        hint: "Enter Aadhaar Number",
                        controller: _aadhaarController,
                        validator: (val) => (val == null || val.isEmpty)
                            ? "Aadhaar Number required"
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomText(
                          text: "OR", color: Colors.grey.shade600, size: 14),
                    ),
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner_rounded,
                          color: ThemeColors.kPrimaryThemeColor, size: 36),
                      onPressed: _scanAadhaarQr,
                      tooltip: "Scan Aadhaar QR Code",
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.send_to_mobile),
                    label: const Text("Verify with OTP"),
                    onPressed: () async {
                      if (_aadhaarController.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Enter Aadhaar Number");
                        return;
                      }
                      final verified = await _showAadhaarOtpDialog();
                      if (verified) {
                        setState(() {
                          showAadhaarData = true;
                          showApiData = false;
                          _aadhaarDobController.text = aadhaarData["dob"]!;
                          _aadhaarNameController.text = aadhaarData["name"]!;
                          _aadhaarAddressController.text =
                              aadhaarData["address"]!;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (showAadhaarData) ...[
                  Row(children: [
                    Expanded(
                        child: RegisterField(
                            hint: "DOB",
                            controller: _aadhaarDobController,
                            enabled: false)),
                    const SizedBox(width: 10),
                    CustomText(
                        text: "19+ Years",
                        color: ThemeColors.kPrimaryThemeColor,
                        size: 18,
                        weight: FontWeight.bold)
                  ]),
                  const SizedBox(height: 10),
                  RegisterField(
                      hint: "Name",
                      controller: _aadhaarNameController,
                      enabled: true),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _aadhaarAddressController,
                    minLines: 3,
                    maxLines: 5,
                    enabled: true,
                    decoration: InputDecoration(
                      labelText: "Address",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (showApiData && gstData.isNotEmpty) ...[
                  RegisterField(
                      hint: "GST Status", controller: _gstStatusController),
                  const SizedBox(height: 10),
                  RegisterField(
                      hint: "Legal Name", controller: _gstLegalNameController),
                  const SizedBox(height: 10),
                  RegisterField(
                      hint: "Trade Name", controller: _gstTradeNameController),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _gstAddressController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                        labelText: "Address",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                  const SizedBox(height: 10),
                  RegisterField(
                      hint: "Company Type",
                      controller: _gstCompanyTypeController),
                  const SizedBox(height: 16),
                ],
                CustomText(text: "Company Logo", weight: FontWeight.w500),
                const SizedBox(height: 8),
                if (_selectedImage == null)
                  GestureDetector(
                    onTap: _pickAndCropLogo,
                    child: DottedBorder(
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
                              CustomText(
                                  text: "Tap to upload logo",
                                  color: Colors.grey.shade700),
                            ]),
                      ),
                    ),
                  )
                else
                  Stack(alignment: Alignment.topRight, children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedImage!.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                            onPressed: _pickAndCropLogo),
                      ),
                    )
                  ]),
                const SizedBox(height: 16),
                AddStoreForm(showStore: true, phone: widget.phone),
                const CustomText(
                    text: "Catering To", size: 18, weight: FontWeight.w500),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCateringOption,
                  decoration: InputDecoration(
                      hintText: 'Select an Option',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0))),
                  items: const [
                    DropdownMenuItem(
                        value: '1', child: CustomText(text: "Pan India")),
                    DropdownMenuItem(
                        value: '2', child: CustomText(text: "Domestic")),
                  ],
                  onChanged: (value) async {
                    setState(() => _selectedCateringOption = value);
                    if (value == '2') {
                      final result = await showDialog<int>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) =>
                            RadiusSelectionDialog(
                                initialRadius: _selectedRadius),
                      );
                      if (result != null)
                        setState(() => _selectedRadius = result);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Please select an option' : null,
                ),
                const SizedBox(height: 12),
                if (_selectedCateringOption == '2')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: Row(children: [
                      Icon(Icons.radio_button_checked,
                          color: ThemeColors.kPrimaryThemeColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                  text: "Selected Radius: $_selectedRadius km",
                                  weight: FontWeight.w500),
                              const SizedBox(height: 4),
                              CustomText(
                                  text:
                                      "Your service area covers $_selectedRadius km radius",
                                  size: 12,
                                  color: Colors.grey.shade700),
                            ]),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: ThemeColors.kPrimaryThemeColor),
                        onPressed: () async {
                          final result = await showDialog<int>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) =>
                                RadiusSelectionDialog(
                                    initialRadius: _selectedRadius),
                          );
                          if (result != null)
                            setState(() => _selectedRadius = result);
                        },
                      ),
                    ]),
                  ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const CustomText(
                      text: "ISO Certified?", weight: FontWeight.w500),
                  checkColor: Colors.white,
                  activeColor: ThemeColors.kPrimaryThemeColor,
                  value: isCertified,
                  onChanged: (value) => setState(() => isCertified = value!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (isCertified)
                  RegisterField(
                      hint: "Enter ISO Certification Number",
                      controller: _isoController),
                const SizedBox(height: 16),
                if (_status != 'unregistered') ...[
                  RegisterField(
                      hint: "E-Way Bill ID", controller: _ewayIdController),
                  const SizedBox(height: 12),
                  RegisterField(
                      hint: "E-Way Bill Password",
                      controller: _ewayPassController),
                ],
                const SizedBox(height: 12),
                const CustomText(
                    text: "Scope Of Work", size: 18, weight: FontWeight.w500),
                Row(children: [
                  Expanded(
                      child: CheckboxListTile(
                          title: const CustomText(
                              text: "Sale", weight: FontWeight.w500),
                          value: _selectedValues[1],
                          onChanged: (value) =>
                              setState(() => _selectedValues[1] = value!))),
                  Expanded(
                      child: CheckboxListTile(
                          title: const CustomText(
                              text: "Rental", weight: FontWeight.w500),
                          value: _selectedValues[2],
                          onChanged: (value) =>
                              setState(() => _selectedValues[2] = value!))),
                ]),
                Row(children: [
                  Expanded(
                      child: CheckboxListTile(
                          title: const CustomText(
                              text: "Contractor", weight: FontWeight.w500),
                          value: _selectedValues[3],
                          onChanged: (value) =>
                              setState(() => _selectedValues[3] = value!))),
                  Expanded(
                      child: CheckboxListTile(
                          title: const CustomText(
                              text: "Service", weight: FontWeight.w500),
                          value: _selectedValues[4],
                          onChanged: (value) =>
                              setState(() => _selectedValues[4] = value!))),
                ]),
                const SizedBox(height: 16),
                CustomText(text: "Upload Signature", weight: FontWeight.w500),
                const SizedBox(height: 8),
                if (signature == null)
                  GestureDetector(
                    onTap: _showPickerOptions,
                    child: DottedBorder(
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
                              Icon(Icons.draw_outlined,
                                  color: Colors.grey.shade700, size: 40),
                              const SizedBox(height: 8),
                              CustomText(
                                  text: "Tap to upload/draw signature",
                                  color: Colors.grey.shade700),
                            ]),
                      ),
                    ),
                  )
                else
                  Stack(alignment: Alignment.topRight, children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(signature!, fit: BoxFit.contain)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                            onPressed: _showPickerOptions),
                      ),
                    )
                  ]),
                const SizedBox(height: 30),
                PrimaryButton(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        showLoadingDialog('Creating company profile...');
                        final data = collectFormData();
                        await createCompanyAndProfile(data);
                        closeLoadingDialog();
                        showSuccess('Profile created successfully');
                        if (mounted) {
                          Get.offAll(() => HomeScreen(phone: widget.phone));
                        }
                      } catch (e) {
                        closeLoadingDialog();
                        handleError(e);
                      }
                    }
                  },
                  text: "Save Profile",
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
