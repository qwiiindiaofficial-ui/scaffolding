// lib/screens/Bills.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:scaffolding_sale/screens/home/Union/union.dart';
import 'package:scaffolding_sale/screens/home/rental/tab.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// lib/billing/bill_service.dart
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Bill ke andar jo items hain unka model
class BillLineItem {
  final String itemName;
  final int quantity;
  final double rate;
  final double amount;

  BillLineItem(
      {required this.itemName,
      required this.quantity,
      required this.rate,
      required this.amount});

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'quantity': quantity,
        'rate': rate,
        'amount': amount
      };

  factory BillLineItem.fromJson(Map<String, dynamic> json) => BillLineItem(
      itemName: json['itemName'],
      quantity: json['quantity'],
      rate: json['rate'],
      amount: json['amount']);
}

// Bill/Invoice ka main model
enum BillType { Performa, FinalBill }

class Bill {
  final String id;
  String invoiceNumber;
  DateTime createDate;
  DateTime fromDate;
  DateTime toDate;
  final BillType type;
  final List<BillLineItem> items;
  double totalAmount;

  Bill({
    required this.id,
    required this.invoiceNumber,
    required this.createDate,
    required this.fromDate,
    required this.toDate,
    required this.type,
    required this.items,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'createDate': createDate.toIso8601String(),
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
        'type': type.index,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
      };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'],
        invoiceNumber: json['invoiceNumber'],
        createDate: DateTime.parse(json['createDate']),
        fromDate: DateTime.parse(json['fromDate']),
        toDate: DateTime.parse(json['toDate']),
        type: BillType.values[json['type']],
        items: List<BillLineItem>.from(
            json['items'].map((item) => BillLineItem.fromJson(item))),
        totalAmount: json['totalAmount'],
      );
}

// Bills ko SharedPreferences mein manage karne wali service
class BillService {
  static const _billsKey = 'user_bills';

  static Future<List<Bill>> getBills() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_billsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Bill.fromJson(json)).toList();
  }

  static Future<void> _saveBills(List<Bill> bills) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _billsKey, jsonEncode(bills.map((b) => b.toJson()).toList()));
  }

  static Future<void> addBill(Bill newBill) async {
    final bills = await getBills();
    bills.add(newBill);
    await _saveBills(bills);
  }

  static Future<void> updateBill(Bill updatedBill) async {
    final bills = await getBills();
    final index = bills.indexWhere((b) => b.id == updatedBill.id);
    if (index != -1) {
      bills[index] = updatedBill;
      await _saveBills(bills);
    }
  }

  static Future<void> deleteBill(String billId) async {
    final bills = await getBills();
    bills.removeWhere((b) => b.id == billId);
    await _saveBills(bills);
  }
}

// lib/billing/bill_service.dart

// ... (Pichhla saara code Bill, BillLineItem, BillService, etc. waise ka waisa rahega)
// Hum bas neeche naye Models aur Services add kar rahe hain.

// ... (Pichhle code ko yahaan paste karein) ...

// Lost/Repair Item ka type (Enum)
enum LostItemType { Short, Repair }

// Ek single lost/repair entry ka model
class LostItemEntry {
  final String stockItemId;
  final String stockItemName;
  final LostItemType type;
  final int quantity;
  final double rate;
  final double totalAmount;

