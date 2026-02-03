import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:scaffolding_sale/utils/colors.dart';

// ============= MODELS =============
class SlipDetailData {
  final String title;
  final String value;
  final String issueCount;

  SlipDetailData({
    required this.title,
    required this.value,
    required this.issueCount,
  });
}

class SlipData {
  final DateTime date;
  final String slipNo;
  final String totalStaff;
  final List<SlipDetailData> details;

  SlipData({
    required this.date,
    required this.slipNo,
    required this.totalStaff,
    required this.details,
  });
}

class ServiceBill {
  final String billNo;
  final DateTime date;
  final List<SlipData> slips;
  final double grandTotal;
  final String creationType; // 'date' or 'slip'
  final bool isPerforma; // true = Performa, false = Tax Invoice
  String? eWayBillNo;

  ServiceBill({
    required this.billNo,
    required this.date,
    required this.slips,
    required this.grandTotal,
    required this.creationType,
    required this.isPerforma,
    this.eWayBillNo,
  });
}

// ============= MAIN SERVICE BILLS SCREEN =============
class ServiceBillsScreen extends StatefulWidget {
  const ServiceBillsScreen({super.key});

  @override
  State<ServiceBillsScreen> createState() => _ServiceBillsScreenState();
}

class _ServiceBillsScreenState extends State<ServiceBillsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<ServiceBill> performaBills = [];
  List<ServiceBill> taxBills = [];

  // Hardcoded slip data
  final List<SlipData> slipList = [
    SlipData(
      date: DateTime(2025, 11, 12),
      slipNo: '01',
      totalStaff: '01',
      details: [
        SlipDetailData(
          title: 'Scaffolding Fixing\n100*80*2',
          value: '₹ 20',
          issueCount: '320000',
        ),
        SlipDetailData(
          title: 'Scaffolding Closing\n10*20*2',
          value: '₹ 20',
          issueCount: '2080',
        ),
        SlipDetailData(title: 'Material', value: '', issueCount: '100'),
        SlipDetailData(title: 'Total', value: '  ', issueCount: '322180'),
      ],
    ),
    SlipData(
      date: DateTime(2025, 11, 13),
      slipNo: '02',
      totalStaff: '02',
      details: [
        SlipDetailData(
          title: 'Scaffolding Fixing\n50*10*1',
          value: '₹ 15',
          issueCount: '5000',
        ),
        SlipDetailData(
          title: 'Scaffolding Fixing\n10*10*1',
          value: '₹ 10',
          issueCount: '1000',
        ),
        SlipDetailData(
          title: 'Scaffolding Closing\n10*20*2',
          value: '₹ 500',
          issueCount: '500',
        ),
        SlipDetailData(title: 'Total', value: '  ', issueCount: '6500'),
      ],
    ),
    SlipData(
      date: DateTime(2025, 11, 14),
      slipNo: '03',
      totalStaff: '03',
      details: [
        SlipDetailData(
          title: 'Scaffolding Fixing\n100*1',
          value: '₹ 5',
          issueCount: '100',
        ),
        SlipDetailData(
          title: 'Scaffolding Fixing',
          value: '₹ 200',
          issueCount: '200',
        ),
        SlipDetailData(title: 'Total', value: '  ', issueCount: '300'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateBillOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Service Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Create by Date'),
              subtitle: const Text('Select date range for bill'),
              onTap: () {
                Navigator.pop(context);
                _showBillTypeSelection('date');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.green),
              title: const Text('Create by Slips'),
              subtitle: const Text('Select specific slips'),
              onTap: () {
                Navigator.pop(context);
                _showBillTypeSelection('slip');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBillTypeSelection(String creationType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Bill Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.description_outlined,
                  color: Colors.orange.shade700),
              title: const Text('Performa Invoice'),
              subtitle: const Text('Create a performa invoice'),
              onTap: () {
                Navigator.pop(context);
                if (creationType == 'date') {
                  _showDateSelectionDialog(true);
                } else {
                  _showSlipSelectionDialog(true);
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.receipt_long_outlined,
                  color: Colors.green.shade700),
              title: const Text('Tax Invoice'),
              subtitle: const Text('Create a tax invoice directly'),
              onTap: () {
                Navigator.pop(context);
                if (creationType == 'date') {
                  _showDateSelectionDialog(false);
                } else {
                  _showSlipSelectionDialog(false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateSelectionDialog(bool isPerforma) {
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
              'Select Date Range - ${isPerforma ? 'Performa' : 'Tax Invoice'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(startDate != null
                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                    : 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => startDate = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(endDate != null
                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                    : 'Not selected'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => endDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (startDate == null || endDate == null) {
                  Fluttertoast.showToast(msg: 'Please select both dates');
                  return;
                }
                if (endDate!.isBefore(startDate!)) {
                  Fluttertoast.showToast(
                      msg: 'End date must be after start date');
                  return;
                }
                Navigator.pop(context);
                _createBillByDate(startDate!, endDate!, isPerforma);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: isPerforma ? Colors.orange : Colors.green),
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSlipSelectionDialog(bool isPerforma) {
    List<String> selectedSlips = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title:
              Text('Select Slips - ${isPerforma ? 'Performa' : 'Tax Invoice'}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: slipList.length,
              itemBuilder: (context, index) {
                final slip = slipList[index];
                final isSelected = selectedSlips.contains(slip.slipNo);
                return CheckboxListTile(
                  title: Text('Slip #${slip.slipNo}'),
                  subtitle: Text(
                      '${slip.date.day}/${slip.date.month}/${slip.date.year} - Staff: ${slip.totalStaff}'),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setDialogState(() {
                      if (value == true) {
                        selectedSlips.add(slip.slipNo);
                      } else {
                        selectedSlips.remove(slip.slipNo);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedSlips.isEmpty) {
                  Fluttertoast.showToast(
                      msg: 'Please select at least one slip');
                  return;
                }
                Navigator.pop(context);
                _createBillBySlips(selectedSlips, isPerforma);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: isPerforma ? Colors.orange : Colors.green),
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _createBillByDate(
      DateTime startDate, DateTime endDate, bool isPerforma) {
    final filteredSlips = slipList.where((slip) {
      return (slip.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          slip.date.isBefore(endDate.add(const Duration(days: 1))));
    }).toList();

    if (filteredSlips.isEmpty) {
      Fluttertoast.showToast(msg: 'No slips found in selected date range');
      return;
    }

    double total = 0;
    for (var slip in filteredSlips) {
      final totalDetail = slip.details.firstWhere(
        (d) => d.title.toLowerCase().contains('total'),
        orElse: () => SlipDetailData(title: '', value: '', issueCount: '0'),
      );
      total += double.tryParse(totalDetail.issueCount) ?? 0;
    }

    final prefix = isPerforma ? 'PI' : 'TI';
    final list = isPerforma ? performaBills : taxBills;

    final newBill = ServiceBill(
      billNo: '$prefix-${(list.length + 1).toString()}',
      date: DateTime.now(),
      slips: filteredSlips,
      grandTotal: total,
      creationType: 'date',
      isPerforma: isPerforma,
    );

    setState(() {
      if (isPerforma) {
        performaBills.insert(0, newBill);
        _tabController.animateTo(0);
      } else {
        taxBills.insert(0, newBill);
        _tabController.animateTo(1);
      }
    });

    Fluttertoast.showToast(
        msg:
            '${isPerforma ? 'Performa Invoice' : 'Tax Invoice'} created successfully!');
  }

  void _createBillBySlips(List<String> selectedSlipNos, bool isPerforma) {
    final selectedSlips = slipList
        .where((slip) => selectedSlipNos.contains(slip.slipNo))
        .toList();

    double total = 0;
    for (var slip in selectedSlips) {
      final totalDetail = slip.details.firstWhere(
        (d) => d.title.toLowerCase().contains('total'),
        orElse: () => SlipDetailData(title: '', value: '', issueCount: '0'),
      );
      total += double.tryParse(totalDetail.issueCount) ?? 0;
    }

    final prefix = isPerforma ? 'PI' : 'TI';
    final list = isPerforma ? performaBills : taxBills;

    final newBill = ServiceBill(
      billNo: '$prefix-${(list.length + 1).toString()}',
      date: DateTime.now(),
      slips: selectedSlips,
      grandTotal: total,
      creationType: 'slip',
      isPerforma: isPerforma,
    );

    setState(() {
      if (isPerforma) {
        performaBills.insert(0, newBill);
        _tabController.animateTo(0);
      } else {
        taxBills.insert(0, newBill);
        _tabController.animateTo(1);
      }
    });

    Fluttertoast.showToast(
        msg:
            '${isPerforma ? 'Performa Invoice' : 'Tax Invoice'} created successfully!');
  }

  void _transferToTaxInvoice(ServiceBill performaBill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer to Tax Invoice'),
        content: Text(
            'Transfer ${performaBill.billNo} to Tax Invoice?\n\nThis will create a new Tax Invoice with the same details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newBillNo =
                    'TI-${DateTime.now().year}${(taxBills.length + 1).toString().padLeft(4, '0')}';
                final newTaxBill = ServiceBill(
                  billNo: newBillNo,
                  date: DateTime.now(),
                  slips: performaBill.slips,
                  grandTotal: performaBill.grandTotal,
                  creationType: performaBill.creationType,
                  isPerforma: false,
                );
                taxBills.insert(0, newTaxBill);
                performaBills.remove(performaBill);
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: 'Transferred to Tax Invoice successfully!');
              _tabController.animateTo(1);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child:
                const Text('Transfer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addEWayBill(ServiceBill bill) {
    final TextEditingController eWayBillController = TextEditingController();
    if (bill.eWayBillNo != null) {
      eWayBillController.text = bill.eWayBillNo!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add E-Way Bill Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bill No: ${bill.billNo}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: eWayBillController,
              decoration: InputDecoration(
                hintText: 'Enter E-Way Bill Number',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.receipt_long),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (eWayBillController.text.isEmpty) {
                Fluttertoast.showToast(msg: 'Please enter E-Way Bill number');
                return;
              }
              setState(() {
                bill.eWayBillNo = eWayBillController.text;
              });
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'E-Way Bill added successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBillDetails(ServiceBill bill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceBillDetailScreen(
          bill: bill,
          onAddEWayBill: () => _addEWayBill(bill),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FloatingActionButton.extended(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: _showCreateBillOptions,
              backgroundColor: ThemeColors.kSecondaryThemeColor,
              icon: const Icon(Icons.add, color: Colors.white),
              extendedPadding: EdgeInsets.all(2),
              label: const Text('PI & Bill ',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(
            width: 12,
          ),
        ],
        title:
            const Text("Service Bills", style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Performa Invoice"),
            Tab(text: "Tax Invoice"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBillsList(performaBills, true),
          _buildBillsList(taxBills, false),
        ],
      ),
    );
  }

  Widget _buildBillsList(List<ServiceBill> bills, bool isPerforma) {
    if (bills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isPerforma ? 'No Performa Invoices' : 'No Tax Invoices',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              isPerforma
                  ? 'Create your first Performa Invoice'
                  : 'Create Tax Invoice or transfer from Performa',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showBillDetails(bill),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              bill.billNo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${bill.date.day}/${bill.date.month}/${bill.date.year}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPerforma
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPerforma
                                ? Colors.orange.shade200
                                : Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          isPerforma ? 'PERFORMA' : 'TAX',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPerforma ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          'Slips',
                          '${bill.slips.length}',
                          Icons.receipt_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Created',
                          bill.creationType == 'date' ? 'By Date' : 'By Slip',
                          Icons.info_outline,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Total',
                          '₹ ${bill.grandTotal.toStringAsFixed(0)}',
                          Icons.currency_rupee,
                        ),
                      ),
                    ],
                  ),
                  if (!isPerforma && bill.eWayBillNo != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'E-Way: ${bill.eWayBillNo}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (isPerforma)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _transferToTaxInvoice(bill),
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Transfer to Tax Invoice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
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

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

// ============= SERVICE BILL DETAIL SCREEN =============
class ServiceBillDetailScreen extends StatelessWidget {
  final ServiceBill bill;
  final VoidCallback onAddEWayBill;

  const ServiceBillDetailScreen({
    super.key,
    required this.bill,
    required this.onAddEWayBill,
  });

  String _convertNumberToWords(double number) {
    final ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine'
    ];
    final teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];
    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String convertLessThanThousand(int num) {
      if (num == 0) return '';
      if (num < 10) return ones[num];
      if (num < 20) return teens[num - 10];
      if (num < 100) {
        return tens[num ~/ 10] + (num % 10 != 0 ? ' ${ones[num % 10]}' : '');
      }
      return '${ones[num ~/ 100]} Hundred${num % 100 != 0 ? ' ${convertLessThanThousand(num % 100)}' : ''}';
    }

    int rupees = number.toInt();
    int paise = ((number - rupees) * 100).round();

    if (rupees == 0 && paise == 0) return 'Zero Rupees Only';

    String result = '';

    if (rupees >= 10000000) {
      int crores = rupees ~/ 10000000;
      result += '${convertLessThanThousand(crores)} Crore ';
      rupees %= 10000000;
    }

    if (rupees >= 100000) {
      int lakhs = rupees ~/ 100000;
      result += '${convertLessThanThousand(lakhs)} Lakh ';
      rupees %= 100000;
    }

    if (rupees >= 1000) {
      int thousands = rupees ~/ 1000;
      result += '${convertLessThanThousand(thousands)} Thousand ';
      rupees %= 1000;
    }

    if (rupees > 0) {
      result += convertLessThanThousand(rupees);
    }

    result += ' Rupees';

    if (paise > 0) {
      result += ' and ${convertLessThanThousand(paise)} Paise';
    }

    return result.trim() + ' Only';
  }

  Future<void> _generateServiceBillPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final logoBytes = await rootBundle.load('images/logo.png');
      final nameBytes = await rootBundle.load('images/name.png');
      final stampBytes = await rootBundle.load('images/stamp.jpeg');

      final linkStyle = pw.TextStyle(
        color: PdfColors.blue,
        decoration: pw.TextDecoration.underline,
      );

      // Prepare slip details for PDF
      final List<List<dynamic>> slipTableData = [];
      double totalArea = 0; // Track total area
      double subtotal = 0; // Subtotal before GST

      for (var slip in bill.slips) {
        // Add slip header
        slipTableData.add([
          {
            'text':
                'Slip #${slip.slipNo} - ${slip.date.day}/${slip.date.month}/${slip.date.year} - Staff: ${slip.totalStaff}',
            'colspan': 4,
            'bold': true
          },
        ]);

        // Add slip details (including total rows for calculation)
        for (var detail in slip.details) {
          // Extract area from title if present
          String areaText = '';
          double itemArea = 0;

          if (detail.title.contains('*')) {
            final parts = detail.title.split('\n');
            if (parts.length > 1) {
              final calculation = parts[1];
              try {
                final numbers = calculation.split('*');
                itemArea = numbers.fold<double>(
                    1, (prev, num) => prev * double.parse(num.trim()));
                areaText = itemArea.toStringAsFixed(0);
                totalArea += itemArea;
              } catch (e) {
                areaText = '';
              }
            }
          }

          // Add to subtotal (including all items)
          final amount =
              double.tryParse(detail.value.replaceAll('₹', '').trim()) ?? 0;
          subtotal += amount;

          // Skip displaying total rows in PDF (but we counted them above)
          if (detail.title.toLowerCase().contains('total')) {
            continue;
          }

          slipTableData.add([
            {'text': detail.title, 'colspan': 3},
            {'text': areaText, 'colspan': 1},
            {'text': detail.value.replaceAll('₹', '').trim(), 'colspan': 1},
            {
              'text': detail.issueCount.isNotEmpty ? detail.issueCount : '',
              'colspan': 1
            },
          ]);
        }
      }

      // Calculate GST and Grand Total
      double cgstAmount = subtotal * 0.09; // CGST 9%
      double sgstAmount = subtotal * 0.09; // SGST 9%
      double totalGst = cgstAmount + sgstAmount; // Total 18%
      double grandTotal = subtotal + totalGst;

      // Don't add GST rows to table - will show in summary section only

      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(15),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(pw.MemoryImage(logoBytes.buffer.asUint8List()),
                        width: 90, height: 90, fit: pw.BoxFit.fill),
                    pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(nameBytes.buffer.asUint8List()),
                            width: 240, height: 75, fit: pw.BoxFit.fill),
                        pw.Text('(A/N ISO 9001:2015 Certified Company)',
                            style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          bill.isPerforma ? 'PERFORMA INVOICE' : 'TAX INVOICE',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('Bill No: ${bill.billNo}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Date: ${bill.date.day}/${bill.date.month}/${bill.date.year}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 5),

                // Address
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.RichText(
                    textAlign: pw.TextAlign.start,
                    text: pw.TextSpan(
                      style: const pw.TextStyle(fontSize: 8),
                      children: [
                        const pw.TextSpan(
                            text:
                                'PLOT NO-23 KHASRA NO 14/1 RANI LAXMI BAI NAGAR, DUNDA HERA, GHAZIABAD (U.P) - 201001 MOBILE NO: '),
                        pw.TextSpan(
                            text: '9871227048',
                            style: linkStyle,
                            annotation: pw.AnnotationUrl('tel:9871227048')),
                        const pw.TextSpan(text: ', '),
                        pw.TextSpan(
                            text: '9213449692',
                            style: linkStyle,
                            annotation: pw.AnnotationUrl('tel:9213449692')),
                      ],
                    ),
                  ),
                ),

                // Bill To / Ship To
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Bill To: UP02/01/01',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                            pw.Text('M/S: Elatio By Gards LLP',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.Text(
                                'Billing Add: PLOT NO.120 KHASRA NO 372M, HAIBATPUR, VILLAGE HAIBATPUR, Noida, Gautambuddha Nagar, Uttar Pradesh, 201301',
                                style: const pw.TextStyle(fontSize: 7)),
                            pw.Text('GST NO: 09DFSPG6487R1Z2',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8),
                                children: [
                                  const pw.TextSpan(text: 'Phone: '),
                                  pw.TextSpan(
                                      text: '9876543210',
                                      style: linkStyle,
                                      annotation:
                                          pw.AnnotationUrl('tel:9876543210')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                          width: 1, color: PdfColors.black, height: 60),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Ship To: ',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                            pw.Text(
                                'Delivery Address: PLOT NO.120 KHASRA NO 372M, HAIBATPUR, VILLAGE HAIBATPUR, Noida, Gautambuddha Nagar, Uttar Pradesh, 201301',
                                style: const pw.TextStyle(fontSize: 7)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 5),

                // Slip Details Table
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1, color: PdfColors.black),
                    ),
                    child: pw.Table(
                      border: pw.TableBorder.all(
                          width: 0.5, color: PdfColors.black),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(4),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        // Header Row
                        pw.TableRow(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.grey300),
                          children: ['Description', 'Area', 'Rate', 'Amount']
                              .map((h) => pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      h,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 9),
                                      textAlign: pw.TextAlign.center,
                                    ),
                                  ))
                              .toList(),
                        ),
                        // Data Rows
                        ...slipTableData.map((row) {
                          final cell = row[0];
                          final isBold = cell['bold'] == true;
                          final colspan = cell['colspan'] as int;

                          if (colspan == 4) {
                            return pw.TableRow(
                              decoration: isBold
                                  ? const pw.BoxDecoration(
                                      color: PdfColors.grey200)
                                  : null,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    cell['text'],
                                    textAlign: pw.TextAlign.start,
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: isBold
                                          ? pw.FontWeight.bold
                                          : pw.FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return pw.TableRow(
                              decoration: isBold
                                  ? const pw.BoxDecoration(
                                      color: PdfColors.grey200)
                                  : null,
                              children: row.map((cell) {
                                final isBold = cell['bold'] == true;
                                final int index = row.indexOf(cell);

                                pw.TextAlign align;
                                if (index == 0) {
                                  align = pw.TextAlign.left;
                                } else if (index == row.length - 1) {
                                  align = pw.TextAlign.right;
                                } else {
                                  align = pw.TextAlign.center;
                                }

                                return pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    cell['text'],
                                    textAlign: align,
                                    style: pw.TextStyle(
                                      fontSize: isBold ? 9 : 8,
                                      fontWeight: isBold
                                          ? pw.FontWeight.bold
                                          : pw.FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList());
                        })
                      ],
                    ),
                  ),
                ),

                // Summary Section
                pw.Container(
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 3,
                                  child: pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text('Bank Details:',
                                            style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 8)),
                                        pw.SizedBox(height: 2),
                                        pw.Text('Bank Name: HDFC Bank',
                                            style: const pw.TextStyle(
                                                fontSize: 7)),
                                        pw.Text('A/C No: 123456789012',
                                            style: const pw.TextStyle(
                                                fontSize: 7)),
                                        pw.Text('IFSC: HDFC0001234',
                                            style: const pw.TextStyle(
                                                fontSize: 7)),
                                        pw.Text('Branch: Delhi',
                                            style: const pw.TextStyle(
                                                fontSize: 7)),
                                        pw.SizedBox(height: 15),
                                        pw.UrlLink(
                                          destination:
                                              'https://scaffoldingappindia.com/',
                                          child: pw.Text(
                                              'POWERED BY SCAFFOLDING APP INDIA',
                                              style: pw.TextStyle(
                                                  fontSize: 7,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                  color: PdfColors.blue,
                                                  decoration: pw.TextDecoration
                                                      .underline)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                pw.Container(
                                  width: 100,
                                  height: 100,
                                  margin: const pw.EdgeInsets.all(4),
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                          width: 0.5,
                                          color: PdfColors.grey700)),
                                ),
                              ],
                            ),
                            pw.Divider(height: 0.5),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(
                                'Amount in Words: ${_convertNumberToWords(grandTotal)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8,
                                    fontStyle: pw.FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(width: 0.5, color: PdfColors.black),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.black, width: 0.5),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              // Sub Total Row
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    bottom: pw.BorderSide(
                                        color: PdfColors.black, width: 0.5),
                                  ),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('Sub Total',
                                          style:
                                              const pw.TextStyle(fontSize: 9)),
                                    ),
                                    pw.Container(
                                      width: 0.5,
                                      color: PdfColors.black,
                                    ),
                                    pw.Expanded(
                                      child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text(
                                            subtotal.toStringAsFixed(2),
                                            style:
                                                const pw.TextStyle(fontSize: 9),
                                            textAlign: pw.TextAlign.right),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // CGST Row
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    bottom: pw.BorderSide(
                                        color: PdfColors.black, width: 0.5),
                                  ),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('CGST (9%)',
                                          style:
                                              const pw.TextStyle(fontSize: 9)),
                                    ),
                                    pw.Container(
                                      width: 0.5,
                                      color: PdfColors.black,
                                    ),
                                    pw.Expanded(
                                      child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text(
                                            cgstAmount.toStringAsFixed(2),
                                            style:
                                                const pw.TextStyle(fontSize: 9),
                                            textAlign: pw.TextAlign.right),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // SGST Row
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    bottom: pw.BorderSide(
                                      color: PdfColors.black,
                                    ),
                                  ),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('SGST (9%)',
                                          style:
                                              const pw.TextStyle(fontSize: 9)),
                                    ),
                                    pw.Container(
                                      width: 0.5,
                                      color: PdfColors.black,
                                    ),
                                    pw.Expanded(
                                      child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text(
                                            sgstAmount.toStringAsFixed(2),
                                            style:
                                                const pw.TextStyle(fontSize: 9),
                                            textAlign: pw.TextAlign.right),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Grand Total Row
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey300,
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text('Grand Total',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 10)),
                                    ),
                                    pw.Container(
                                      width: 0.5,
                                      color: PdfColors.black,
                                    ),
                                    pw.Expanded(
                                      child: pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8),
                                        child: pw.Text(
                                            grandTotal.toStringAsFixed(2),
                                            style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10),
                                            textAlign: pw.TextAlign.right),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                pw.Container(
                  height: 80,
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text('Terms and Conditions:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                              pw.Text(
                                  '1. All services must be completed as per agreement.',
                                  style: const pw.TextStyle(fontSize: 7)),
                              pw.Text(
                                  '2. Payment terms: Net 30 days from invoice date.',
                                  style: const pw.TextStyle(fontSize: 7)),
                              pw.Text(
                                  '3. Any disputes subject to local jurisdiction.',
                                  style: const pw.TextStyle(fontSize: 7)),
                            ],
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 100,
                        height: 80,
                        decoration:
                            pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Image(
                                pw.MemoryImage(stampBytes.buffer.asUint8List()),
                                height: 55,
                                width: 80,
                                fit: pw.BoxFit.contain),
                            pw.Text(
                              "${bill.date.day}-${bill.date.month}-${bill.date.year.toString().substring(2)} ${DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]}",
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/service_bill_${bill.billNo.replaceAll('-', '_')}.pdf');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      Fluttertoast.showToast(msg: 'PDF Generated Successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error generating PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          bill.billNo,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateServiceBillPdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bill.isPerforma
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: bill.isPerforma
                      ? Colors.orange.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.isPerforma
                                ? 'PERFORMA INVOICE'
                                : 'TAX INVOICE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: bill.isPerforma
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bill.billNo,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${bill.date.day}/${bill.date.month}/${bill.date.year}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.receipt_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Created by: ${bill.creationType == 'date' ? 'Date Range' : 'Slip Selection'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Slips Section
            const Text(
              'Slip Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Display all slips
            ...bill.slips.map((slip) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Slip Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Slip #${slip.slipNo}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                'Staff: ${slip.totalStaff}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${slip.date.day}/${slip.date.month}/${slip.date.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        // Slip Details
                        ...slip.details.map((detail) {
                          final isTotal =
                              detail.title.toLowerCase().contains('total');
                          return isTotal
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          detail.title,
                                          style: TextStyle(
                                            fontSize: isTotal ? 14 : 13,
                                            fontWeight: isTotal
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          detail.value,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          detail.issueCount.isNotEmpty
                                              ? '₹ ${detail.issueCount}'
                                              : '',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: isTotal ? 14 : 13,
                                            fontWeight: isTotal
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isTotal
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container();
                        }),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            // Grand Total Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grand Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '₹ ${bill.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
