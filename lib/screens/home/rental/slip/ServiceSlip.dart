import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:scaffolding_sale/main.dart';
import 'package:scaffolding_sale/screens/home/rental/delivery.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/return.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/outward.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip_notes.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'package:scaffolding_sale/screens/pdf.dart';

// Data model to pass unique data to each slip card
class SlipData {
  final DateTime date;
  final String slipNo;
  final String totalStaff;
  final List<SlipDetailData> details;

  SlipData(
      {required this.date,
      required this.slipNo,
      required this.totalStaff,
      required this.details});
}

class SlipDetailData {
  final String title;
  final String value;
  final String issueCount;

  SlipDetailData(
      {required this.title, required this.value, required this.issueCount});
}

// Hardcoded data for three slips
final List<SlipData> slipList = [
  SlipData(
    date: DateTime(2025, 11, 12),
    slipNo: '01',
    totalStaff: '01',
    details: [
      SlipDetailData(
          title: 'Scaffolding Fixing\n100*80*2',
          value: '₹ 20',
          issueCount: '320000'),
      SlipDetailData(
          title: 'Scaffolding Closing\n10+2*10+2*2',
          value: '₹ 20',
          issueCount: '2080'),
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
          issueCount: '5000'),
      SlipDetailData(
          title: 'Scaffolding Fixing\n10*10*1',
          value: '₹ 10',
          issueCount: '1000'),
      SlipDetailData(
          title: 'Scaffolding Fixing', value: '₹ 500', issueCount: '500'),
      SlipDetailData(title: 'Total', value: '  ', issueCount: '6500'),
    ],
  ),
  SlipData(
    date: DateTime(2025, 11, 14),
    slipNo: '03',
    totalStaff: '03',
    details: [
      SlipDetailData(
          title: 'Scaffolding Fixing\n100*1', value: '₹ 5', issueCount: '100'),
      SlipDetailData(
          title: 'Scaffolding Fixing', value: '₹ 200', issueCount: '200'),
      SlipDetailData(title: 'Total', value: '  ', issueCount: '300'),
    ],
  ),
];

class Serviceslip extends StatefulWidget {
  const Serviceslip({super.key});

  @override
  _ServiceslipState createState() => _ServiceslipState();
}

class _ServiceslipState extends State<Serviceslip>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'All Slip',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar and buttons in a row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                // PopupMenuButton(
                //   icon: const Icon(Icons.more_vert),
                //   itemBuilder: (context) => const [
                //     // PopupMenuItem(
                //     //   child: Text("Delivery Items"),
                //     // ),
                //     // PopupMenuItem(
                //     //   child: Text("Receive Items"),
                //     // ),
                //     PopupMenuItem(
                //       child: Text("Submit Balance A"),
                //     ),
                //     PopupMenuItem(
                //       child: Text("View all notes"),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'UnBilled'),
              Tab(text: 'Billed'),
              Tab(text: 'Payment'),
            ],
            labelColor: Colors.teal,
            indicatorColor: Colors.teal,
          ),

          // Divider
          const Divider(),

          // Address and Other Information
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MH Shuttering & Scaffolding. KHATA NO-199 GRAM SARFABAD, SECTOR 73 Noida GAUTAM BUDH NAGAR, UTTAR PRADESH- 201307',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // List of Items
          Expanded(
            child: ListView.builder(
              itemCount: slipList.length, // Use the count of your data list
              itemBuilder: (context, index) {
                // Pass the unique data for each slip to the SlipCard
                return SlipCard(slipData: slipList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SlipCard extends StatefulWidget {
  final SlipData slipData; // Added to receive unique data
  const SlipCard({super.key, required this.slipData});

  @override
  State<SlipCard> createState() => _SlipCardState();
}

class _SlipCardState extends State<SlipCard> {
  // Use a local variable initialized from widget.slipData.date
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.slipData.date;
  }

  void _onPopupMenuSelected(BuildContext context, String value) {
    // ... (unchanged logic for menu selection)
    switch (value) {
      case 'Delete':
        // Handle Delete
        break;
      case 'Cancel':
        // Handle Cancel
        break;
      case 'Outward challan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Delivery();
            },
          ),
        );
        break;
      case 'Inward challan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Return();
            },
          ),
        );
        break;
      case 'E-way/ vehicle/ Edit date No':
        // Assuming this is handled by Navigator.pushNamed
        // Navigator.pushNamed(context, '/eway-vehicle');
        break;
      case 'Add Note':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Notes();
            },
          ),
        );
        break;
      case 'View slip notes':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const SlipNotes();
            },
          ),
        );
        break;
      case 'Site Pic':
        // Assuming this is handled by Navigator.pushNamed
        // Navigator.pushNamed(context, '/site-pic');
        break;
      case 'Other Charges':
        showAddChargesDialog(context);
        break;
      case 'Site current location':
        // Assuming this is handled by Navigator.pushNamed
        // Navigator.pushNamed(context, '/site-current-location');
        break;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthName(date.month)} "
        "${date.year}";
  }

  String _monthName(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 290, // Note: This width constraint might be too specific
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
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
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          // Using dynamic date and slip number
                          "${_formatDate(selectedDate)}\nSLIP No: ${widget.slipData.slipNo}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        // Using dynamic total staff
                        'Total Staff: ${widget.slipData.totalStaff}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.white),
                      onPressed: () {
                        generatePdfa(context,
                            isCancelled: false, withStamp: false);
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.red),
                      onSelected: (value) =>
                          _onPopupMenuSelected(context, value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'Delete',
                            child: Text("Delete",
                                style: TextStyle(color: Colors.red))),
                        PopupMenuItem(
                          value: 'Other Charges',
                          child: Text("Add Other Charges"),
                        ),
                        PopupMenuItem(
                            value: 'Add Note', child: Text("Add Note")),
                        PopupMenuItem(
                            value: 'View slip notes',
                            child: Text("View slip notes")),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Dynamically create SlipDetailRow widgets based on data
              ...widget.slipData.details.map((detail) {
                return Column(
                  children: [
                    SlipDetailRow(
                      title: detail.title,
                      value: detail.value,
                      issueCount: detail.issueCount,
                      iconColor: Colors.red, // Keep static color for now
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
              // Remove the last divider if you don't want it after the final element
              if (widget.slipData.details.isNotEmpty)
                const SizedBox(
                    height:
                        0), // Placeholder to remove the final Divider from the loop
            ],
          ),
        ),
      ),
    );
  }
}