  LostItemEntry({
    required this.stockItemId,
    required this.stockItemName,
    required this.type,
    required this.quantity,
    required this.rate,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() => {
        'stockItemId': stockItemId,
        'stockItemName': stockItemName,
        'type': type.index,
        'quantity': quantity,
        'rate': rate,
        'totalAmount': totalAmount,
      };

  factory LostItemEntry.fromJson(Map<String, dynamic> json) => LostItemEntry(
        stockItemId: json['stockItemId'],
        stockItemName: json['stockItemName'],
        type: LostItemType.values[json['type']],
        quantity: json['quantity'],
        rate: json['rate'],
        totalAmount: json['totalAmount'],
      );
}

// Poore challan ka model jo entries ko group karega
class LostItemsChallan {
  final String id;
  final String originalChallanNo;
  final DateTime date;
  final List<LostItemEntry> entries;

  LostItemsChallan({
    required this.id,
    required this.originalChallanNo,
    required this.date,
    required this.entries,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalChallanNo': originalChallanNo,
        'date': date.toIso8601String(),
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory LostItemsChallan.fromJson(Map<String, dynamic> json) =>
      LostItemsChallan(
        id: json['id'],
        originalChallanNo: json['originalChallanNo'],
        date: DateTime.parse(json['date']),
        entries: List<LostItemEntry>.from(
            json['entries'].map((e) => LostItemEntry.fromJson(e))),
      );
}

// Lost Items ko manage karne wali service
class LostItemService {
  static const _key = 'lost_items_challans';

  static Future<void> saveLostItemsChallan(LostItemsChallan challan) async {
    final challans = await getLostItemsChallans();
    challans.add(challan);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(challans.map((c) => c.toJson()).toList()));
  }

  static Future<List<LostItemsChallan>> getLostItemsChallans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => LostItemsChallan.fromJson(json)).toList();
  }
}

// STOCK SERVICE KI FILE BHI IMPORT KARNI HOGI IS FILE MEIN
// import 'package:scaffolding_sale/services/stock_service.dart';

class Bills extends StatefulWidget {
  const Bills({super.key});

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> with TickerProviderStateMixin {
  late TabController controller;
  List<Bill> _allBills = [];
  List<Bill> _performaInvoices = [];
  List<Bill> _finalBills = [];
  bool _isLoading = false;
  String _loadingText = "";

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() => setState(() {}));
    _loadBills();
  }

  Future<void> _loadBills() async {
    final bills = await BillService.getBills();
    setState(() {
      _allBills = bills;
      _performaInvoices =
          bills.where((b) => b.type == BillType.Performa).toList();
      _finalBills = bills.where((b) => b.type == BillType.FinalBill).toList();
    });
  }

  void _showCreateBillSheet({Bill? existingBill}) {
    final isEditing = existingBill != null;
    final invoiceController = TextEditingController(
        text: isEditing ? existingBill.invoiceNumber : '');
    DateTime createDate = isEditing ? existingBill.createDate : DateTime.now();
    DateTime fromDate = isEditing ? existingBill.fromDate : DateTime.now();
    DateTime toDate = isEditing
        ? existingBill.toDate
        : DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditing ? "Edit Bill" : "Create Bill",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                  controller: invoiceController,
                  decoration: const InputDecoration(
                      labelText: "Invoice No.", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                    "Create Date: ${DateFormat.yMMMd().format(createDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: createDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (picked != null) setModalState(() => createDate = picked);
                },
              ),
              ListTile(
                title:
                    Text("From Date: ${DateFormat.yMMMd().format(fromDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: fromDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (picked != null) setModalState(() => fromDate = picked);
                },
              ),
              ListTile(
                title: Text("To Date: ${DateFormat.yMMMd().format(toDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: toDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (picked != null) setModalState(() => toDate = picked);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                  onTap: () => _handleSaveBill(
                      isEditing: isEditing,
                      billId: existingBill?.id,
                      invoiceNumber: invoiceController.text,
                      createDate: createDate,
                      fromDate: fromDate,
                      toDate: toDate,
                      billType: controller.index == 0
                          ? BillType.Performa
                          : BillType.FinalBill),
                  text: "Save"),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _handleSaveBill(
      {required bool isEditing,
      String? billId,
      required String invoiceNumber,
      required DateTime createDate,
      required DateTime fromDate,
      required DateTime toDate,
      required BillType billType}) async {
    Navigator.pop(context); // Close bottom sheet
    setState(() {
      _isLoading = true;
      _loadingText = "Fetching items till date...";
    });

    await Future.delayed(const Duration(seconds: 3)); // Fake loader

    // Fake items as requested
    final items = [
      BillLineItem(
          itemName: 'Standar 1 mtr', quantity: 20, rate: 10, amount: 200),
      BillLineItem(
          itemName: 'Standar 2.0 mtr', quantity: 15, rate: 15, amount: 225),
    ];
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.amount);

    if (isEditing) {
      final updatedBill = Bill(
          id: billId!,
          invoiceNumber: invoiceNumber,
          createDate: createDate,
          fromDate: fromDate,
          toDate: toDate,
          type: billType,
          items: items,
          totalAmount: totalAmount);
      await BillService.updateBill(updatedBill);
    } else {
      final newBill = Bill(
          id: const Uuid().v4(),
          invoiceNumber: invoiceNumber,
          createDate: createDate,
          fromDate: fromDate,
          toDate: toDate,
          type: billType,
          items: items,
          totalAmount: totalAmount);
      await BillService.addBill(newBill);
    }

