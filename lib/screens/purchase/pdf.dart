import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchasePDFView extends StatefulWidget {
  final Purchase purchase;

  const PurchasePDFView({super.key, required this.purchase});

  @override
  State<PurchasePDFView> createState() => _PurchasePDFViewState();
}

class _PurchasePDFViewState extends State<PurchasePDFView> {
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

  String _getCompanyName() {
    if (profileData['gst_status'] == 'registered') {
      return profileData['gst_trade_name'] ??
          profileData['gst_legal_name'] ??
          'Your Company Name';
    } else {
      return profileData['aadhaar_name'] ?? 'Your Company Name';
    }
  }

  String _getCompanyAddress() {
    if (profileData['gst_status'] == 'registered') {
      return profileData['gst_address'] ?? 'Address Line 1, City, State - PIN';
    } else {
      return profileData['aadhaar_address'] ??
          'Address Line 1, City, State - PIN';
    }
  }

  String _getGSTIN() {
    if (profileData['gst_status'] == 'registered') {
      return 'GSTIN: ${profileData['gst_number'] ?? '07XXXXX1234X1XX'}';
    } else {
      return 'Aadhaar: ${profileData['aadhaar_number'] ?? 'XXXX XXXX XXXX'}';
    }
  }

  Widget _buildLogoWidget() {
    if (profileData['logo_path'] != null &&
        File(profileData['logo_path']).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(profileData['logo_path']),
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Generate logo from company name initials
      String companyName = _getCompanyName();
      List<String> nameParts = companyName.split(' ');
      String initials = nameParts
          .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
          .join();
      if (initials.length > 2) {
        initials = initials.substring(0, 2);
      }

      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSignatureWidget() {
    if (profileData['signature_path'] != null &&
        File(profileData['signature_path']).existsSync()) {
      return Image.file(
        File(profileData['signature_path']),
        height: 60,
        width: 150,
        fit: BoxFit.contain,
      );
    } else {
      return const SizedBox(height: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Invoice - ${widget.purchase.invoiceNo}'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice - ${widget.purchase.invoiceNo}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Logo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogoWidget(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TAX INVOICE',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getCompanyName(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCompanyAddress(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getGSTIN(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 32, thickness: 2),

                // Invoice Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bill To:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.purchase.partyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildDetailRow(
                            'Invoice No:', widget.purchase.invoiceNo),
                        _buildDetailRow(
                            'Purchase No:', widget.purchase.purchaseNo),
                        _buildDetailRow(
                            'Date:',
                            DateFormat('dd/MM/yyyy')
                                .format(widget.purchase.date)),
                        _buildDetailRow('HSN Code:', widget.purchase.hsnCode),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Items Table Header
                Container(
                  color: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text('Item',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text('Size',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 1,
                          child: Text('Qty',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 2,
                          child: Text('Rate',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right)),
                      Expanded(
                          flex: 2,
                          child: Text('Amount',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right)),
                    ],
                  ),
                ),

                // Items Table Body
                ...widget.purchase.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  Item item = entry.value;
                  return Container(
                    color: index.isEven ? Colors.grey[50] : Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(item.name)),
                        Expanded(flex: 2, child: Text(item.size ?? '-')),
                        Expanded(
                            flex: 1,
                            child: Text('${item.quantity}',
                                textAlign: TextAlign.center)),
                        Expanded(
                            flex: 2,
                            child: Text('₹${item.rate.toStringAsFixed(2)}',
                                textAlign: TextAlign.right)),
                        Expanded(
                            flex: 2,
                            child: Text('₹${item.amount.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                      ],
                    ),
                  );
                }),

                const Divider(thickness: 1),

                // Totals
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal', widget.purchase.totalAmount),
                      if (widget.purchase.cgst > 0)
                        _buildTotalRow('CGST (9%)', widget.purchase.cgst,
                            isSmall: true),
                      if (widget.purchase.sgst > 0)
                        _buildTotalRow('SGST (9%)', widget.purchase.sgst,
                            isSmall: true),
                      if (widget.purchase.igst > 0)
                        _buildTotalRow('IGST (18%)', widget.purchase.igst,
                            isSmall: true),
                      const Divider(thickness: 2),
                      _buildTotalRow('Grand Total', widget.purchase.grandTotal,
                          isBold: true, isLarge: true),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[100],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms & Conditions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Payment due within 30 days\n• Goods once sold will not be taken back\n• Subject to Delhi Jurisdiction',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Signature with company name
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSignatureWidget(),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            const Text(
                              'Authorized Signature',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCompanyName(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount,
      {bool isBold = false, bool isLarge = false, bool isSmall = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 2 : 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isLarge ? 16 : (isSmall ? 13 : 14),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 32),
          SizedBox(
            width: 120,
            child: Text(
              '₹${amount.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isLarge ? 18 : (isSmall ? 13 : 14),
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? Colors.teal : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