class SlipDetailRow extends StatefulWidget {
  final String title;
  final String value;
  final String issueCount;
  final Color iconColor;

  const SlipDetailRow({
    required this.title,
    required this.value,
    required this.issueCount,
    required this.iconColor,
    super.key,
  });

  @override
  State<SlipDetailRow> createState() => _SlipDetailRowState();
}

class _SlipDetailRowState extends State<SlipDetailRow> {
  late String title;
  late String value;
  late String issueCount;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    value = widget.value;
    issueCount = widget.issueCount;
  }

  void _openEditDialog() {
    TextEditingController tCtrl = TextEditingController(text: title);
    TextEditingController vCtrl = TextEditingController(text: value);
    TextEditingController lCtrl = TextEditingController(text: ("100"));
    TextEditingController hCtrl = TextEditingController(text: ("100"));
    TextEditingController wCtrl = TextEditingController(text: ("2"));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: vCtrl,
              decoration: const InputDecoration(labelText: "Rate"),
              keyboardType: TextInputType.number,
            ),
            title == "Material"
                ? Container()
                : TextField(
                    controller: lCtrl,
                    decoration: const InputDecoration(labelText: "Length"),
                    keyboardType: TextInputType.number,
                  ),
            title == "Material"
                ? Container()
                : TextField(
                    controller: wCtrl,
                    decoration: const InputDecoration(labelText: "Height"),
                    keyboardType: TextInputType.number,
                  ),
            title == "Material"
                ? Container()
                : TextField(
                    controller: hCtrl,
                    decoration: const InputDecoration(labelText: "Width"),
                    keyboardType: TextInputType.number,
                  ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                title = tCtrl.text.trim();
                value = vCtrl.text.trim();
                // issueCount = iCtrl.text.trim();
              });

              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  void _openEditDialog2() {
    TextEditingController tCtrl = TextEditingController(text: title);
    TextEditingController vCtrl = TextEditingController(text: value);

    TextEditingController lCtrl = TextEditingController(text: "10");
    TextEditingController l2Ctrl = TextEditingController(text: "2");

    TextEditingController hCtrl = TextEditingController(text: "10");
    TextEditingController h2Ctrl = TextEditingController(text: "2");

    TextEditingController wCtrl = TextEditingController(text: "2");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rate
            TextField(
              controller: vCtrl,
              decoration: const InputDecoration(labelText: "Rate"),
              keyboardType: TextInputType.number,
            ),

            // Length row
            if (title != "Material") ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: lCtrl,
                      decoration: const InputDecoration(labelText: "Length"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: l2Ctrl,
                      decoration: const InputDecoration(labelText: "Length 2"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],

            // Height row
            if (title != "Material") ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hCtrl,
                      decoration: const InputDecoration(labelText: "Height"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: h2Ctrl,
                      decoration: const InputDecoration(labelText: "Height 2"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],

            // Width single field
            if (title != "Material") ...[
              const SizedBox(height: 10),
              TextField(
                controller: wCtrl,
                decoration: const InputDecoration(labelText: "Width"),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                title = tCtrl.text.trim();
                value = vCtrl.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  void _onMenu(String v, String title) {
    if (v == "Edit") {
      if (title.contains("Closing")) {
        _openEditDialog2();
      } else {
        _openEditDialog();
      }
    } else if (v == "Delete") {
      // static delete action
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // icon
          SizedBox(
            width: 20,
            child: Icon(Icons.circle, color: widget.iconColor, size: 12),
          ),

          // Title (left aligned, fixed flex)
          Expanded(
            flex: 3,
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Value (center, fixed space)
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.center,
            ),
          ),

          // Issue Count (center, fixed space)
          Expanded(
            flex: 2,
            child: Text(
              issueCount,
              textAlign: TextAlign.center,
            ),
          ),

          // Menu Button (right side, fixed space)
          SizedBox(
            width: 40,
            child: title == "Total"
                ? const SizedBox()
                : PopupMenuButton(
                    onSelected: (value) {
                      _onMenu(value, title);
                    },
                    itemBuilder: (c) => const [
                      PopupMenuItem(value: "Edit", child: Text("Edit")),
                      PopupMenuItem(value: "Delete", child: Text("Delete")),
                    ],
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
          ),
        ],
      ),
    );
  }
}

final itemsData = [
  [
    'Scaffolding Fixing (100*100*2)',
    (100 * 100 * 2).toString(),
    '20',
    '400000',
  ],
];

void generatePdfa(BuildContext contextM,
    {required bool withStamp, required bool isCancelled}) async {
  final pdf = pw.Document();
  final appLogo = await rootBundle.load('images/logo.png');
  final logoBytes = await rootBundle.load('images/file.png');
  final nameBytes = await rootBundle.load('images/name.png');
  final stampBytes = await rootBundle.load('images/stamp.jpeg');

  final List<List<String>> tableData = [];
  for (int i = 0; i < itemsData.length; i++) {
    tableData.add(['${i + 1}', ...itemsData[i]]);
  }

  tableData.add(
    [
      "",
      'Scaffolding Closing (10+2*10+2*2)',
      "104",
      '20',
      '2080',
    ],
  );
  tableData.add([
    '',
    'Mayank Bajaj,',
    '',
    '',
    '',
  ]);

  tableData.add(
    [
      "",
      'Material',
      ""
          '',
      '',
      "100"
    ],
  );

  tableData.add(
    [
      '',
      'Total',
      '',
      '',
      '322180',
    ],
  );

  // --- Clickable Phone Number Style ---
  final linkStyle = pw.TextStyle(
    color: PdfColors.blue,
    decoration: pw.TextDecoration.underline,
  );

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        final pageWidth =
            context.page.pageFormat.width - 40; // Total width minus margins

        return pw.Stack(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(pw.MemoryImage(logoBytes.buffer.asUint8List()),
                        width: 120, height: 120, fit: pw.BoxFit.fill),
                    pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(nameBytes.buffer.asUint8List()),
                            width: 300, height: 100, fit: pw.BoxFit.fill),
                        pw.Text('(A/N ISO 9001:2015 Certified Company)',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 8),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('SERVICE SLIP', style: const pw.TextStyle()),
                        pw.SizedBox(height: 30),
                        pw.Text('SLIP No: 1',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Date: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'HSN CODE:776546',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),

                // --- MODIFICATION 1: CLICKABLE PHONE NUMBERS IN HEADER ADDRESS ---
                pw.Container(
                  width: pageWidth,
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.RichText(
                    textAlign: pw.TextAlign.center,
                    text: pw.TextSpan(
                      children: [
                        const pw.TextSpan(
                            text:
                                'PLOT NO-23 KHASRA NO 14/1 RANI LAXMI BAI NAGAR, DUNDA HERA, GHAZIABAD (U.P) - 201001 MOBILE NO: '),
                        pw.TextSpan(
                          text: '9871227048',
                          style: linkStyle,
                          annotation: pw.AnnotationUrl('tel:9871227048'),
                        ),
                        const pw.TextSpan(text: ', '),
                        pw.TextSpan(
                          text: '9213449692',
                          style: linkStyle,
                          annotation: pw.AnnotationUrl('tel:9213449692'),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column - Bill To
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Bill To: UP02/01/01',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('M/S: Elatio By Gards LLP'),
                            pw.Text(
                                'Billing Add: PLOT NO.120 KHASRA NO 372M, HAIBATPUR, VILLAGE HAIBATPUR, Noida, Gautambuddha Nagar, Uttar Pradesh, 201301'),
                            pw.Text('GST NO: 09DFSPG6487R1Z2'),
                            pw.RichText(
                              text: pw.TextSpan(
                                children: [
                                  const pw.TextSpan(text: 'Phone: '),
                                  pw.TextSpan(
                                    text: '9876543210',
                                    style: linkStyle,
                                    annotation:
                                        pw.AnnotationUrl('tel:9876543210'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical Divider
                      pw.Container(
                        width: 1,
                        margin: const pw.EdgeInsets.symmetric(horizontal: 10),
                        color: PdfColors.grey,
                        height: 100, // adjust height as per your layout
                      ),

                      // Right Column - Ship To
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Ship To:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                                'Delivery Address: PLOT NO.120 KHASRA NO 372M, HAIBATPUR, VILLAGE HAIBATPUR, Noida, Gautambuddha Nagar, Uttar Pradesh, 201301'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Main items table
                pw.Table.fromTextArray(
                  headers: [
                    'Sr\nNo',
                    'Item Name',
                    'Area',
                    'Rate',
                    'Amount',
                  ],
                  data: tableData,
                  border: pw.TableBorder.all(width: 0.5),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.center,
                ),
                pw.SizedBox(height: 10),

                // --- MODIFICATION 3: DRIVER DETAILS TABLE WITH CLICKABLE PHONE ---
                // pw.Table(
                //   border: pw.TableBorder.all(width: 0.5),
                //   // cellAlignment: pw.Alignment.center,
                //   // cellStyle: const pw.TextStyle(fontSize: 10),
                //   children: [
                //     pw.TableRow(
                //       children: [
                //         'E-way Bill No',
                //         'Vehicle Number',
                //         'Driver Name',
                //         'Driver Mobile',
                //         'Driving License'
                //       ]
                //           .map((header) => pw.Container(
                //                 padding: const pw.EdgeInsets.all(4),
                //                 child: pw.Text(header,
                //                     style: pw.TextStyle(
                //                         fontWeight: pw.FontWeight.bold),
                //                     textAlign: pw.TextAlign.center),
                //               ))
                //           .toList(),
                //     ),
                //     pw.TableRow(
                //       children: [
                //         pw.Text('0222'),
                //         pw.Text('DL01LAD1234'),
                //         pw.Text('Mayank'),
                //         pw.UrlLink(
                //           destination: 'tel:9354953434',
                //           child: pw.Text('9354953434', style: linkStyle),
                //         ),
                //         pw.Text('UP-752980914201'),
                //       ]
                //           .map((cell) => pw.Container(
                //                 padding: const pw.EdgeInsets.all(4),
                //                 alignment: pw.Alignment.center,
                //                 child: cell,
                //               ))
                //           .toList(),
                //     ),
                //   ],
                // ),
                pw.SizedBox(height: 20),

                pw.Container(
                  height: 120,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(10),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Image(
                                pw.MemoryImage(appLogo.buffer.asUint8List()),
                                width: 80),
                            pw.SizedBox(width: 5),
                            // --- MODIFICATION 4: CLICKABLE 'POWERED BY' TEXT ---
                            pw.UrlLink(
                              destination:
                                  'https://scaffoldingappindia.com/', // Change to your app's link
                              child: pw.Text(
                                'POWERED BY SCAFFOLDING APP INDIA',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue,
                                  decoration: pw.TextDecoration.underline,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Spacer(),
                      pw.Container(
                        width: 120,
                        height: 120,
                        decoration:
                            pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                        child: pw.Center(child: pw.Text("Customer Sign")),
                      ),
                      pw.Container(
                        width: 120,
                        height: 120,
                        decoration:
                            pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Image(
                                pw.MemoryImage(stampBytes.buffer.asUint8List()),
                                height: 80,
                                width: 100,
                                fit: pw.BoxFit.contain),
                            pw.Text(
                              "01-07-25 " +
                                  DateTime.now()
                                      .toLocal()
                                      .toString()
                                      .split(' ')[1]
                                      .split('.')[0],
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Terms and Conditions:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    '1. All equipment must be in good condition upon delivery.'),
                pw.Text(
                    '2. Elatio By Gards LLP is responsible for repairing any damage.'),
                pw.Text(
                    '3. The security deposit will be refunded upon the return of the equipment in satisfactory condition.'),
              ],
            ),
            if (isCancelled)
              pw.Center(
                child: pw.Transform.rotate(
                  angle: -math.pi / 4, // Rotates the text by -45 degrees
                  child: pw.Text(
                    'CANCELLED',
                    style: pw.TextStyle(
                      fontSize: 100,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor(1, 0, 0, 0.3),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/challan.pdf');
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);
}

void showAddChargesDialog(BuildContext context) {
  final TextEditingController chargesTypeController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add Other Charges"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chargesTypeController,
              decoration: InputDecoration(
                labelText: 'Charges Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without action
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Retrieve input values if needed
              String chargesType = chargesTypeController.text;
              String amount = amountController.text;

              // Add your logic here to handle the entered data

              Navigator.of(context)
                  .pop(); // Close the dialog after handling data
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
