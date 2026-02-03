import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Bill Class with GST Details
class Bill {
  final String billNumber;
  final double billValue;
  final String billDate;
  final String billProvider;
  final String billType;
  final double cgst;
  final double sgst;
  final double igst;
  final double taxableAmount;

  Bill({
    required this.billNumber,
    required this.billValue,
    required this.billDate,
    required this.billProvider,
    required this.billType,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.taxableAmount,
  });

  Map<String, dynamic> toJson() => {
        'billNumber': billNumber,
        'billValue': billValue,
        'billDate': billDate,
        'billProvider': billProvider,
        'billType': billType,
        'cgst': cgst,
        'sgst': sgst,
        'igst': igst,
        'taxableAmount': taxableAmount,
      };
}

// GST Summary Class
class GSTSummary {
  double totalCGST = 0;
  double totalSGST = 0;
  double totalIGST = 0;
  double totalTaxableAmount = 0;
  double totalBillValue = 0;

  void addBill(Bill bill) {
    totalCGST += bill.cgst;
    totalSGST += bill.sgst;
    totalIGST += bill.igst;
    totalTaxableAmount += bill.taxableAmount;
    totalBillValue += bill.billValue;
  }
}

// Main Bills Page Widget
class BillsPage extends StatefulWidget {
  @override
  _BillsPageState createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  String _selectedFinancialYear = '2025-26';
  final List<String> _financialYears = [
    '2025-26',
    '2024-25',
    '2023-24',
    '2022-23'
  ];

  String _selectedBillType = 'All';
  final List<String> _billTypes = [
    'All',
    'Sale',
    'Rent',
    'Service',
    'Purchase'
  ];

  final TextEditingController _searchController = TextEditingController();
  final List<Bill> _bills = [];

  // Date Filter Variables
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _generateRandomBills();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Bill> get _filteredBills {
    final searchQuery = _searchController.text.toLowerCase();

    List<Bill> filtered = _bills.where((bill) {
      // Filter by Bill Type
      if (_selectedBillType != 'All' && bill.billType != _selectedBillType) {
        return false;
      }

      // Filter by Search Query
      if (searchQuery.isNotEmpty &&
          !bill.billProvider.toLowerCase().contains(searchQuery)) {
        return false;
      }

      // Filter by Date Range
      if (_startDate != null || _endDate != null) {
        final billDate = DateFormat('dd-MM-yyyy').parse(bill.billDate);
        if (_startDate != null && billDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && billDate.isAfter(_endDate!)) {
          return false;
        }
      }

      return true;
    }).toList();

    return filtered;
  }

  GSTSummary get _gstSummary {
    final summary = GSTSummary();
    for (var bill in _filteredBills) {
      summary.addBill(bill);
    }
    return summary;
  }

  String _getRandomDate() {
    final now = DateTime.now();
    final random = Random();
    final pastDays = random.nextInt(90);
    final randomDate = now.subtract(Duration(days: pastDays));
    return "${randomDate.day.toString().padLeft(2, '0')}-${randomDate.month.toString().padLeft(2, '0')}-${randomDate.year}";
  }

