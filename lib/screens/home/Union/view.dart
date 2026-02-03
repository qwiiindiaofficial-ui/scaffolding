import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/home/Union/edit.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewDetails extends StatefulWidget {
  final String partyId;

  const ViewDetails({super.key, required this.partyId});

  @override
  State<ViewDetails> createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  Map<String, dynamic> partyData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPartyDetails();
  }

  Future<void> _loadPartyDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? partiesJsonList = prefs.getStringList('parties_list');

      if (partiesJsonList != null) {
        for (String partyJson in partiesJsonList) {
          final Map<String, dynamic> party = jsonDecode(partyJson);
          if (party['id'] == widget.partyId) {
            setState(() {
              partyData = party;
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error loading party details: $e');
      Fluttertoast.showToast(msg: "Error loading customer details");
    } finally {
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
          Row(
            children: [
              Expanded(
                child: CustomText(
                  text: value ?? 'Not provided',
                  size: 16,
                  weight: FontWeight.w500,
                ),
              ),
              // const Spacer(),
              label == "Designation"
                  ? const Row(
                      children: [
                        CustomText(
                          text: "",
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Icon(Icons.phone)
                      ],
                    )
                  : Container()
            ],
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

  Widget _buildImageViewer(String imagePath, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        CustomText(
          text: title,
          size: 14,
          color: Colors.grey.shade700,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(File(imagePath)),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getPartyName() {
    if (partyData['register_type'] == '1') {
      return partyData['gst_trade_name'] ??
          partyData['gst_legal_name'] ??
          'GST Party';
    } else if (partyData['register_type'] == '2') {
      return partyData['aadhaar_name'] ?? partyData['name'] ?? 'Aadhaar Party';
    } else {
      return partyData['name'] ?? 'User Party';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Customer Details",
          size: 18,
          color: ThemeColors.kWhiteTextColor,
        ),
        actions: [
          if (partyData.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPartyScreen(
                      initialPartyData: partyData,
                    ),
                  ),
                ).then((_) {
                  // After returning from the edit screen, reload the details
                  // to show any changes that were saved.
                  _loadPartyDetails();
                });
              },
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : partyData.isEmpty
              ? const Center(child: Text("Customer not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      if (partyData['profile_image'] != null)
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage:
                                    FileImage(File(partyData['profile_image'])),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                      // Basic Information
                      // _buildSectionTitle("Basic Information"),
                      // _buildInfoItem("Email", partyData['email']),

                      // GST Information (if registered)
                      if (partyData['register_type'] == '1') ...[
                        _buildSectionTitle("GST Information"),
                        _buildInfoItem("GST Number", partyData['gst_number']),
                        _buildInfoItem(
                            "Legal Name", partyData['gst_legal_name']),
                        _buildInfoItem(
                            "Trade Name", partyData['gst_trade_name']),
                        _buildInfoItem("Address", partyData['gst_address']),
                        _buildInfoItem(
                            "Company Type", partyData['gst_company_type']),
                        _buildInfoItem("GST Status", partyData['gst_status']),
                        _buildInfoItem("MSME Number", partyData['msme_number']),
                        if (partyData['gst_certificate'] != null)
                          _buildImageViewer(
                              partyData['gst_certificate'], "GST Certificate"),
                      ],

                      // Aadhaar Information (if unregistered)
                      if (partyData['register_type'] == '2') ...[
                        _buildSectionTitle("Aadhaar Information"),
                        _buildInfoItem(
                            "Aadhaar Number", partyData['aadhar_number']),
                        _buildInfoItem("Name", getPartyName()),

                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                  "Date of Birth", partyData['aadhaar_dob']),
                            ),
                            CustomText(
                              text: "19+ Years",
                              color: ThemeColors.kPrimaryThemeColor,
                              size: 22,
                            ),
                          ],
                        ),
                        if (partyData['aadhaar_address'] != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: "Address (from Aadhaar)",
                                  size: 14,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: CustomText(
                                    text: partyData['aadhaar_address'] ??
                                        'Not provided',
                                    size: 16,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Divider(color: Colors.grey.shade300),
                              ],
                            ),
                          ),
                        ],
                        _buildInfoItem("PAN Number", partyData['pan_number']),

                        // Aadhaar Card Image
                        if (partyData['aadhar_card'] != null)
                          _buildImageViewer(
                              partyData['aadhar_card'], "Aadhaar Card"),

                        // PAN Card Image
                        if (partyData['pan_card'] != null) ...[
                          const SizedBox(height: 16),
                          _buildImageViewer(partyData['pan_card'], "PAN Card"),
                        ],
                      ],

                      // User Information (if existing user)
                      if (partyData['register_type'] == '3') ...[
                        _buildSectionTitle("User Information"),
                        _buildInfoItem(
                            partyData['is_scaffolding_id'] == true
                                ? "Scaffolding ID"
                                : "Mobile Number",
                            partyData['is_scaffolding_id'] == true
                                ? partyData['scaffolding_id']
                                : partyData['mobile_number']),
                      ],

                      // Additional Information for all types
                      if (partyData['designation'] != null) ...[
                        _buildSectionTitle("Additional Information"),
                        _buildInfoItem("Designation", partyData['designation']),
                      ],

                      // Contacts
                      if (partyData['contacts'] != null &&
                          (partyData['contacts'] as List).isNotEmpty) ...[
                        _buildSectionTitle("Contacts"),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (partyData['contacts'] as List).length,
                          itemBuilder: (context, index) {
                            final contact =
                                (partyData['contacts'] as List)[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color:
                                                ThemeColors.kPrimaryThemeColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: CustomText(
                                            text: contact['name'] ?? 'No Name',
                                            size: 16,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: ThemeColors
                                                .kPrimaryThemeColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: CustomText(
                                            text: contact['designation'] ??
                                                'No Designation',
                                            size: 12,
                                            color:
                                                ThemeColors.kPrimaryThemeColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (contact['email'] != null &&
                                        contact['email'].toString().isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.email,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: CustomText(
                                              text: contact['email'],
                                              size: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 4),
                                    if (contact['phones'] != null &&
                                        (contact['phones'] as List).isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (var phone in contact['phones'])
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.phone,
                                                      size: 16,
                                                      color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  CustomText(
                                                    text: phone,
                                                    size: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // Creation Date
                      // Creation Date
                      if (partyData['created_at'] != null) ...[
                        _buildSectionTitle("Record Information"),
                        _buildInfoItem(
                          "Created On",
                          DateFormat('dd MMMM yyyy, hh:mm a')
                              .format(DateTime.parse(partyData['created_at'])),
                        ),
                        _buildInfoItem(
                          "Joined Scaffolding App India",
                          DateFormat('dd MMMM yyyy, hh:mm a')
                              .format(DateTime.parse(partyData['created_at'])),
                        ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}