    await _loadBills();
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Bill ${isEditing ? 'updated' : 'created'} successfully!')));
  }

  Future<void> _showDeleteConfirmation(String billId) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to delete this bill? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await BillService.deleteBill(billId);
      await _loadBills();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Bill deleted.')));
    }
  }

  Future<void> _viewPdf(Bill bill) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        build: (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      bill.type == BillType.Performa
                          ? 'Performa Invoice'
                          : 'Final Bill',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Invoice #: ${bill.invoiceNumber}'),
                  pw.Text(
                      'Date: ${DateFormat.yMMMd().format(bill.createDate)}'),
                  pw.Text(
                      'Period: ${DateFormat.yMMMd().format(bill.fromDate)} to ${DateFormat.yMMMd().format(bill.toDate)}'),
                  pw.Divider(height: 30),
                  pw.Table.fromTextArray(
                    headers: ['Item Description', 'Qty', 'Rate', 'Amount'],
                    data: bill.items
                        .map((item) => [
                              item.itemName,
                              item.quantity.toString(),
                              '₹${item.rate.toStringAsFixed(2)}',
                              '₹${item.amount.toStringAsFixed(2)}',
                            ])
                        .toList(),
                  ),
                  pw.Divider(height: 30),
                  pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                          'Total Amount: ₹${9800.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)))
                ])));
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

