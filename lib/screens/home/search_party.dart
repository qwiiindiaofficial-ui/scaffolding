import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/Union/view.dart';
import 'package:scaffolding_sale/screens/profile/EditProfile.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';

class SearchCustomers extends StatefulWidget {
  const SearchCustomers({super.key});

  @override
  State<SearchCustomers> createState() => _SearchCustomersState();
}

class _SearchCustomersState extends State<SearchCustomers> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allCustomers = [];
  List<Map<String, dynamic>> filteredCustomers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? partiesJsonList = prefs.getStringList('parties_list');

      if (partiesJsonList != null && partiesJsonList.isNotEmpty) {
        List<Map<String, dynamic>> loadedParties = [];

        for (String partyJson in partiesJsonList) {
          try {
            final Map<String, dynamic> partyData = jsonDecode(partyJson);
            loadedParties.add(partyData);
          } catch (e) {
            print('Error parsing party data: $e');
          }
        }

        setState(() {
          allCustomers = loadedParties;
          filteredCustomers = loadedParties;
        });
      }
    } catch (e) {
      print('Error loading parties: $e');
      Fluttertoast.showToast(msg: "Error loading customers");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = allCustomers;
      } else {
        filteredCustomers = allCustomers
            .where((customer) =>
                (getPartyName(customer))
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (getPartyAddress(customer))
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (getPartyIdentifier(customer))
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String getPartyName(Map<String, dynamic> party) {
    if (party['register_type'] == '1') {
      if (party['gst_trade_name'] != null &&
          party['gst_trade_name'].toString().isNotEmpty &&
          party['gst_trade_name'].toString() != "NA") {
        return party['gst_trade_name'];
      } else if (party['gst_legal_name'] != null &&
          party['gst_legal_name'].toString().isNotEmpty) {
        return party['gst_legal_name'];
      } else {
        return 'GST Party';
      }
    } else if (party['register_type'] == '2') {
      if (party['aadhaar_name'] != null &&
          party['aadhaar_name'].toString().isNotEmpty) {
        return party['aadhaar_name'];
      } else if (party['name'] != null && party['name'].toString().isNotEmpty) {
        return party['name'];
      } else {
        return 'Aadhaar Party';
      }
    } else if (party['register_type'] == '3') {
      if (party['name'] != null && party['name'].toString().isNotEmpty) {
        return party['name'];
      } else {
        return 'User Party';
      }
    }
    return 'Unknown Party';
  }

  String getPartyAddress(Map<String, dynamic> party) {
    if (party['register_type'] == '1') {
      if (party['gst_address'] != null &&
          party['gst_address'].toString().isNotEmpty) {
        return party['gst_address'];
      } else {
        return 'No address available';
      }
    } else if (party['register_type'] == '2') {
      if (party['aadhaar_address'] != null &&
          party['aadhaar_address'].toString().isNotEmpty) {
        return party['aadhaar_address'];
      } else {
        return 'No address available';
      }
    } else if (party['register_type'] == '3') {
      return 'No address available';
    }
    return 'No address available';
  }

  String getPartyIdentifier(Map<String, dynamic> party) {
    if (party['register_type'] == '1' && party['gst_number'] != null) {
      return 'GST: ${party['gst_number']}';
    } else if (party['register_type'] == '2' &&
        party['aadhar_number'] != null) {
      return 'Aadhaar: ${party['aadhar_number']}';
    } else if (party['register_type'] == '3') {
      if (party['is_scaffolding_id'] == true &&
          party['scaffolding_id'] != null) {
        return 'ID: ${party['scaffolding_id']}';
      } else if (party['mobile_number'] != null) {
        return 'Mobile: ${party['mobile_number']}';
      }
    }
    return '';
  }

  String getRegistrationTypeLabel(Map<String, dynamic> party) {
    if (party['register_type'] == '1') {
      return 'GST Registered';
    } else if (party['register_type'] == '2') {
      return 'Unregistered';
    } else if (party['register_type'] == '3') {
      return 'Existing User';
    }
    return 'Unknown';
  }

  String getPartyPhoneNumber(Map<String, dynamic> party) {
    if (party['mobile_number'] != null) {
      return party['mobile_number'];
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Search Customers",
          color: ThemeColors.kWhiteTextColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfile())).then((_) =>
                  _loadParties()); // Reload parties when returning from add screen
            },
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: ThemeColors.kSecondaryThemeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Center(
                  child: CustomText(
                    text: "New Customer",
                    size: 12,
                    color: ThemeColors.kWhiteTextColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name, address or ID...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: filterCustomers,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCustomers.isEmpty
                    ? const Center(
                        child: Text(
                          "No customers found",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customerData = filteredCustomers[index];
                            final partyName = getPartyName(customerData);
                            final registrationType =
                                getRegistrationTypeLabel(customerData);
                            final partyPhoneNumber =
                                getPartyPhoneNumber(customerData);
                            final partyId = customerData['id'] ?? '';

                            // Determine registration status icon/color
                            IconData statusIcon;
                            Color statusColor;

                            if (customerData['register_type'] == '1') {
                              statusIcon = Icons.business;
                              statusColor = Colors.green;
                            } else if (customerData['register_type'] == '2') {
                              statusIcon = Icons.person;
                              statusColor = Colors.orange;
                            } else {
                              statusIcon = Icons.account_circle;
                              statusColor = Colors.blue;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                height: 44,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ThemeColors.kPrimaryThemeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ViewDetails(partyId: partyId),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          statusIcon,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CustomText(
                                              text: partyName,
                                              size: 16,
                                              color: Colors.white,
                                              weight: FontWeight.w500,
                                            ),
                                            CustomText(
                                              text:
                                                  '$registrationType - $partyPhoneNumber',
                                              size: 12,
                                              color: Colors.white70,
                                              weight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