  void _generateRandomBills() {
    _bills.clear();
    final random = Random();
    final providers = [
      "Elatio By Gards LLP",
      "Shree Ram Traders",
      "Ganesh Enterprises",
      "Prakash & Co.",
      "Amit Steels",
      "Sai Cement",
      "Kumar Industries",
      "Rajesh Suppliers",
      "Mohan Trading Co.",
      "Verma & Sons",
      "Patel Enterprises",
      "Singh Traders"
    ];

    final billTypes = ['Sale', 'Rent', 'Service', 'Purchase'];

    for (int i = 0; i < 12; i++) {
      final billNumber = (100 + random.nextInt(900)).toString();
      final taxableAmount = 1000 + random.nextDouble() * 9000;
      final randomProvider = providers[i % providers.length];
      final randomType = billTypes[random.nextInt(billTypes.length)];

      // Generate GST randomly (either CGST+SGST or IGST)
      final isIGST = random.nextBool();
      double cgst = 0, sgst = 0, igst = 0;

      if (isIGST) {
        igst = taxableAmount * 0.18; // 18% IGST
      } else {
        cgst = taxableAmount * 0.09; // 9% CGST
        sgst = taxableAmount * 0.09; // 9% SGST
      }

      final totalValue = taxableAmount + cgst + sgst + igst;

      _bills.add(
        Bill(
          billNumber: billNumber,
          billValue: totalValue,
          taxableAmount: taxableAmount,
          cgst: cgst,
          sgst: sgst,
          igst: igst,
          billProvider: randomProvider,
          billDate: _getRandomDate(),
          billType: randomType,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _shareAsJson() async {
    final jsonData = {
      'financialYear': _selectedFinancialYear,
      'exportDate': DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      'bills': _filteredBills.map((bill) => bill.toJson()).toList(),
      'summary': {
        'totalBills': _filteredBills.length,
        'totalValue': _gstSummary.totalBillValue,
        'totalCGST': _gstSummary.totalCGST,
        'totalSGST': _gstSummary.totalSGST,
        'totalIGST': _gstSummary.totalIGST,
        'totalTaxableAmount': _gstSummary.totalTaxableAmount,
      }
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);

    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/bills_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Bills Data Export',
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _showGSTSummary() {
    final summary = _gstSummary;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GST Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 10),
              _buildSummaryRow('Total Bills', '${_filteredBills.length}'),
              _buildSummaryRow('Taxable Amount',
                  '₹${summary.totalTaxableAmount.toStringAsFixed(2)}'),
              Divider(),
              _buildSummaryRow(
                  'CGST', '₹${summary.totalCGST.toStringAsFixed(2)}',
                  color: Colors.blue),
              _buildSummaryRow(
                  'SGST', '₹${summary.totalSGST.toStringAsFixed(2)}',
                  color: Colors.blue),
              _buildSummaryRow(
                  'IGST', '₹${summary.totalIGST.toStringAsFixed(2)}',
                  color: Colors.orange),
              Divider(),
              _buildSummaryRow(
                'Total Amount',
                '₹${summary.totalBillValue.toStringAsFixed(2)}',
                color: Colors.green,
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "All Bills ($_selectedFinancialYear)",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.assessment, color: Colors.white),
            onPressed: _showGSTSummary,
            tooltip: 'GST Summary',
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareAsJson,
            tooltip: 'Share as JSON',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Year Dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Financial Year:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: _selectedFinancialYear,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.teal, fontSize: 16),
                  underline: Container(
                    height: 2,
                    color: Colors.tealAccent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFinancialYear = newValue!;
                      _generateRandomBills();
                    });
                  },
                  items: _financialYears
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Date Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: Icon(Icons.date_range, size: 20),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}'
                          : 'Select Date Range',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                if (_startDate != null || _endDate != null)
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.red),
                    onPressed: _clearDateFilter,
                    tooltip: 'Clear Filter',
                  ),
              ],
            ),
          ),

          // Bill Type Filter Chips
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _billTypes.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = _billTypes[index];
                final isSelected = _selectedBillType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: Colors.teal.withOpacity(0.2),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.teal.shade800 : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedBillType = type;
                      });
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(height: 8),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by Party Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          // Bills Count & Quick Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredBills.length} Bills',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Total: ₹${_gstSummary.totalBillValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filteredBills.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 64, color: Colors.grey.shade300),
                          SizedBox(height: 16),
                          Text(
                            "No bills found",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredBills.length,
                      itemBuilder: (context, index) {
                        final bill = _filteredBills[index];
                        return BillItem(bill: bill);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillItem extends StatelessWidget {
  final Bill bill;

  BillItem({required this.bill});

  Color _getTypeColor() {
    switch (bill.billType) {
      case 'Sale':
        return Colors.blue.shade700;
      case 'Rent':
        return Colors.orange.shade700;
      case 'Service':
        return Colors.purple.shade700;
      case 'Purchase':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Future<void> _viewPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Tax Invoice',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Bill Type: ${bill.billType}',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Invoice #: ${bill.billNumber}'),
            pw.Text('Provider: ${bill.billProvider}'),
            pw.Text('Date: ${bill.billDate}'),
            pw.Divider(height: 30),
            pw.Table.fromTextArray(
              headers: ['Description', 'Amount'],
              data: [
                ['Taxable Amount', '₹${bill.taxableAmount.toStringAsFixed(2)}'],
                if (bill.cgst > 0)
                  ['CGST (9%)', '₹${bill.cgst.toStringAsFixed(2)}'],
                if (bill.sgst > 0)
                  ['SGST (9%)', '₹${bill.sgst.toStringAsFixed(2)}'],
                if (bill.igst > 0)
                  ['IGST (18%)', '₹${bill.igst.toStringAsFixed(2)}'],
              ],
            ),
            pw.Divider(height: 30),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total Amount: ₹${bill.billValue.toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final fileName =
        "bill_${bill.billNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _viewPdf(context),
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${bill.billType} Inv No. ${bill.billNumber}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: _getTypeColor(),
                    ),
                  ),
                  Text(
                    '₹${bill.billValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bill.billProvider,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    bill.billDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (bill.cgst > 0)
                    Chip(
                      label: Text('CGST: ₹${bill.cgst.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.blue.shade50,
                      padding: EdgeInsets.all(2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (bill.sgst > 0)
                    Chip(
                      label: Text('SGST: ₹${bill.sgst.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.blue.shade50,
                      padding: EdgeInsets.all(2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  if (bill.igst > 0)
                    Chip(
                      label: Text('IGST: ₹${bill.igst.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11)),
                      backgroundColor: Colors.orange.shade50,
                      padding: EdgeInsets.all(2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