// State Variables to hold the entire list (assuming it's available globally or passed in)
// Note: Replace ledgerEntries with your actual data source if it's not a state variable.
// List<Map<String, dynamic>> ledgerEntries = [...];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  // यह नया फ़ंक्शन आपके स्टेटफ़ुल विजेट क्लास में होना चाहिए
  Future<void> _generatePdfWithDateRange(
      BuildContext context, List<Map<String, dynamic>> allLedgerEntries) async {
    // 1. Show Date Range Picker
    final picked = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      // सुनिश्चित करें कि आप 'flutter' से 'showDateRangePicker' को इंपोर्ट करें
    );

    if (picked != null) {
      // 2. Prepare Period Text for PDF Header
      final periodText =
          '${DateFormat('dd-MMM-yy').format(picked.start)} to ${DateFormat('dd-MMM-yy').format(picked.end)}';

      // 3. Generate PDF with the FULL data list, but using the selected period text.
      // फ़िल्टरिंग लॉजिक को यहाँ स्किप कर दिया गया है।
      await _viewLedgerPdf(
        allLedgerEntries,
      );
    }
    // अगर यूज़र डेट पिकर को कैंसिल कर देता है, तो कुछ नहीं होगा
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //... (Your AppBar code is fine, no changes needed)
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(text: "Bills", color: ThemeColors.kWhiteTextColor),
        actions: [
          ElevatedButton.icon(
              onPressed: () =>
                  _generatePdfWithDateRange(context, ledgerEntries),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View PDF")),
          if (controller.index !=
              2) // Show Create Bill button for first two tabs
            InkWell(
              onTap: _showCreateBillSheet,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: ThemeColors.kSecondaryThemeColor,
                    borderRadius: BorderRadius.circular(8)),
                child: const Center(
                    child:
                        CustomText(text: "Create Bill", color: Colors.white)),
              ),
            ),
          const SizedBox(width: 20),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  TabBar(
                    controller: controller,
                    labelPadding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                        color: ThemeColors.kSecondaryThemeColor,
                        borderRadius: BorderRadius.circular(12)),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      TabItem(text: "Performa Invoice"),
                      TabItem(text: "Bills"),
                      TabItem(text: "Ledger"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: controller,
                      children: [
                        _buildBillList(_performaInvoices),
                        _buildBillList(_finalBills),
                        _buildLedgerView(), // Ledger View
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(_loadingText, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillList(List<Bill> bills) {
    if (bills.isEmpty) {
      return const Center(
          child: Text(
              'This list is empty, please use "Create Bill" button to add.'));
    }
    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return InkWell(
          onTap: () async {
            final bytes = await rootBundle.load('images/pdf.pdf');
            final list = bytes.buffer.asUint8List();

            // Get temp directory
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/temp.pdf');

            // Write to temp file
            await tempFile.writeAsBytes(list);

            // Open the file
            await OpenFile.open(tempFile.path);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: ListTile(
              title: Text("Invoice No: 02",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
                  Text("Date: ${DateFormat.yMMMd().format(bill.createDate)}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("₹178180",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view') _viewPdf(bill);
                      if (value == 'edit')
                        _showCreateBillSheet(existingBill: bill);
                      if (value == 'delete') _showDeleteConfirmation(bill.id);
                      if (value == 'credit')
                        _showCreditNoteSheet(bill); // 👈 new handler
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'view', child: Text("View/PDF")),
                      const PopupMenuItem(value: 'edit', child: Text("Edit")),
                      const PopupMenuItem(
                          value: 'delete', child: Text("Delete")),
                      const PopupMenuItem(
                          value: 'credit',
                          child: Text("Add Credit Note")), // 👈 new menu option
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreditNoteSheet(Bill bill) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController debitNoteNumberController =
        TextEditingController();
    DateTime? debitNoteDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Credit Note",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Debit Note Number
                    TextField(
                      controller: debitNoteNumberController,
                      decoration: const InputDecoration(
                        labelText: "Debit Note Number",
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Debit Note Date
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            debitNoteDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Debit Note Date",
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          debitNoteDate != null
                              ? "${debitNoteDate!.day}/${debitNoteDate!.month}/${debitNoteDate!.year}"
                              : "Select Date",
                          style: TextStyle(
                            color: debitNoteDate != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Amount Input
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Credit Amount",
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reason Input
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Reason",
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Note Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Note: Please ensure the entered amount is inclusive of applicable GST. ",
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: ThemeColors.kPrimaryThemeColor,
                        ),
                      ),
                    ),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final debitNoteNumber =
                              debitNoteNumberController.text;
                          final creditAmount =
                              double.tryParse(amountController.text) ?? 0.0;
                          final reason = reasonController.text;

                          if (debitNoteNumber.isNotEmpty &&
                              debitNoteDate != null &&
                              creditAmount > 0 &&
                              reason.isNotEmpty) {
                            // 👇 yahan tum apna save logic likho (API/database call)
                            print(
                                "Credit Note Added: Invoice ${bill.invoiceNumber}, Debit Note No: $debitNoteNumber, Date: $debitNoteDate, Amount: ₹$creditAmount, Reason: $reason");

                            Navigator.pop(context); // close sheet
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Enter all required details")),
                            );
                          }
                        },
                        child: const Text("Save Credit Note"),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _viewLedgerPdf(List<Map<String, dynamic>> ledgerEntries) async {
    final pdf = pw.Document();

    // Define Party Details
    const myCompanyName = 'Pal Scaffolding';
    const myCompanyAddress =
        'Khasra no 14/1, Rani Laxmi Bai Nagar, Plot No 23, Biharipur Village, Dundahera, Ghaziabad, Uttar Pradesh 201009';
    const customerName = 'Elatio By Gards LLP';
    const customerAddress =
        'B 240 3RD FLOOR B NOIDA SECTOR 50 NOIDA, Uttar Pradesh, India - 201301';

    // --- 💥 NEW: Calculate Totals and Date Range 💥 ---
    double totalInvoices = 0;
    double totalCredits = 0;
    double totalPayments = 0;
    double netOutstanding = 0;

    // Assuming 'Date' key is a String that can be parsed
    DateTime? startDate = DateTime.now();
    DateTime? endDate = DateTime.now();

    for (var entry in ledgerEntries) {
      // Total Calculation
      if (entry["type"] == "Invoice") {
        totalInvoices += entry["amount"];
        netOutstanding += entry["amount"];
      } else if (entry["type"] == "Credit Note") {
        totalCredits += entry["amount"];
        netOutstanding -= entry["amount"];
      } else if (entry["type"] == "Payment Added") {
        totalPayments += entry["amount"];
        netOutstanding -= entry["amount"];
      }

      // Date Range Calculation
      if (entry["Date"] is String) {
        try {
          final entryDate = DateFormat('dd-MM-yyyy').parse(entry["Date"]);
          if (startDate == null || entryDate.isBefore(startDate)) {
            startDate = entryDate;
          }
          if (endDate == null || entryDate.isAfter(endDate)) {
            endDate = entryDate;
          }
        } catch (e) {
          // Handle date parsing error if necessary
        }
      }
    }

    final totalCreditAmount = totalCredits + totalPayments;

    // Format the date range string
    final periodText = (startDate != null && endDate != null)
        ? '${DateFormat('dd-MMM-yy').format(startDate)} to ${DateFormat('dd-MMM-yy').format(endDate)}'
        : 'All Transactions';
    // ----------------------------------------------------

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(12),
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- 💥 OPTIMIZED Header & Time Period 💥 ---
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'LEDGER ACCOUNT',
                      style: pw.TextStyle(
                        fontSize: 18, // Reduced size
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.Text(
                      'Report Date: ${DateFormat('dd-MMM-yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10, // Reduced size
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Period: $periodText', // Show calculated period
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Divider(thickness: 1.5, color: PdfColors.blue900), // Separator
            pw.SizedBox(height: 10), // Reduced space
            // ---------------------------------------------------

            // Party Details in Boxes
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // From Company
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6), // Reduced padding
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      borderRadius:
                          pw.BorderRadius.circular(3), // Reduced radius
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'From:',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2), // Reduced space
                        pw.Text(
                          myCompanyName,
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold), // Reduced size
                        ),
                        pw.Text(
                          myCompanyAddress,
                          style:
                              const pw.TextStyle(fontSize: 8), // Reduced size
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10), // Reduced space
                // To Customer
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6), // Reduced padding
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.grey400, width: 0.5),
                      borderRadius:
                          pw.BorderRadius.circular(3), // Reduced radius
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'To:',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2), // Reduced space
                        pw.Text(
                          customerName,
                          style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold), // Reduced size
                        ),
                        pw.Text(
                          customerAddress,
                          style:
                              const pw.TextStyle(fontSize: 8), // Reduced size
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10), // Reduced space

            // Table Header
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                border: pw.Border.all(color: PdfColors.grey600),
              ),
              padding: const pw.EdgeInsets.symmetric(
                  vertical: 4, horizontal: 2), // Reduced padding
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Particulars',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Vch Type',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Vch No',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Debit (₹)',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Credit (₹)',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Transaction Rows
            ...ledgerEntries.asMap().entries.map((mapEntry) {
              final entry = mapEntry.value;
              final amount = entry["amount"] as double;
              final date = entry["Date"] ?? "";
              final isInvoice = entry["type"] == "Invoice";
              final isPayment = entry["type"] == "Payment Added";

              String debitAmount = "";
              String creditAmount = "";

              if (isInvoice) {
                debitAmount = amount.toStringAsFixed(2);
              } else {
                creditAmount = amount.toStringAsFixed(2);
              }

              return pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                    right: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                    bottom: pw.BorderSide(width: 0.3, color: PdfColors.grey300),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(
                    vertical: 3, horizontal: 2), // Reduced padding
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Date Column
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        date.trim(),
                        style: const pw.TextStyle(fontSize: 8), // Reduced size
                      ),
                    ),
                    // Particulars Column
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Particulars Line 1: 'By' or 'To'
                          pw.Text(
                            isInvoice ? "By" : "To",
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold), // Reduced size
                          ),
                          // Particulars Line 2: Party Name
                          pw.Text(
                            entry["party"],
                            style:
                                const pw.TextStyle(fontSize: 8), // Reduced size
                          ),
                        ],
                      ),
                    ),
                    // Vch Type Column
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        isInvoice
                            ? "Invoice"
                            : isPayment
                                ? "Payment"
                                : "C/N", // C/N for Credit Note
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 8), // Reduced size
                      ),
                    ),
                    // Vch No Column
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        (mapEntry.key + 1).toString(),
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 8), // Reduced size
                      ),
                    ),
                    // Debit Column
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        debitAmount.isEmpty ? "" : debitAmount,
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 8), // Reduced size
                      ),
                    ),
                    // Credit Column
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        creditAmount.isEmpty ? "" : creditAmount,
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(fontSize: 8), // Reduced size
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // --- Grand Total Row ---
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey100,
                border: pw.Border(
                  top: pw.BorderSide(width: 1.5, color: PdfColors.blueGrey800),
                  left: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                  right: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                  bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(
                  vertical: 4, horizontal: 2), // Reduced padding
              child: pw.Row(
                children: [
                  // 'Total' Label
                  pw.Expanded(
                    flex:
                        10, // Takes up space of Date, Particulars, Vch Type, Vch No
                    child: pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),

                  // Total Debit Column
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      totalInvoices.toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  // Total Credit Column
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      totalCreditAmount.toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Closing Balance Row
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.amber100,
                border: pw.Border(
                  left: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                  right: pw.BorderSide(width: 0.5, color: PdfColors.grey400),
                  bottom:
                      pw.BorderSide(width: 1.5, color: PdfColors.blueGrey800),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(
                  vertical: 4, horizontal: 2), // Reduced padding
              child: pw.Row(
                children: [
                  // 'Closing Balance' Label
                  pw.Expanded(
                    flex: 10,
                    child: pw.Text(
                      'CLOSING BALANCE (Net Outstanding):',
                      style: pw.TextStyle(
                        fontSize: 10, // Slightly larger for emphasis
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),

                  // Debit (Balance) Side
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      netOutstanding >= 0
                          ? netOutstanding.abs().toStringAsFixed(2)
                          : '',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  // Credit (Advance) Side
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      netOutstanding < 0
                          ? netOutstanding.abs().toStringAsFixed(2)
                          : '',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            pw.Spacer(),

            // Footer (Unchanged)
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(top: 10), // Reduced space
              child: pw.Text(
                'This is a computer-generated statement and does not require a signature.',
                style: const pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey600), // Reduced size
              ),
            ),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
        '${dir.path}/Ledger_Statement_${DateTime.now().microsecondsSinceEpoch}.pdf');

    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);
  }

// Complete Ledger View Widget
  Widget _buildLedgerView() {
    // Mock ledger data

    double total = 0;

    // Calculate running total with logic
    for (var entry in ledgerEntries) {
      if (entry["type"] == "Invoice") {
        total += entry["amount"]; // Invoice increases balance
      } else if (entry["type"] == "Credit Note") {
        total -= entry["amount"]; // Credit note reduces balance
      } else if (entry["type"] == "Payment Added") {
        total -= entry["amount"]; // Payment reduces balance
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Unionpage();
                  }));
                },
                icon: const Icon(Icons.filter_alt),
                label: const Text("Defaulter")),
            ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Reminder sent to all parties.')));
                },
                icon: const Icon(Icons.send),
                label: const Text("Reminder")),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: ledgerEntries.length,
            itemBuilder: (context, index) {
              final entry = ledgerEntries[index];
              final amount = entry["amount"] as double;

              Color color;
              if (entry["type"] == "Credit Note") {
                color = Colors.red; // credit note reduces balance
              } else if (entry["type"] == "Invoice") {
                color = Colors.amber.shade800; // invoice
              } else {
                color = Colors.green; // payment reduces balance
              }

              return ListTile(
                title: Row(
                  children: [
                    Text(entry["party"]),
                    Text(
                      entry["Date"] == null ? "" : (entry["Date"]),
                      style: TextStyle(color: ThemeColors.kSecondaryThemeColor),
                    ),
                  ],
                ),
                subtitle: Text(entry["type"] == "Invoice"
                    ? "2 Oct 2025 -  6 Oct 2025"
                    : entry["type"]),
                trailing: Text(
                  "₹${amount.toStringAsFixed(2)}",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),

        // Detailed Summary at bottom
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Calculate individual totals
              Builder(builder: (context) {
                double totalInvoices = 0;
                double totalCredits = 0;
                double totalPayments = 0;

                for (var entry in ledgerEntries) {
                  if (entry["type"] == "Invoice") {
                    totalInvoices += entry["amount"];
                  } else if (entry["type"] == "Credit Note") {
                    totalCredits += entry["amount"];
                  } else if (entry["type"] == "Payment Added") {
                    totalPayments += entry["amount"];
                  }
                }

                return Column(
                  children: [
                    // Invoice Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Invoices (Debit):",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "+ ₹${totalInvoices.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Credit Notes Total
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     const Text(
                    //       "Total Credit Notes:",
                    //       style: TextStyle(fontSize: 14),
                    //     ),
                    //     Text(
                    //       "- ₹${totalCredits.toStringAsFixed(2)}",
                    //       style: const TextStyle(
                    //         fontSize: 14,
                    //         color: Colors.red,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 8),

                    // Payments Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Payments Received:",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "- ₹${totalPayments.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 2),

                    // Net Outstanding
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Net Outstanding:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: total > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),

                    // Calculation breakdown
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> ledgerEntries = [
  {
    "party": "CN No: 01,",
    "type": "Credit Note",
    "amount": 100.0,
    "Date": " 05-OCT-2025"
  },
  {
    "party": "CN No: 02, ",
    "type": "Credit Note",
    "amount": 100.0,
    "Date": " 05-OCT-2025"
  },
  {
    "party": "Invoice: 01",
    "type": "Invoice",
    "amount": 425.0,
    "Date": " 05-OCT-2025"
  },
  {
    "party": "PS No: 01",
    "type": "Payment Added",
    "amount": 10000.0,
    "Date": " 05-OCT-2025"
  },
  {
    "party": "PS No: 02,",
    "type": "Payment Added",
    "amount": 1000.0,
    "Date": " 05-OCT-2025"
  },
];
