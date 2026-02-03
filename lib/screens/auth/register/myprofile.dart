import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffolding_sale/screens/auth/register/edit.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:open_file/open_file.dart';

class ProfileScreen extends StatefulWidget {
  final String phone;
  const ProfileScreen({super.key, required this.phone});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString('register_form_data');

    if (jsonData != null) {
      setState(() {
        profileData = jsonDecode(jsonData);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: value ?? 'Not provided',
            size: 16,
            weight: FontWeight.w500,
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: CustomText(
        text: title,
        size: 18,
        weight: FontWeight.w600,
        color: ThemeColors.kPrimaryThemeColor,
      ),
    );
  }

  Widget _buildLogoWidget() {
    if (profileData['logo_path'] != null &&
        File(profileData['logo_path']).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(profileData['logo_path']),
          height: 120,
          width: 120,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Generate logo from company name initials
      String companyName = profileData['gst_trade_name'] ??
          profileData['gst_legal_name'] ??
          'Company Name';
      List<String> nameParts = companyName.split(' ');
      String initials = nameParts
          .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
          .join();
      if (initials.length > 2) {
        initials = initials.substring(0, 2); // Limit to 2 initials
      }

      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: ThemeColors.kPrimaryThemeColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: CustomText(
            text: initials,
            size: 36,
            color: Colors.white,
            weight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  // NEW: Widget to display document (PDF) files
  Widget _buildDocumentDisplay(String label, String? filePath) {
    if (filePath == null || !File(filePath).existsSync()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final result = await OpenFile.open(filePath);
              if (result.type != ResultType.done) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open file: ${result.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: p.basename(filePath),
                          size: 14,
                          weight: FontWeight.w500,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: 'PDF Document • Tap to open',
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: ThemeColors.kPrimaryThemeColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Widget to display image files (for Aadhaar card image)
  Widget _buildImageDisplay(String label, String? imagePath) {
    if (imagePath == null || !File(imagePath).existsSync()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // Show full screen image viewer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _FullScreenImageViewer(
                    imagePath: imagePath,
                    title: label,
                  ),
                ),
              );
            },
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: CustomText(
              text: 'Tap to view full size',
              size: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kWhiteTextColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Company Profile",
          size: 18,
          color: ThemeColors.kWhiteTextColor,
        ),
        actions: [
          // Only show the edit button if profile data exists
          if (profileData.isNotEmpty)
            IconButton(
              icon: Icon(Icons.edit, color: ThemeColors.kWhiteTextColor),
              onPressed: () {
                // Navigate to the new EditProfileScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      // Pass the current data to the edit screen
                      profileData: profileData,
                    ),
                  ),
                ).then((_) {
                  // Reload data after returning from edit screen
                  _loadProfileData();
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        text: "No profile data found",
                        size: 18,
                        weight: FontWeight.w500,
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        onTap: () {
                          // Navigate to form in create mode
                        },
                        text: "Create Profile",
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Logo
                        Center(
                          child: Column(
                            children: [
                              _buildLogoWidget(),
                              const SizedBox(height: 10),
                              const CustomText(
                                text: "Company Logo",
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // GST Information or Aadhaar Information
                        if (profileData['gst_status'] == 'registered') ...[
                          _buildSectionTitle("GST Information"),
                          _buildInfoItem(
                              "GST Status",
                              profileData['gst_status'] == 'registered'
                                  ? "Registered"
                                  : "Unregistered"),
                          _buildInfoItem(
                              "GST Number", profileData['gst_number']),
                          _buildInfoItem(
                              "Legal Name", profileData['gst_legal_name']),
                          _buildInfoItem(
                              "Trade Name", profileData['gst_trade_name']),
                          _buildInfoItem("Address", profileData['gst_address']),
                          _buildInfoItem(
                              "Company Type", profileData['gst_company_type']),
                          _buildInfoItem(
                              "GST Status", profileData['gst_status_text']),
                          const SizedBox(height: 8),
                          // NEW: Display GST Certificate
                          _buildDocumentDisplay("GST Certificate",
                              profileData['gst_certificate']),
                        ] else ...[
                          _buildSectionTitle("Aadhaar Information"),
                          _buildInfoItem(
                              "Aadhaar Number", profileData['aadhaar_number']),
                          _buildInfoItem("Name", profileData['aadhaar_name']),
                          _buildInfoItem(
                              "Date of Birth", profileData['aadhaar_dob']),
                          _buildInfoItem(
                              "Address", profileData['aadhaar_address']),
                          const SizedBox(height: 8),
                          // NEW: Display Aadhaar Card (could be image or PDF)
                          if (profileData['aadhaar_card'] != null &&
                              profileData['aadhaar_card']
                                  .toString()
                                  .toLowerCase()
                                  .endsWith('.pdf'))
                            _buildDocumentDisplay(
                                "Aadhaar Card", profileData['aadhaar_card'])
                          else
                            _buildImageDisplay(
                                "Aadhaar Card", profileData['aadhaar_card']),
                        ],

                        // Catering Information
                        _buildSectionTitle("Service Area"),
                        _buildInfoItem(
                            "Catering To",
                            profileData['catering_option'] == '1'
                                ? "Pan India"
                                : "Domestic" +
                                    " (${profileData['catering_radius']} km)"),

                        // Certification
                        if (profileData['iso_certified'] == true) ...[
                          _buildSectionTitle("Certifications"),
                          _buildInfoItem(
                              "ISO Certified", profileData['iso_number']),
                        ],

                        // E-Way Bill
                        if (profileData['gst_status'] == 'registered') ...[
                          _buildSectionTitle("E-Way Bill Information"),
                          _buildInfoItem(
                              "E-Way Bill ID", profileData['eway_bill_id']),
                          _buildInfoItem("E-Way Bill Password", "********"),
                        ],

                        _buildSectionTitle("Scope of Work"),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (profileData['scope_of_work']?['sale'] == true)
                                _buildScopeChip("Sale"),
                              if (profileData['scope_of_work']?['rental'] ==
                                  true)
                                _buildScopeChip("Rental"),
                              if (profileData['scope_of_work']?['contractor'] ==
                                  true)
                                _buildScopeChip("Contractor"),
                              if (profileData['scope_of_work']?['service'] ==
                                  true)
                                _buildScopeChip("Service"),
                            ],
                          ),
                        ),

                        // Signature
                        if (profileData['signature_path'] != null &&
                            File(profileData['signature_path'])
                                .existsSync()) ...[
                          _buildSectionTitle("Signature"),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.file(
                                    File(profileData['signature_path']),
                                    height: 100,
                                    width: 200,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildScopeChip(String label) {
    return Chip(
      backgroundColor: ThemeColors.kPrimaryThemeColor.withOpacity(0.1),
      label: CustomText(
        text: label,
        color: ThemeColors.kPrimaryThemeColor,
        weight: FontWeight.w500,
      ),
      avatar: Icon(
        Icons.check_circle,
        size: 18,
        color: ThemeColors.kPrimaryThemeColor,
      ),
    );
  }
}

// Full Screen Image Viewer
class _FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const _FullScreenImageViewer({
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: CustomText(
          text: title,
          size: 18,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              final result = await OpenFile.open(imagePath);
              if (result.type != ResultType.done) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open file: ${result.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
