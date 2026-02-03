import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Bill Class for GST Returns
class GSTBill {
  final String billNumber;
  final double billValue;
  final String billDate;
  final String billProvider;
  final String billType;
  final double cgst;
  final double sgst;
  final double igst;
  final double taxableAmount;
  final String gstin;

  GSTBill({
    required this.billNumber,
    required this.billValue,
    required this.billDate,
    required this.billProvider,
    required this.billType,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.taxableAmount,
    required this.gstin,
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
        'gstin': gstin,
      };
}

// GST R1 - Outward Supplies (Sales) with Date Filter
class GSTR1 extends StatefulWidget {
  @override
  State<GSTR1> createState() => _GSTR1State();
}

class _GSTR1State extends State<GSTR1> {
  final List<GSTBill> _allBills = [];
  List<GSTBill> _filteredBills = [];
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  DateTime? _startDate;
  DateTime? _endDate;
  String _filterType = 'All'; // All, Today, This Week, This Month, Custom

  @override
  void initState() {
    super.initState();
    _generateRandomBills();
  }

  void _generateRandomBills() {
    _allBills.clear();
    final random = Random();
    final providers = [
      "Elatio By Gards LLP",
      "Shree Ram Traders",
      "Ganesh Enterprises",
      "Prakash & Co.",
      "Amit Steels",
      "Sai Cement",
      "Kumar Industries",
      "Rajesh Suppliers"
    ];

    for (int i = 0; i < 15; i++) {
      final billNumber = (1000 + random.nextInt(9000)).toString();
      final taxableAmount = 5000 + random.nextDouble() * 45000;
      final randomProvider = providers[random.nextInt(providers.length)];

      final isIGST = random.nextBool();
      double cgst = 0, sgst = 0, igst = 0;

      if (isIGST) {
        igst = taxableAmount * 0.18;
      } else {
        cgst = taxableAmount * 0.09;
        sgst = taxableAmount * 0.09;
      }

      final totalValue = taxableAmount + cgst + sgst + igst;
      final gstin =
          '${random.nextInt(10)}${random.nextInt(10)}AAAAA${random.nextInt(10000)}A${random.nextInt(10)}Z${random.nextInt(10)}';

      _allBills.add(
        GSTBill(
          billNumber: billNumber,
          billValue: totalValue,
          taxableAmount: taxableAmount,
          cgst: cgst,
          sgst: sgst,
          igst: igst,
          billProvider: randomProvider,
          billDate: _getRandomDate(),
          billType: 'Sale',
          gstin: gstin,
        ),
      );
    }
    _applyFilter();
  }

  String _getRandomDate() {
    final now = DateTime.now();
    final random = Random();
    final daysBack = random.nextInt(60); // Last 60 days
    final randomDate = now.subtract(Duration(days: daysBack));
    return DateFormat('dd-MM-yyyy').format(randomDate);
  }

  void _applyFilter() {
    setState(() {
      if (_filterType == 'All') {
        _filteredBills = List.from(_allBills);
      } else if (_filterType == 'Today') {
        final today = DateTime.now();
        _filteredBills = _allBills.where((bill) {
          final billDate = DateFormat('dd-MM-yyyy').parse(bill.billDate);
          return billDate.year == today.year &&
              billDate.month == today.month &&
              billDate.day == today.day;
        }).toList();
      } else if (_filterType == 'This Week') {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(Duration(days: 6));
        _filteredBills = _allBills.where((bill) {
          final billDate = DateFormat('dd-MM-yyyy').parse(bill.billDate);
          return billDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
              billDate.isBefore(weekEnd.add(Duration(days: 1)));
        }).toList();
      } else if (_filterType == 'This Month') {
        final now = DateTime.now();
        _filteredBills = _allBills.where((bill) {
          final billDate = DateFormat('dd-MM-yyyy').parse(bill.billDate);
          return billDate.year == now.year && billDate.month == now.month;
        }).toList();
      } else if (_filterType == 'Custom' &&
          _startDate != null &&
          _endDate != null) {
        _filteredBills = _allBills.where((bill) {
          final billDate = DateFormat('dd-MM-yyyy').parse(bill.billDate);
          return billDate.isAfter(_startDate!.subtract(Duration(days: 1))) &&
              billDate.isBefore(_endDate!.add(Duration(days: 1)));
        }).toList();
      }
    });
  }

