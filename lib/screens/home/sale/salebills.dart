import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

// ============= MODELS =============
class InvoiceItem {
  final String itemName;
  final int qty;
  final String unit;
  final double rate;
  final double value;
  final String hsnCode;

  InvoiceItem({
    required this.itemName,
    required this.qty,
    required this.unit,
    required this.rate,
    required this.value,
    required this.hsnCode,
  });
}

class Invoice {
  final String invoiceNo;
  final String gatePassNo;
  final DateTime date;
  final List<InvoiceItem> items;
  final String gstType;
  final double taxableValue;
  final double gstAmount;
  final double grandTotal;
  String? eWayBillNo;

  Invoice({
    required this.invoiceNo,
    required this.gatePassNo,
    required this.date,
    required this.items,
    required this.gstType,
    required this.taxableValue,
    required this.gstAmount,
    required this.grandTotal,
    this.eWayBillNo,
  });
}

// ============= MAIN INVOICE SCREEN =============
class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({super.key});

  @override
  State<InvoiceManagementScreen> createState() =>
      _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy Data
  List<Invoice> performaInvoices = [];
  List<Invoice> taxInvoices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDummyData();
  }

  void _loadDummyData() {
    // Generate dummy Performa Invoices
    performaInvoices = List.generate(5, (index) {
      final random = Random();
      final items = List.generate(
          random.nextInt(3) + 2,
          (i) => InvoiceItem(
                itemName: 'Standar ${random.nextBool() ? '1.0m' : '1.5m'}',
                qty: random.nextInt(50) + 10,
                unit: random.nextBool() ? 'Pcs' : 'Kgs',
                rate: (random.nextDouble() * 100) + 150,
                value: 0,
                hsnCode: '${7300 + random.nextInt(100)}',
              ));

      final taxableValue =
          items.fold(0.0, (sum, item) => sum + (item.qty * item.rate));
      final gstAmount = taxableValue * 0.18;

      return Invoice(
        invoiceNo: 'PI-${2025}${(index + 1).toString().padLeft(4, '0')}',
        gatePassNo: 'GP-${(index + 1).toString().padLeft(3, '0')}',
        date: DateTime.now().subtract(Duration(days: index)),
        items: items,
        gstType: random.nextBool() ? 'IGST (18%)' : 'CGST+SGST (9%+9%)',
        taxableValue: taxableValue,
        gstAmount: gstAmount,
        grandTotal: taxableValue + gstAmount,
      );
    });

    // Generate dummy Tax Invoices
    taxInvoices = List.generate(3, (index) {
      final random = Random();
      final items = List.generate(
          random.nextInt(3) + 2,
          (i) => InvoiceItem(
                itemName: 'Standar ${random.nextBool() ? '1.0m' : '1.5m'}',
                qty: random.nextInt(50) + 10,
                unit: random.nextBool() ? 'Pcs' : 'Kgs',
                rate: (random.nextDouble() * 100) + 150,
                value: 0,
                hsnCode: '${7300 + random.nextInt(100)}',
              ));

      final taxableValue =
          items.fold(0.0, (sum, item) => sum + (item.qty * item.rate));
      final gstAmount = taxableValue * 0.18;

      return Invoice(
        invoiceNo: 'TI-${2025}${(index + 1).toString().padLeft(4, '0')}',
        gatePassNo: 'GP-${(index + 1).toString().padLeft(3, '0')}',
        date: DateTime.now().subtract(Duration(days: index)),
        items: items,
        gstType: random.nextBool() ? 'IGST (18%)' : 'CGST+SGST (9%+9%)',
        taxableValue: taxableValue,
        gstAmount: gstAmount,
        grandTotal: taxableValue + gstAmount,
        eWayBillNo: random.nextBool()
            ? 'EWB${random.nextInt(900000000) + 100000000}'
            : null,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _transferToTaxInvoice(Invoice performaInvoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer to Tax Invoice'),
        content: Text(
            'Transfer ${performaInvoice.invoiceNo} to Tax Invoice?\n\nThis will create a new Tax Invoice with the same details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newInvoiceNo =
                    'TI-${DateTime.now().year}${(taxInvoices.length + 1).toString().padLeft(4, '0')}';
                final newTaxInvoice = Invoice(
                  invoiceNo: newInvoiceNo,
                  gatePassNo: performaInvoice.gatePassNo,
                  date: DateTime.now(),
                  items: performaInvoice.items,
                  gstType: performaInvoice.gstType,
                  taxableValue: performaInvoice.taxableValue,
                  gstAmount: performaInvoice.gstAmount,
                  grandTotal: performaInvoice.grandTotal,
                );
                taxInvoices.insert(0, newTaxInvoice);
                performaInvoices.remove(performaInvoice);
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

  void _addEWayBill(Invoice taxInvoice) {
    final TextEditingController eWayBillController = TextEditingController();
    if (taxInvoice.eWayBillNo != null) {
      eWayBillController.text = taxInvoice.eWayBillNo!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add E-Way Bill Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bill No: ${taxInvoice.invoiceNo}',
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
                taxInvoice.eWayBillNo = eWayBillController.text;
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

  void _showInvoiceDetails(Invoice invoice, bool isPerforma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(
          invoice: invoice,
          isPerforma: isPerforma,
          onAddEWayBill: !isPerforma ? () => _addEWayBill(invoice) : null,
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
        title: const Text("Invoices", style: TextStyle(color: Colors.white)),
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
          _buildInvoiceList(performaInvoices, true),
          _buildInvoiceList(taxInvoices, false),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices, bool isPerforma) {
    if (invoices.isEmpty) {
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
                  : 'Transfer from Performa Invoice',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 1,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showInvoiceDetails(invoice, isPerforma),
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
                              invoice.invoiceNo,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'GP: ${invoice.gatePassNo}',
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
                          'Items',
                          '${invoice.items.length}',
                          Icons.inventory_2_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'GST',
                          invoice.gstType.contains('IGST')
                              ? 'IGST'
                              : 'CGST+SGST',
                          Icons.account_balance_outlined,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Total',
                          ' ${invoice.grandTotal.toStringAsFixed(0)}',
                          Icons.currency_rupee,
                        ),
                      ),
                    ],
                  ),
                  if (!isPerforma && invoice.eWayBillNo != null) ...[
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
                            'E-Way: ${invoice.eWayBillNo}',
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
                            onPressed: () => _transferToTaxInvoice(invoice),
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
                      else ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _addEWayBill(invoice),
                            icon: const Icon(Icons.receipt_long, size: 18),
                            label: Text(invoice.eWayBillNo == null
                                ? 'Add E-Way Bill'
                                : 'Update E-Way Bill'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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

// ============= INVOICE DETAIL SCREEN =============
class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;
  final bool isPerforma;
  final VoidCallback? onAddEWayBill;

  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    required this.isPerforma,
    this.onAddEWayBill,
  });

  // Helper function to convert number to words
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

  Future<void> _generateInvoicePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final logoBytes = await rootBundle.load('images/logo.png');
      final nameBytes = await rootBundle.load('images/name.png');
      final stampBytes = await rootBundle.load('images/stamp.jpeg');

      final linkStyle = pw.TextStyle(
        color: PdfColors.blue,
        decoration: pw.TextDecoration.underline,
      );

      // Prepare table data with conditional columns
      final List<List<dynamic>> tableData = [];

      // Add default "Scaffolding Material" row with all columns
      tableData.add([
        {'text': '-', 'colspan': 1},
        {'text': 'Scaffolding Material', 'colspan': 1},
        {'text': '85', 'colspan': 1},
        {'text': 'KGs', 'colspan': 1},
        {'text': '7342', 'colspan': 1},
        {'text': '455', 'colspan': 1},
        {'text': '19070', 'colspan': 1},
      ]);

      // Add invoice items - sirf name ke saath, no other columns
      for (int i = 0; i < invoice.items.length; i++) {
        final item = invoice.items[i];
        tableData.add([
          {'text': '${i + 1}', 'colspan': 1},
          {
            'text': '${item.itemName} ${item.qty}',
            'colspan': 6
          }, // Colspan 6 to merge remaining columns
        ]);
      }
      final table = pw.Table(
        border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
        columnWidths: {
          0: const pw.FixedColumnWidth(25),
          1: const pw.FlexColumnWidth(3),
          2: const pw.FixedColumnWidth(35),
          3: const pw.FixedColumnWidth(35),
          4: const pw.FixedColumnWidth(50),
          5: const pw.FixedColumnWidth(40),
          6: const pw.FixedColumnWidth(50),
        },
        children: [
          // Header Row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              'Sr\nNo',
              'Item Name',
              'Qty',
              'Unit',
              'HSN Code',
              'Rate',
              'Amount'
            ]
                .map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.all(3),
                      child: pw.Text(
                        h,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8),
                        textAlign: pw.TextAlign.center,
                      ),
                    ))
                .toList(),
          ),
          // Data Rows
          ...tableData.map((row) {
            return pw.TableRow(
              children: row
                  .map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(
                          cell['text'],
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ))
                  .toList(),
            );
          }).toList(),
        ],
      );
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(15), // Reduced from 20
          build: (pw.Context context) {
            final pageWidth = context.page.pageFormat.width - 30;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Compact Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(pw.MemoryImage(logoBytes.buffer.asUint8List()),
                        width: 90,
                        height: 90,
                        fit: pw.BoxFit.fill), // Reduced size
                    pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(nameBytes.buffer.asUint8List()),
                            width: 240,
                            height: 75,
                            fit: pw.BoxFit.fill), // Reduced size
                        pw.Text('(A/N ISO 9001:2015 Certified Company)',
                            style: const pw.TextStyle(
                                fontSize: 9)), // Smaller font
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          isPerforma ? 'PERFORMA INVOICE' : 'TAX INVOICE',
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 8), // Reduced spacing
                        pw.Text('Invoice No: ${invoice.invoiceNo}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Date: ${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text('Gate Pass: ${invoice.gatePassNo}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 5), // Reduced spacing

                // Compact Address
                pw.Container(
                  width: pageWidth,
                  padding: const pw.EdgeInsets.all(4),
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.RichText(
                    textAlign: pw.TextAlign.center,
                    text: pw.TextSpan(
                      style: const pw.TextStyle(fontSize: 8), // Smaller font
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

                // Compact Bill To / Ship To
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

                // Custom Items Table with conditional columns and bordered whitespace
                pw.Container(
                  height: 400,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1, color: PdfColors.black),
                  ),
                  child: pw.Stack(
                    children: [
                      // Background full-height column overlays
                      pw.Positioned(
                        // width: 2/5, // Sr No column width
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              right: pw.BorderSide(
                                  width: 0.5, color: PdfColors.black),
                            ),
                          ),
                        ),
                      ),
                      pw.Positioned(
                        // width: 50, // Amount column width
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              left: pw.BorderSide(
                                  width: 0.5, color: PdfColors.black),
                            ),
                          ),
                        ),
                      ),
                      // The table itself
                      pw.Positioned.fill(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 0, right: 0),
                          child: table,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Compact Summary Section
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
                                'Amount in Words: ${_convertNumberToWords(invoice.grandTotal)}',
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
                        child: pw.Table(
                          border: pw.TableBorder(
                            verticalInside: const pw.BorderSide(width: 0.5),
                            horizontalInside: const pw.BorderSide(width: 0.5),
                          ),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(2),
                            1: const pw.FlexColumnWidth(2),
                          },
                          children: [
                            pw.TableRow(children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('Taxable Value',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8))),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                      '${invoice.taxableValue.toStringAsFixed(2)}',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8))),
                            ]),
                            if (invoice.gstType.contains("CGST+SGST")) ...[
                              pw.TableRow(children: [
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('CGST 9%',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 8))),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                        '${(invoice.gstAmount / 2).toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 8))),
                              ]),
                              pw.TableRow(children: [
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text('SGST 9%',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 8))),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                        '${(invoice.gstAmount / 2).toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 8))),
                              ]),
                            ] else ...[
                              pw.TableRow(children: [
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                        '${invoice.gstType} (${invoice.gstAmount.toStringAsFixed(1)}%)',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 8))),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                        '${invoice.gstAmount.toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 8))),
                              ]),
                            ],
                            pw.TableRow(children: [
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text('Round Off',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8))),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                      '${(invoice.grandTotal.roundToDouble() - invoice.grandTotal).toStringAsFixed(2)}',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8))),
                            ]),
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey200),
                              children: [
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text('Grand Total',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10))),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.all(6),
                                    child: pw.Text(
                                        '${invoice.grandTotal.roundToDouble().toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold,
                                            fontSize: 10))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isPerforma && invoice.eWayBillNo != null) ...[
                  pw.SizedBox(height: 5),
                  pw.Container(
                    child: pw.Table(
                      border: pw.TableBorder.all(width: 0.5),
                      children: [
                        pw.TableRow(
                          children: [
                            'E-way Bill No',
                            'Vehicle Number',
                            'Driver Name',
                            'Driver Mobile',
                            'Driving License'
                          ]
                              .map((h) => pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(h,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8),
                                      textAlign: pw.TextAlign.center)))
                              .toList(),
                        ),
                        pw.TableRow(
                          children: [
                            pw.Text('0222',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.Text('DL01LAD1234',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.Text('Mayank',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.UrlLink(
                                destination: 'tel:9354953434',
                                child: pw.Text('9354953434',
                                    style: linkStyle.copyWith(fontSize: 8))),
                            pw.Text('UP-752980914201',
                                style: const pw.TextStyle(fontSize: 8)),
                          ]
                              .map((c) => pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Align(
                                      alignment: pw.Alignment.center,
                                      child: c)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                // Compact Footer
                pw.Container(
                  height: 80, // Reduced height
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
                                  '1. All equipment must be in good condition upon delivery.',
                                  style: const pw.TextStyle(fontSize: 7)),
                              pw.Text(
                                  '2. Elatio By Gards LLP is responsible for repairing any damage.',
                                  style: const pw.TextStyle(fontSize: 7)),
                              pw.Text(
                                  '3. The security deposit will be refunded upon the return of the.',
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
                              "${invoice.date.day}-${invoice.date.month}-${invoice.date.year.toString().substring(2)} ${DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]}",
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
      final file = File('${output.path}/invoice_${invoice.invoiceNo}.pdf');
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
          invoice.invoiceNo,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateInvoicePdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isPerforma ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPerforma
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
                            isPerforma ? 'PERFORMA INVOICE' : 'TAX INVOICE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPerforma ? Colors.orange : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoice.invoiceNo,
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
                            '${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
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
                      Icon(Icons.badge_outlined,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Gate Pass: ${invoice.gatePassNo}',
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

            // Items Section
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Items Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text('Item',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 1,
                      child: Text('Qty',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1,
                      child: Text('Rate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right)),
                  Expanded(
                      flex: 1,
                      child: Text('Value',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right)),
                ],
              ),
            ),

            // Items List
            ...invoice.items.map((item) => Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.itemName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text('HSN: ${item.hsnCode}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('${item.qty} ${item.unit}',
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(' ${item.rate.toStringAsFixed(0)}',
                                textAlign: TextAlign.right),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                                ' ${(item.qty * item.rate).toStringAsFixed(0)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 24),

            // Calculation Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  _buildCalculationRow('Taxable Value', invoice.taxableValue),
                  const SizedBox(height: 8),
                  _buildCalculationRow(invoice.gstType, invoice.gstAmount),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        ' ${invoice.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!isPerforma && invoice.eWayBillNo != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-Way Bill Number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            invoice.eWayBillNo!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onAddEWayBill,
                      icon: const Icon(Icons.edit),
                      color: Colors.green.shade700,
                    ),
                  ],
                ),
              ),
            ],

            if (!isPerforma && invoice.eWayBillNo == null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddEWayBill,
                  icon: const Icon(Icons.add),
                  label: const Text('Add E-Way Bill Number'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          ' ${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
