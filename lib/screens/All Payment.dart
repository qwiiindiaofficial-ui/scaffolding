import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class AllPayment extends StatefulWidget {
  @override
  _AllPaymentState createState() => _AllPaymentState();
}

class _AllPaymentState extends State<AllPayment>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? dateFrom;
  DateTime? dateTo;
  String selectedStatus = 'All';
  String selectedPaymentMode = 'All';
  String searchQuery = '';
  bool showFilters = false;

  final List<Map<String, dynamic>> allPayments = [
    // --- Existing Data ---
    {
      'title': 'Payment Received from\nTech Solutions Pvt Ltd',
      'companyName': 'Tech Solutions Pvt Ltd',
      'date': '15 Nov 2025',
      'time': '10:30 AM',
      'details':
          'Invoice #INV-2025-001\nDescription: Website Development Services',
      'id': 'CR-001',
      'amount': 50000,
      'type': 'credit',
      'mode': 'Bank Transfer',
      'status': 'Completed'
    },
    {
      'title': 'Payment Made to\nOffice Supplies Co.',
      'companyName': 'Office Supplies Co.',
      'date': '14 Nov 2025',
      'time': '02:15 PM',
      'details':
          'Bill #BILL-2025-045\nDescription: Office Furniture & Equipment',
      'id': 'DB-102',
      'amount': 25000,
      'type': 'debit',
      'mode': 'Cheque',
      'status': 'Completed'
    },
    {
      'title': 'Payment Received from\nGlobal Enterprises',
      'companyName': 'Global Enterprises',
      'date': '13 Nov 2025',
      'time': '11:45 AM',
      'details': 'Invoice #INV-2025-002\nDescription: Consulting Services Q4',
      'id': 'CR-002',
      'amount': 75000,
      'type': 'credit',
      'mode': 'UPI',
      'status': 'Completed'
    },
    // --- New Expenses Dummy Data ---
    {
      'title': 'Office Rent Payment',
      'companyName': 'City Properties',
      'date': '01 Nov 2025',
      'time': '10:00 AM',
      'details': 'Rent #NOV-2025\nDescription: Monthly Office Rent',
      'id': 'EXP-201',
      'amount': 35000,
      'type': 'expense', // Marked as expense
      'mode': 'Bank Transfer',
      'status': 'Completed'
    },
    {
      'title': 'Tea & Snacks Expenses',
      'companyName': 'Sharma Canteen',
      'date': '05 Nov 2025',
      'time': '05:30 PM',
      'details': 'Bill #TEA-NOV-01\nDescription: Staff Refreshments',
      'id': 'EXP-202',
      'amount': 4500,
      'type': 'expense', // Marked as expense
      'mode': 'Cash',
      'status': 'Completed'
    },
    {
      'title': 'Internet Bill',
      'companyName': 'Airtel Broadband',
      'date': '07 Nov 2025',
      'time': '11:20 AM',
      'details': 'Bill #NET-2025-11\nDescription: Fiber Connection 300Mbps',
      'id': 'EXP-203',
      'amount': 1200,
      'type': 'expense', // Marked as expense
      'mode': 'UPI',
      'status': 'Completed'
    },
    // --- More Existing Data ---
    {
      'title': 'Salary Payment to\nEmployees',
      'companyName': 'Employees',
      'date': '12 Nov 2025',
      'time': '09:00 AM',
      'details': 'Payroll #PAY-NOV-2025\nDescription: Monthly Salary November',
      'id': 'DB-103',
      'amount': 120000,
      'type': 'debit',
      'mode': 'Bank Transfer',
      'status': 'Completed'
    },
    {
      'title': 'Payment Received from\nRetail Mart Chain',
      'companyName': 'Retail Mart Chain',
      'date': '11 Nov 2025',
      'time': '03:30 PM',
      'details':
          'Invoice #INV-2025-003\nDescription: Software License Annual Renewal',
      'id': 'CR-003',
      'amount': 90000,
      'type': 'credit',
      'mode': 'NEFT',
      'status': 'Completed'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Increased length to 4 to include Expenses
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (dateFrom ?? DateTime.now())
          : (dateTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          dateFrom = pickedDate;
        } else {
          dateTo = pickedDate;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      dateFrom = null;
      dateTo = null;
      selectedStatus = 'All';
      selectedPaymentMode = 'All';
      searchQuery = '';
    });
  }

  List<Map<String, dynamic>> _getFilteredPayments() {
    List<Map<String, dynamic>> filtered = allPayments;

    // Filter by tab
    if (_tabController.index == 1) {
      // Credit
      filtered = filtered.where((p) => p['type'] == 'credit').toList();
    } else if (_tabController.index == 2) {
      // Debit (Excluding explicit expenses for clarity, or including if you prefer)
      // Here we show only 'debit' type
      filtered = filtered.where((p) => p['type'] == 'debit').toList();
    } else if (_tabController.index == 3) {
      // Expenses (New Tab)
      filtered = filtered.where((p) => p['type'] == 'expense').toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p['companyName']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              p['id'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by status
    if (selectedStatus != 'All') {
      filtered = filtered.where((p) => p['status'] == selectedStatus).toList();
    }

    // Filter by payment mode
    if (selectedPaymentMode != 'All') {
      filtered =
          filtered.where((p) => p['mode'] == selectedPaymentMode).toList();
    }

    // Filter by date range
    if (dateFrom != null || dateTo != null) {
      filtered = filtered.where((p) {
        DateTime paymentDate = DateFormat('dd MMM yyyy').parse(p['date']);
        if (dateFrom != null && paymentDate.isBefore(dateFrom!)) return false;
        if (dateTo != null && paymentDate.isAfter(dateTo!)) return false;
        return true;
      }).toList();
    }

    return filtered;
  }

  Map<String, dynamic> _calculateSummary() {
    List<Map<String, dynamic>> payments = _getFilteredPayments();
    double totalCredit = 0;
    double totalDebit = 0;
    double totalExpenses = 0;

    for (var payment in payments) {
      if (payment['type'] == 'credit') {
        totalCredit += payment['amount'];
      } else if (payment['type'] == 'debit') {
        totalDebit += payment['amount'];
      } else if (payment['type'] == 'expense') {
        totalExpenses += payment['amount'];
      }
    }

    return {
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'totalExpenses': totalExpenses,
      // Balance = Credit - (Debit + Expenses)
      'balance': totalCredit - (totalDebit + totalExpenses),
      'totalTransactions': payments.length,
    };
  }

  Future<void> _downloadAsJson() async {
    try {
      List<Map<String, dynamic>> payments = _getFilteredPayments();
      Map<String, dynamic> summary = _calculateSummary();

      Map<String, dynamic> exportData = {
        'summary': summary,
        'payments': payments,
        'exported_at': DateTime.now().toIso8601String(),
      };

      String jsonString = JsonEncoder.withIndent('  ').convert(exportData);

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/payments_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject:
            'Payment Report - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
        text: 'Payment report exported as JSON',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting JSON: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getFinancialYearPeriod() {
    DateTime now = DateTime.now();
    int startYear = now.month >= 4 ? now.year : now.year - 1;
    int endYear = startYear + 1;
    return "01 Apr $startYear - 31 Mar $endYear";
  }

  Future<void> _downloadAsPdf() async {
    try {
      List<Map<String, dynamic>> payments = _getFilteredPayments();
      Map<String, dynamic> summary = _calculateSummary();

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // ------------------------------------------------
              // 1. Header: Pal Scaffolding
              // ------------------------------------------------
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Pal Scaffolding',
                      style: pw.TextStyle(
                        fontSize: 30,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // Updated: Date and Financial Year on corners
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Financial Year: ${getFinancialYearPeriod()}',
                          style: pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey800),
                        ),
                        pw.Text(
                          'Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(
                              fontSize: 12, color: PdfColors.black),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 5),
                    pw.Divider(thickness: 1),
                    pw.Center(
                      child: pw.Text(
                        'Payment Summary',
                        style: pw.TextStyle(
                            fontSize: 14, color: PdfColors.grey700),
                      ),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                ),
              ),

              // ------------------------------------------------
              // 2. Summary Section
              // ------------------------------------------------
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryText('Total Credit', summary['totalCredit'],
                        PdfColors.green700),
                    _buildSummaryText(
                        'Total Debit', summary['totalDebit'], PdfColors.red700),
                    _buildSummaryText('Expenses', summary['totalExpenses'],
                        PdfColors.orange700),
                    _buildSummaryText(
                        'Balance', summary['balance'], PdfColors.black,
                        isBold: true),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ------------------------------------------------
              // 3. Stylish Payments Table with Sr No
              // ------------------------------------------------
              pw.Table.fromTextArray(
                // Added Sr No to header
                headers: ['Sr No', 'Date', 'Company', 'Type', 'Amount', 'Mode'],
                // Updated data mapping to include index
                data: payments.asMap().entries.map((entry) {
                  int idx = entry.key + 1; // Sr No starts from 1
                  Map<String, dynamic> payment = entry.value;

                  String typeLabel = '';
                  if (payment['type'] == 'credit')
                    typeLabel = 'Credit';
                  else if (payment['type'] == 'debit')
                    typeLabel = 'Debit';
                  else
                    typeLabel = 'Expense';

                  return [
                    idx.toString(), // Sr No
                    payment['date'],
                    payment['companyName'],
                    typeLabel,
                    '${NumberFormat('#,##,##0').format(payment['amount'])}',
                    payment['mode'],
                  ];
                }).toList(),

                // Table Styling
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                ),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                ),
                cellPadding: pw.EdgeInsets.all(8),
                cellAlignment: pw.Alignment.centerLeft,
                oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
                // Adjust column widths if needed (0 is Sr No, make it small)
                columnWidths: {
                  0: pw.FixedColumnWidth(40),
                  1: pw.FixedColumnWidth(70),
                  2: pw.FlexColumnWidth(),
                  3: pw.FixedColumnWidth(60),
                  4: pw.FixedColumnWidth(70),
                  5: pw.FixedColumnWidth(70),
                },
              ),
            ];
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final fileName =
          "Pal_Scaffolding_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${output.path}/$fileName");

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF opened successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _buildSummaryText(String label, dynamic value, PdfColor color,
      {bool isBold = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.Text(
          '${NumberFormat('#,##,##0').format(value)}',
          style: pw.TextStyle(
              fontSize: 14,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color),
        ),
      ],
    );
  }

  void _showDownloadOptions() {
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
            children: [
              Text(
                'Download Payment Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Download as PDF'),
                subtitle: Text('Get a formatted PDF report'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadAsPdf();
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.code, color: Colors.blue),
                title: Text('Download as JSON'),
                subtitle: Text('Get data in JSON format'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadAsJson();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> summary = _calculateSummary();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('All Payments', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: _showDownloadOptions,
          ),
          IconButton(
            icon: Icon(Icons.filter_alt, color: Colors.white),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Credit'),
            Tab(text: 'Debit'),
            Tab(text: 'Expenses'), // New Tab
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSummaryCard(
                    'Credit',
                    '₹${NumberFormat('#,##,##0').format(summary['totalCredit'])}',
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                  SizedBox(width: 8),
                  _buildSummaryCard(
                    'Debit',
                    '₹${NumberFormat('#,##,##0').format(summary['totalDebit'])}',
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                  SizedBox(width: 8),
                  _buildSummaryCard(
                    'Expenses',
                    '₹${NumberFormat('#,##,##0').format(summary['totalExpenses'])}',
                    Colors.orange,
                    Icons.receipt_long,
                  ),
                  SizedBox(width: 8),
                  _buildSummaryCard(
                    'Balance',
                    '₹${NumberFormat('#,##,##0').format(summary['balance'])}',
                    summary['balance'] >= 0 ? Colors.blue : Colors.orange,
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by company or ID...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filters Section
          if (showFilters)
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Column(
                children: [
                  // Date Filters
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            dateFrom == null
                                ? 'From Date'
                                : DateFormat('dd MMM yyyy').format(dateFrom!),
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _selectDate(context, true),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            dateTo == null
                                ? 'To Date'
                                : DateFormat('dd MMM yyyy').format(dateTo!),
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () => _selectDate(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Status and Payment Mode Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: ['All', 'Completed', 'Pending']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status,
                                        style: TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPaymentMode,
                          decoration: InputDecoration(
                            labelText: 'Payment Mode',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            'All',
                            'Bank Transfer',
                            'UPI',
                            'Cheque',
                            'Cash',
                            'NEFT',
                            'Online'
                          ]
                              .map((mode) => DropdownMenuItem(
                                    value: mode,
                                    child: Text(mode,
                                        style: TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMode = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Clear Filters Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.clear_all),
                      label: Text('Clear All Filters'),
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Payments List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentList(), // All
                _buildPaymentList(), // Credit
                _buildPaymentList(), // Debit
                _buildPaymentList(), // Expenses
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String amount, Color color, IconData icon) {
    return Container(
      width: 100, // Fixed width for scrollable row
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    List<Map<String, dynamic>> payments = _getFilteredPayments();

    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No records found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _buildSimplifiedEntry(payments[index]),
        );
      },
    );
  }

  Widget _buildSimplifiedEntry(Map<String, dynamic> payment) {
    Color typeColor;
    IconData typeIcon;

    if (payment['type'] == 'credit') {
      typeColor = Colors.green;
      typeIcon = Icons.arrow_downward;
    } else if (payment['type'] == 'debit') {
      typeColor = Colors.red;
      typeIcon = Icons.arrow_upward;
    } else {
      // Expenses
      typeColor = Colors.orange;
      typeIcon = Icons.receipt_long;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          CircleAvatar(
            backgroundColor: typeColor.withOpacity(0.1),
            radius: 24,
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          SizedBox(width: 16),

          // Company Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['companyName'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      payment['date'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: payment['status'] == 'Completed'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment['status'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: payment['status'] == 'Completed'
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${NumberFormat('#,##,##0').format(payment['amount'])}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
              SizedBox(height: 2),
              Text(
                payment['id'],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// Add this for date formatting

class AllChallans extends StatefulWidget {
  @override
  _AllChallansState createState() => _AllChallansState();
}

class _AllChallansState extends State<AllChallans> {
  DateTime? dateFrom;
  DateTime? dateTo;

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (dateFrom ?? DateTime.now())
          : (dateTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          dateFrom = pickedDate;
        } else {
          dateTo = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('All Challans', style: TextStyle(color: Colors.white)),
        actions: const [],
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildEntry(
              //   title: 'Created Inward Challan',
              //   date: '6 Sept 2025',
              //   time: '',
              //   details:
              //       'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
              //   id: 'B-08-4432',
              // ),
              // SizedBox(height: 16),
              _buildEntry(
                title: 'Created Inward Challan',
                date: '5 Sept 2025',
                time: '',
                details:
                    'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
                id: 'B-08-4432',
              ),
              SizedBox(height: 16),
              _buildEntry(
                title: 'Created Outward Challan',
                date: '5 Sept 2025',
                time: '',
                details:
                    'A-388, Sudama Puri Colony, Bihari Pura, Ghaziabad-201001, Uttar Pradesh, India',
                id: 'B-08-4432',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntry({
    required String title,
    required String date,
    required String time,
    required String details,
    required String id,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 13,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Spacer(),
                  Text(
                    id,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 16),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            details,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
