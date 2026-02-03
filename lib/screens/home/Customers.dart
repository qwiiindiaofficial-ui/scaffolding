import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/BankDetail.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/Union/view.dart';
import 'package:scaffolding_sale/screens/profile/EditProfile.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:share_plus/share_plus.dart';

import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';

class Coustomers extends StatefulWidget {
  const Coustomers({super.key});

  @override
  State<Coustomers> createState() => _CoustomersState();
}

class _CoustomersState extends State<Coustomers> {
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
      final appController = AppController.to;
      final companyId = appController.companyId;

      if (companyId == null) {
        showError('Company not found');
        return;
      }

      final parties = await appController.partyService.getParties(
        companyId: companyId,
        partyType: 'customer',
      );

      setState(() {
        allCustomers = parties;
        filteredCustomers = parties;
      });
    } catch (e) {
      showError('Error loading customers');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteParty(String partyId) async {
    try {
      showLoadingDialog('Deleting customer...');
      await AppController.to.partyService.deleteParty(partyId);
      closeLoadingDialog();
      showSuccess('Customer deleted successfully');
      await _loadParties();
    } catch (e) {
      closeLoadingDialog();
      showError('Error deleting customer');
    }
  }

  void _showPaymentRequestSheet(String customerName) {
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Send Payment Request to $customerName",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Enter Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final amountText = amountController.text.trim();
                  if (amountText.isEmpty ||
                      double.tryParse(amountText) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter a valid amount")),
                    );
                    return;
                  }
                  Navigator.pop(context); // Close bottom sheet
                  _showQRCodeDialog(customerName, double.parse(amountText));
                },
                child: const Text("OK"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showQRCodeDialog(String customerName, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUpiId = prefs.getString('upiId') ?? '';

    final upiDetails = UPIDetails(
      upiID: savedUpiId, // Use saved UPI ID
      payeeName: customerName,
      amount: amount,
      transactionNote: "Payment request for $customerName",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Payment QR Code for $customerName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UPIPaymentQRCode(
                upiDetails: upiDetails,
                size: 220,
                upiQRErrorCorrectLevel: UPIQRErrorCorrectLevel.low,
              ),
              const SizedBox(height: 12),
              Text("Scan QR to Pay",
                  style:
                      TextStyle(color: Colors.grey[600], letterSpacing: 1.2)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text("Share QR Code"),
                onPressed: () async {
                  await Share.share(
                      'Payment Reminder for $customerName: ₹$amount');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
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
    return party['name'] ?? party['company_name'] ?? 'Unknown';
  }

  String getPartyAddress(Map<String, dynamic> party) {
    return party['billing_address'] ?? party['shipping_address'] ?? 'No address';
  }

  String getPartyIdentifier(Map<String, dynamic> party) {
    if (party['gst_number'] != null && party['gst_number'].toString().isNotEmpty) {
      return 'GST: ${party['gst_number']}';
    } else if (party['mobile'] != null && party['mobile'].toString().isNotEmpty) {
      return 'Mobile: ${party['mobile']}';
    }
    return '';
  }

  Future<bool> _hasBankDetails() async {
    try {
      final appController = AppController.to;
      final companyId = appController.companyId;
      if (companyId == null) return false;

      final bankDetails = await appController.companyService.getBankDetails(companyId);
      return bankDetails != null && bankDetails.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  String getRegistrationTypeLabel(Map<String, dynamic> party) {
    final partyType = party['party_type'] ?? 'customer';
    if (partyType == 'customer') {
      return 'Customer';
    } else if (partyType == 'supplier') {
      return 'Supplier';
    } else {
      return 'Both';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Customers",
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
            child: RegisterField(
              hint: "Search by name, address or ID...",
              controller: _searchController,
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
                            final partyAddress = getPartyAddress(customerData);
                            final partyIdentifier =
                                getPartyIdentifier(customerData);
                            final partyId = customerData['id'] ?? '';
                            final registrationType =
                                getRegistrationTypeLabel(customerData);

                            final partyType = customerData['party_type'] ?? 'customer';
                            IconData statusIcon;
                            Color statusColor;

                            if (partyType == 'supplier') {
                              statusIcon = Icons.business;
                              statusColor = Colors.green;
                            } else if (partyType == 'customer') {
                              statusIcon = Icons.person;
                              statusColor = Colors.blue;
                            } else {
                              statusIcon = Icons.account_circle;
                              statusColor = Colors.orange;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                        height: 44,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: ThemeColors.kPrimaryThemeColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: InkWell(
                                          onTap: () {},
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
                                                      text: registrationType,
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
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (partyIdentifier.isNotEmpty) ...[
                                            CustomText(
                                              text: partyIdentifier,
                                              color: Colors.black87,
                                              size: 14,
                                              weight: FontWeight.w500,
                                            ),
                                            const SizedBox(height: 4),
                                          ],
                                          CustomText(
                                            text: partyAddress,
                                            color: Colors.black54,
                                            size: 13,
                                            weight: FontWeight.w400,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (customerData['email'] !=
                                                      null &&
                                                  customerData['email']
                                                      .toString()
                                                      .isNotEmpty)
                                                IconButton(
                                                  icon: const Icon(Icons.email,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Email functionality not implemented");
                                                  },
                                                  tooltip: "Send Email",
                                                ),
                                              if (customerData['mobile'] != null)
                                                IconButton(
                                                  icon: const Icon(Icons.phone,
                                                      color: Colors.green),
                                                  onPressed: () {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Call functionality not implemented");
                                                  },
                                                  tooltip: "Call",
                                                ),
                                              PopupMenuButton(
                                                icon: const Icon(
                                                    Icons.more_vert,
                                                    color: Colors.black),
                                                itemBuilder: (context) =>
                                                    const [
                                                  PopupMenuItem(
                                                    value:
                                                        'Send Payment Request',
                                                    child: Text(
                                                        "Send Payment Request",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'View',
                                                    child: Text("View Details",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'Delete',
                                                    child: Text("Delete",
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                                onSelected: (value) async {
                                                  if (value ==
                                                      'Send Payment Request') {
                                                    _hasBankDetails()
                                                        .then((hasDetails) {
                                                      if (hasDetails) {
                                                        _showPaymentRequestSheet(
                                                            partyName);
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Bankdetail()),
                                                        );
                                                      }
                                                    });
                                                  } else if (value == 'Edit') {
                                                    // Navigate to edit screen
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Edit functionality not implemented");
                                                  } else if (value == 'View') {
                                                    // Navigate to view details screen
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewDetails(
                                                                partyId:
                                                                    partyId),
                                                      ),
                                                    );
                                                  } else if (value ==
                                                      'Delete') {
                                                    final confirm =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            "Delete Customer"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this customer?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    false),
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            child: const Text(
                                                                "Delete",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true) {
                                                      await _deleteParty(
                                                          partyId);
                                                    }
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