  double get _totalTaxableAmount =>
      _filteredBills.fold(0, (sum, bill) => sum + bill.taxableAmount);
  double get _totalCGST =>
      _filteredBills.fold(0, (sum, bill) => sum + bill.cgst);
  double get _totalSGST =>
      _filteredBills.fold(0, (sum, bill) => sum + bill.sgst);
  double get _totalIGST =>
      _filteredBills.fold(0, (sum, bill) => sum + bill.igst);
  double get _totalAmount =>
      _filteredBills.fold(0, (sum, bill) => sum + bill.billValue);

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempFilter = _filterType;
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Filter Invoices'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: Text('All'),
                      value: 'All',
                      groupValue: tempFilter,
                      onChanged: (value) {
                        setDialogState(() => tempFilter = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Today'),
                      value: 'Today',
                      groupValue: tempFilter,
                      onChanged: (value) {
                        setDialogState(() => tempFilter = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('This Week'),
                      value: 'This Week',
                      groupValue: tempFilter,
                      onChanged: (value) {
                        setDialogState(() => tempFilter = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('This Month'),
                      value: 'This Month',
                      groupValue: tempFilter,
                      onChanged: (value) {
                        setDialogState(() => tempFilter = value!);
                      },
                    ),
                    RadioListTile<String>(
                      title: Text('Custom Range'),
                      value: 'Custom',
                      groupValue: tempFilter,
                      onChanged: (value) {
                        setDialogState(() => tempFilter = value!);
                      },
                    ),
                    if (tempFilter == 'Custom') ...[
                      SizedBox(height: 10),
                      ListTile(
                        title: Text(
                          tempStartDate == null
                              ? 'Select Start Date'
                              : 'From: ${DateFormat('dd-MM-yyyy').format(tempStartDate!)}',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.calendar_today, size: 20),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempStartDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() => tempStartDate = date);
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                          tempEndDate == null
                              ? 'Select End Date'
                              : 'To: ${DateFormat('dd-MM-yyyy').format(tempEndDate!)}',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(Icons.calendar_today, size: 20),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempEndDate ?? DateTime.now(),
                            firstDate: tempStartDate ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setDialogState(() => tempEndDate = date);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterType = tempFilter;
                      _startDate = tempStartDate;
                      _endDate = tempEndDate;
                    });
                    _applyFilter();
                    Navigator.pop(context);
                  },
                  child: Text('Apply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _shareAsJson() async {
    final jsonData = {
      'returnType': 'GSTR-1',
      'period': _selectedMonth,
      'filterApplied': _filterType,
      'exportDate': DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      'outwardSupplies': _filteredBills.map((bill) => bill.toJson()).toList(),
      'summary': {
        'totalInvoices': _filteredBills.length,
        'totalTaxableValue': _totalTaxableAmount,
        'totalCGST': _totalCGST,
        'totalSGST': _totalSGST,
        'totalIGST': _totalIGST,
        'totalTaxAmount': _totalCGST + _totalSGST + _totalIGST,
        'totalInvoiceValue': _totalAmount,
      }
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/GSTR1_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'GSTR-1 Return Data',
    );
  }

  void _showSummary() {
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
                    'GSTR-1 Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Text(
                'Filter: $_filterType',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Divider(),
              SizedBox(height: 10),
              _buildSummaryRow('Total Invoices', '${_filteredBills.length}'),
              _buildSummaryRow('Taxable Value',
                  '₹${_totalTaxableAmount.toStringAsFixed(2)}'),
              Divider(),
              _buildSummaryRow('CGST', '₹${_totalCGST.toStringAsFixed(2)}',
                  color: Colors.blue),
              _buildSummaryRow('SGST', '₹${_totalSGST.toStringAsFixed(2)}',
                  color: Colors.blue),
              _buildSummaryRow('IGST', '₹${_totalIGST.toStringAsFixed(2)}',
                  color: Colors.orange),
              Divider(),
              _buildSummaryRow(
                'Total Tax',
                '₹${(_totalCGST + _totalSGST + _totalIGST).toStringAsFixed(2)}',
                color: Colors.red,
                isBold: true,
              ),
              _buildSummaryRow(
                'Total Invoice Value',
                '₹${_totalAmount.toStringAsFixed(2)}',
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "GSTR-1 (Outward Supplies)",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.assessment, color: Colors.white),
            onPressed: _showSummary,
            tooltip: 'View Summary',
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareAsJson,
            tooltip: 'Share JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal.shade50,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Return Period:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      _selectedMonth,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_list, size: 14, color: Colors.teal),
                        SizedBox(width: 4),
                        Text(
                          _filterType,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_filteredBills.length} Invoices',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ₹${_totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredBills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No invoices found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _filterType = 'All';
                            });
                            _applyFilter();
                          },
                          icon: Icon(Icons.clear_all),
                          label: Text('Clear Filter'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: _filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = _filteredBills[index];
                      return GSTBillCard(bill: bill);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateRandomBills,
        icon: Icon(Icons.refresh),
        label: Text('Refresh'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// GST R2B - Inward Supplies (Purchases)
class GSTR2B extends StatefulWidget {
  @override
  State<GSTR2B> createState() => _GSTR2BState();
}

class _GSTR2BState extends State<GSTR2B> {
  final List<GSTBill> _bills = [];
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _generateRandomBills();
  }

  void _generateRandomBills() {
    _bills.clear();
    final random = Random();
    final suppliers = [
      "ABC Suppliers Pvt Ltd",
      "XYZ Trading Co.",
      "Steel King Industries",
      "Modern Cement Works",
      "Prime Materials Ltd",
      "Global Traders"
    ];

    for (int i = 0; i < 6; i++) {
      final billNumber = (2000 + random.nextInt(8000)).toString();
      final taxableAmount = 8000 + random.nextDouble() * 42000;
      final randomSupplier = suppliers[random.nextInt(suppliers.length)];

      final isIGST = random.nextBool();
      double cgst = 0, sgst = 0, igst = 0;

      if (isIGST) {
        igst = taxableAmount * 0.18;
      } else {
        cgst = taxableAmount * 0.09;
        sgst = taxableAmount * 0.09;
      }

      final totalValue = taxableAmount + cgst + sgst + igst;
      final gstin =
          '${random.nextInt(10)}${random.nextInt(10)}BBBBB${random.nextInt(10000)}B${random.nextInt(10)}Z${random.nextInt(10)}';

      _bills.add(
        GSTBill(
          billNumber: billNumber,
          billValue: totalValue,
          taxableAmount: taxableAmount,
          cgst: cgst,
          sgst: sgst,
          igst: igst,
          billProvider: randomSupplier,
          billDate: _getRandomDate(),
          billType: 'Purchase',
          gstin: gstin,
        ),
      );
    }
    setState(() {});
  }

  String _getRandomDate() {
    final now = DateTime.now();
    final random = Random();
    final day = 1 + random.nextInt(28);
    final randomDate = DateTime(now.year, now.month, day);
    return DateFormat('dd-MM-yyyy').format(randomDate);
  }

  double get _totalTaxableAmount =>
      _bills.fold(0, (sum, bill) => sum + bill.taxableAmount);
  double get _totalCGST => _bills.fold(0, (sum, bill) => sum + bill.cgst);
  double get _totalSGST => _bills.fold(0, (sum, bill) => sum + bill.sgst);
  double get _totalIGST => _bills.fold(0, (sum, bill) => sum + bill.igst);
  double get _totalAmount =>
      _bills.fold(0, (sum, bill) => sum + bill.billValue);

  Future<void> _shareAsJson() async {
    final jsonData = {
      'returnType': 'GSTR-2B',
      'period': _selectedMonth,
      'exportDate': DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      'inwardSupplies': _bills.map((bill) => bill.toJson()).toList(),
      'summary': {
        'totalInvoices': _bills.length,
        'totalTaxableValue': _totalTaxableAmount,
        'totalCGST': _totalCGST,
        'totalSGST': _totalSGST,
        'totalIGST': _totalIGST,
        'totalITC': _totalCGST + _totalSGST + _totalIGST,
        'totalInvoiceValue': _totalAmount,
      }
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/GSTR2B_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'GSTR-2B Return Data',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "GSTR-2B (ITC Available)",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareAsJson,
            tooltip: 'Share JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.orange.shade50,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ITC Available:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '₹${(_totalCGST + _totalSGST + _totalIGST).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_bills.length} Purchase Invoices',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Total: ₹${_totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _bills.isEmpty
                ? Center(child: Text('No purchase invoices found'))
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: _bills.length,
                    itemBuilder: (context, index) {
                      final bill = _bills[index];
                      return GSTBillCard(bill: bill);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateRandomBills,
        icon: Icon(Icons.refresh),
        label: Text('Refresh'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// GST R3B - Monthly Return
class GSTR3B extends StatefulWidget {
  @override
  State<GSTR3B> createState() => _GSTR3BState();
}

class _GSTR3BState extends State<GSTR3B> {
  final List<GSTBill> _outwardBills = [];
  final List<GSTBill> _inwardBills = [];
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _generateRandomBills();
  }

  void _generateRandomBills() {
    _outwardBills.clear();
    _inwardBills.clear();
    final random = Random();

    // Generate Outward (Sales)
    for (int i = 0; i < 5; i++) {
      final billNumber = (3000 + random.nextInt(7000)).toString();
      final taxableAmount = 10000 + random.nextDouble() * 40000;

      final isIGST = random.nextBool();
      double cgst = 0, sgst = 0, igst = 0;

      if (isIGST) {
        igst = taxableAmount * 0.18;
      } else {
        cgst = taxableAmount * 0.09;
        sgst = taxableAmount * 0.09;
      }

      final totalValue = taxableAmount + cgst + sgst + igst;

      _outwardBills.add(
        GSTBill(
          billNumber: billNumber,
          billValue: totalValue,
          taxableAmount: taxableAmount,
          cgst: cgst,
          sgst: sgst,
          igst: igst,
          billProvider: "Customer ${i + 1}",
          billDate: _getRandomDate(),
          billType: 'Sale',
          gstin: 'GSTIN${random.nextInt(10000)}',
        ),
      );
    }

    // Generate Inward (Purchases)
    for (int i = 0; i < 3; i++) {
      final billNumber = (4000 + random.nextInt(6000)).toString();
      final taxableAmount = 8000 + random.nextDouble() * 32000;

      final isIGST = random.nextBool();
      double cgst = 0, sgst = 0, igst = 0;

      if (isIGST) {
        igst = taxableAmount * 0.18;
      } else {
        cgst = taxableAmount * 0.09;
        sgst = taxableAmount * 0.09;
      }

      final totalValue = taxableAmount + cgst + sgst + igst;

      _inwardBills.add(
        GSTBill(
          billNumber: billNumber,
          billValue: totalValue,
          taxableAmount: taxableAmount,
          cgst: cgst,
          sgst: sgst,
          igst: igst,
          billProvider: "Supplier ${i + 1}",
          billDate: _getRandomDate(),
          billType: 'Purchase',
          gstin: 'GSTIN${random.nextInt(10000)}',
        ),
      );
    }
    setState(() {});
  }

  String _getRandomDate() {
    final now = DateTime.now();
    final random = Random();
    final day = 1 + random.nextInt(28);
    final randomDate = DateTime(now.year, now.month, day);
    return DateFormat('dd-MM-yyyy').format(randomDate);
  }

  double get _outwardCGST =>
      _outwardBills.fold(0, (sum, bill) => sum + bill.cgst);
  double get _outwardSGST =>
      _outwardBills.fold(0, (sum, bill) => sum + bill.sgst);
  double get _outwardIGST =>
      _outwardBills.fold(0, (sum, bill) => sum + bill.igst);
  double get _totalOutwardTax => _outwardCGST + _outwardSGST + _outwardIGST;

  double get _inwardCGST =>
      _inwardBills.fold(0, (sum, bill) => sum + bill.cgst);
  double get _inwardSGST =>
      _inwardBills.fold(0, (sum, bill) => sum + bill.sgst);
  double get _inwardIGST =>
      _inwardBills.fold(0, (sum, bill) => sum + bill.igst);
  double get _totalITC => _inwardCGST + _inwardSGST + _inwardIGST;

  double get _netTaxPayable => _totalOutwardTax - _totalITC;

  Future<void> _shareAsJson() async {
    final jsonData = {
      'returnType': 'GSTR-3B',
      'period': _selectedMonth,
      'exportDate': DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      'outwardSupplies': {
        'invoices': _outwardBills.map((bill) => bill.toJson()).toList(),
        'summary': {
          'totalCGST': _outwardCGST,
          'totalSGST': _outwardSGST,
          'totalIGST': _outwardIGST,
          'totalTax': _totalOutwardTax,
        }
      },
      'inwardSupplies': {
        'invoices': _inwardBills.map((bill) => bill.toJson()).toList(),
        'summary': {
          'totalCGST': _inwardCGST,
          'totalSGST': _inwardSGST,
          'totalIGST': _inwardIGST,
          'totalITC': _totalITC,
        }
      },
      'netTaxPayable': _netTaxPayable,
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(jsonData);
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/GSTR3B_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'GSTR-3B Return Data',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "GSTR-3B (Monthly Return)",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareAsJson,
            tooltip: 'Share JSON',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Net Tax Payable Card
          Card(
            elevation: 4,
            color:
                _netTaxPayable >= 0 ? Colors.red.shade50 : Colors.green.shade50,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Net Tax Payable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹${_netTaxPayable.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _netTaxPayable >= 0
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _netTaxPayable >= 0
                        ? 'Amount to be paid'
                        : 'Refund available',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Outward Supplies Section
          Text(
            'Outward Supplies (Sales)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTaxRow('CGST', _outwardCGST, Colors.blue),
                  _buildTaxRow('SGST', _outwardSGST, Colors.blue),
                  _buildTaxRow('IGST', _outwardIGST, Colors.orange),
                  Divider(),
                  _buildTaxRow('Total Tax', _totalOutwardTax, Colors.red,
                      isBold: true),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          ..._outwardBills.map((bill) => GSTBillCard(bill: bill)),

          SizedBox(height: 16),

          // Inward Supplies Section
          Text(
            'Inward Supplies (Purchases - ITC)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTaxRow('CGST', _inwardCGST, Colors.blue),
                  _buildTaxRow('SGST', _inwardSGST, Colors.blue),
                  _buildTaxRow('IGST', _inwardIGST, Colors.orange),
                  Divider(),
                  _buildTaxRow('Total ITC', _totalITC, Colors.green,
                      isBold: true),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          ..._inwardBills.map((bill) => GSTBillCard(bill: bill)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateRandomBills,
        icon: Icon(Icons.refresh),
        label: Text('Refresh'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTaxRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Bill Card Widget
class GSTBillCard extends StatelessWidget {
  final GSTBill bill;

  const GSTBillCard({required this.bill});

  Color _getTypeColor() {
    switch (bill.billType) {
      case 'Sale':
        return Colors.blue.shade700;
      case 'Purchase':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.billProvider,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Inv: ${bill.billNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          color: _getTypeColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${bill.billValue.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      bill.billDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Taxable Amount:',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                      Text('₹${bill.taxableAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (bill.cgst > 0)
                              _buildTaxChip('CGST', bill.cgst, Colors.blue),
                            if (bill.sgst > 0)
                              _buildTaxChip('SGST', bill.sgst, Colors.blue),
                            if (bill.igst > 0)
                              _buildTaxChip('IGST', bill.igst, Colors.orange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (bill.gstin.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'GSTIN: ${bill.gstin}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxChip(String label, double amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ₹${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
