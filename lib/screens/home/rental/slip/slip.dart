// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math; // <-- MODIFICATION 1: ADD THIS IMPORT
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/rental/delivery.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip_notes.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
// import 'package:geolocator/geolocator.dart';

// class SiteCurrentLocationPage extends StatefulWidget {
//   const SiteCurrentLocationPage({Key? key}) : super(key: key);

//   @override
//   State<SiteCurrentLocationPage> createState() =>
//       _SiteCurrentLocationPageState();
// }

// class _SiteCurrentLocationPageState extends State<SiteCurrentLocationPage> {
//   Position? _currentPosition;
//   String? _errorMessage;
//   bool _isLoading = false;

//   // लोकेशन प्राप्त करने के लिए मुख्य फ़ंक्शन
//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // 1. अनुमति (Permission) की जाँच करें
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw Exception(
//             'Location permissions are permanently denied, we cannot request permissions.');
//       }

//       // 2. वर्तमान पोजीशन प्राप्त करें
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       setState(() {
//         _currentPosition = position;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Site Current Location'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               if (_isLoading) CircularProgressIndicator(),
//               if (_currentPosition == null && !_isLoading)
//                 Text(
//                   'Press the button to get your current location.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18),
//                 ),
//               if (_currentPosition != null)
//                 Text(
//                   'Latitude: ${_currentPosition!.latitude}\nLongitude: ${_currentPosition!.longitude}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               SizedBox(height: 20),
//               if (_errorMessage != null)
//                 Text(
//                   'Error: $_errorMessage',
//                   style: TextStyle(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//               SizedBox(height: 30),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.my_location),
//                 label: Text('Get Current Location'),
//                 onPressed: _isLoading ? null : _getCurrentLocation,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class Slip extends StatefulWidget {
  const Slip({super.key});

  @override
  _SlipState createState() => _SlipState();
}

class _SlipState extends State<Slip> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  int itemCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'All Vouchers',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  // const SizedBox(width: 8.0),
                  // IconButton(
                  //   icon: const Icon(Icons.picture_as_pdf),
                  //   onPressed: () {
                  //     launchUrlString(
                  //         "https://batbarter.anklegaming.live/AdminPanel/2.pdf");
                  //   },
                  // ),
                  // IconButton(
                  //     icon: const Icon(Icons.print),
                  //     onPressed: () async {
                  //       final Uri pdfUri =
                  //           Uri.parse("https://moneyheist.live/invoice.pdf");

                  //       // Fetch the PDF as bytes
                  //       try {
                  //         final pdfBytes = await NetworkAssetBundle(pdfUri)
                  //             .load(pdfUri.toString());
                  //         final pdfData = pdfBytes.buffer.asUint8List();

                  //         // Use the printing package to open the print dialog
                  //         await Printing.layoutPdf(
                  //           onLayout: (format) async => pdfData,
                  //         );
                  //       } catch (e) {
                  //         print("Error fetching or printing PDF: $e");
                  //       }
                  //     }),
                ],
              ),
            ),

            TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Vouchers'),
                Tab(text: 'Outward'),
                Tab(text: 'Inward'),
                Tab(text: 'Balance Item'),
                Tab(text: 'Payment'),
                Tab(text: 'Service Slip'),
              ],
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: const TextStyle(),
              labelColor: Colors.teal,
              indicatorColor: Colors.teal,
            ),

            // Divider
            const Divider(),

            // Address and Other Information
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PLOT NO.120 KHASRA NO 372M, HAIBATPUR, VILLAGE HAIBATPUR, Noida, Gautambuddha Nagar, Uttar Pradesh, 201301',
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
            SizedBox(
              // height: 4000,
              // width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return index == 2
                      ? PaymentSlip(
                          onViewPdf: () {},
                          payment: PaymentClass(
                              id: "1",
                              partyName: "ELATIO BY GARGS LLP",
                              partyGst: "07AAAFG3827F1ZP",
                              chargeType: "Security Deposit",
                              date: DateTime.now(),
                              amount: 10000,
                              method: "UPI",
                              description: "Rent"),
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ViewPayment();
                                },
                              ),
                            );
                          },
                          onDelete: () {
                            setState(() {
                              itemCount = 2;
                            });
                          },
                        )
                      : SlipCard(
                          bgColor: index == 1
                              ? Colors.teal
                              : index == 0
                                  ? Colors.red.shade600
                                  : Colors.red.shade400,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> savedItems = itemsData.map((itemData) {
  return {
    // itemData[0] is the item name (e.g., 'Standard 3mtr')
    "item": itemData[0],

    // itemData[1] is the Quantity. We use tryParse to handle '-'.
    // If parsing fails, it defaults to 0.
    "Qty": int.tryParse(itemData[1]) ?? 0,

    // itemData[5] is the Rate.
    "rate": double.tryParse(itemData[5]) ?? 0.0,

    // itemData[3] is the per-item Weight.
    "weight": double.tryParse(itemData[3]) ?? 0.0,
  };
}).toList();

class SlipCard extends StatefulWidget {
  final Color bgColor;
  const SlipCard({super.key, required this.bgColor});

  @override
  State<SlipCard> createState() => _SlipCardState();
}

class _SlipCardState extends State<SlipCard> {
  Widget _buildBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Challan Details', // Updated title
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // --- NEW: Challan No. and Date in one row ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(text: "Challan No."),
                    const SizedBox(height: 8),
                    RegisterField(
                      hint: "Challan No.",
                      controller: TextEditingController(text: "03"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Spacing between fields
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(text: "Date"),
                    const SizedBox(height: 8),
                    RegisterField(
                      hint: "Date",
                      controller:
                          TextEditingController(text: "05-10-2025 3:15 PM"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle No.
          const CustomText(text: "Vehicle No."),
          const SizedBox(height: 8),
          RegisterField(
            hint: "Vehicle No.",
            controller: TextEditingController(text: "DL01LAD1234"),
          ),
          const SizedBox(height: 12),

          // Driver Name
          const CustomText(text: "Driver Name"),
          const SizedBox(height: 8),
          RegisterField(
            hint: "Driver Name",
            controller: TextEditingController(text: "Mayank"),
          ),
          const SizedBox(height: 12),

          // --- NEW: Driving License field added ---
          const CustomText(
            text: "Driving License",
          ),
          const SizedBox(
            height: 8,
          ),
          RegisterField(
            hint: "Enter Driving License No.",
            controller: TextEditingController(
                text: 'UP-752980914201'), // Initially empty
          ),
          const SizedBox(
            height: 12,
          ),

          // Driver Phone
          const CustomText(text: "Driver Phone"),
          const SizedBox(height: 8),
          RegisterField(
            hint: "Driver Phone",
            controller: TextEditingController(text: "9354954343"),
          ),
          const SizedBox(height: 12),

          // E-way Bill No
          const CustomText(text: "E-way Bill No"),
          const SizedBox(height: 8),
          RegisterField(
            hint: "E-way Bill No",
            controller: TextEditingController(text: "1234"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          // Transport Amount
          const CustomText(text: "Transport Amount"),
          const SizedBox(height: 8),
          RegisterField(
            hint: "Transport Amount",
            controller: TextEditingController(text: "1000"),
          ),
          const SizedBox(height: 24.0), // Increased spacing before buttons

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: PrimaryButton(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Feature in Development"),
                              content: const Text(
                                  "We're working on this feature. It will be available in a future update!"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Got It!"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      text: "Create E-Way Bill")),
              const SizedBox(width: 20.0),
              Expanded(
                  child: PrimaryButton(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Feature in Development"),
                              content: const Text(
                                  "We're working on this feature. It will be available in a future update!"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("Got It!"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      text: "Cancel E-Way Bill"))
            ],
          ),
          const SizedBox(height: 10.0),

          PrimaryButton(
              onTap: () {
                _generatePdf(context, withStamp: true, isCancelled: false);
              },
              text: "Submit"),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  void _onPopupMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Delete':
        _showDeleteConfirmationDialog(context, 0);
        break;
      case 'Cancel':
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            // Use StatefulBuilder to manage the state of the dialog
            return AlertDialog(
              title: const Text('Confirm Cancellation'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('Are you sure you want to cancel this challan?'),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 3,
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Reason for Cancellation',
                        hintText: 'Please enter a reason',
                      ),
                      // Rebuild the dialog to enable/disable the 'Yes' button
                      onChanged: (text) => setState(() {}),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  // Disable the button if the reason field is empty
                  onPressed: () {
                    // Get the reason from the controller

                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes, Cancel'),
                ),
              ],
            );
          },
        );

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
        Fluttertoast.showToast(
            msg: "No Items Available",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        break;
      case 'E-way/ vehicle/ Edit date No':
        showBottomSheet(
            context: context,
            builder: (context) {
              return _buildBottomSheet(context);
            });
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
      case ' Site Pic':
        _showImagePickerOptions(context);
        break;
      case 'Site current location':
        Navigator.pushNamed(context, '/site-current-location');
        break;
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      // यहाँ आपको चुनी गई इमेज फ़ाइल (image.path) के साथ जो करना है, वह करें
      // जैसे इसे स्टेट में सेव करना या सर्वर पर अपलोड करना
      print('Image picked: ${image.path}');
      // File selectedImage = File(image.path);
    } else {
      print('No image selected.');
    }
  }

// Add this method to show PDF options bottom sheet
  void _showPdfOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generate PDF',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF with Stamp'),
                onTap: () {
                  Navigator.pop(context);
                  _generatePdf(context, withStamp: true, isCancelled: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('PDF without Stamp'),
                onTap: () {
                  Navigator.pop(context);
                  _generatePdf(context, withStamp: false, isCancelled: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
// Make sure you have the necessary imports in your file.
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'dart:math' as math;

  void _generatePdf(BuildContext contextM,
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

    tableData.add([
      '',
      'Total',
      '700',
      '',
      '',
      '8000',
      '',
      '206.5',
      '3090',
    ]);

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
                          pw.Image(
                              pw.MemoryImage(nameBytes.buffer.asUint8List()),
                              width: 300,
                              height: 100,
                              fit: pw.BoxFit.fill),
                          pw.Text('(A/N ISO 9001:2015 Certified Company)',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 8),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('OUTWARD CHALLAN',
                              style: const pw.TextStyle()),
                          pw.SizedBox(height: 30),
                          pw.Text('Challan No: 2',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
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
                    // height: 100,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 0.5),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
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
                              // --- MODIFICATION 2: ADDED CLICKABLE PHONE TO 'BILL TO' ---
                              pw.RichText(
                                text: pw.TextSpan(
                                  children: [
                                    const pw.TextSpan(text: 'Phone: '),
                                    pw.TextSpan(
                                      text: '9876543210', // Sample Phone
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
                        pw.VerticalDivider(width: 10),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Ship To: ',
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
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(width: 1),
                        bottom: pw.BorderSide(width: 1),
                      ),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'Outward Challan Only for Movement of Items, Not for Sale',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ),
                  ),

                  // Main items table
                  pw.Table.fromTextArray(
                    headers: [
                      'Sr\nNo',
                      'Item Name',
                      'Qty',
                      'HSN Code',
                      'Per\nPiece\nWeight',
                      'Weight',
                      'Rate\n/kg',
                      'Rent\n/Day',
                      'Goods Value',
                    ],
                    data: tableData,
                    border: pw.TableBorder.all(width: 0.5),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellStyle: const pw.TextStyle(fontSize: 10),
                    cellAlignment: pw.Alignment.center,
                  ),
                  pw.SizedBox(height: 10),

                  // --- MODIFICATION 3: DRIVER DETAILS TABLE WITH CLICKABLE PHONE ---
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.5),
                    // cellAlignment: pw.Alignment.center,
                    // cellStyle: const pw.TextStyle(fontSize: 10),
                    children: [
                      pw.TableRow(
                        children: [
                          'E-way Bill No',
                          'Vehicle Number',
                          'Driver Name',
                          'Driver Mobile',
                          'Driving License'
                        ]
                            .map((header) => pw.Container(
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(header,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.center),
                                ))
                            .toList(),
                      ),
                      pw.TableRow(
                        children: [
                          pw.Text('0222'),
                          pw.Text('DL01LAD1234'),
                          pw.Text('Mayank'),
                          pw.UrlLink(
                            destination: 'tel:9354953434',
                            child: pw.Text('9354953434', style: linkStyle),
                          ),
                          pw.Text('UP-752980914201'),
                        ]
                            .map((cell) => pw.Container(
                                  padding: const pw.EdgeInsets.all(4),
                                  alignment: pw.Alignment.center,
                                  child: cell,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
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
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5)),
                          child: pw.Center(child: pw.Text("Customer Sign")),
                        ),
                        pw.Container(
                          width: 120,
                          height: 120,
                          decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5)),
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Image(
                                  pw.MemoryImage(
                                      stampBytes.buffer.asUint8List()),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 290,
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
                  border: Border.all(color: widget.bgColor, width: 3),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '05 Oct 2025 \nChallan No: 03',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.black),
                      onPressed: () {
                        _showPdfOptionsBottomSheet(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.black),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onSelected: (value) =>
                          _onPopupMenuSelected(context, value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'Delete',
                            child: Text("Delete",
                                style: TextStyle(color: Colors.red))),
                        PopupMenuItem(value: 'Cancel', child: Text("Cancel")),
                        // PopupMenuItem(
                        //     value: 'Outward challan',
                        //     child: Text("Outward challan Add Item")),
                        PopupMenuItem(
                            value: 'Inward challan',
                            child: Text("Inward challan Add Item")),
                        PopupMenuItem(
                            value: 'E-way/ vehicle/ Edit date No',
                            child: Text("E-way/ vehicle/ Edit date No")),
                        PopupMenuItem(
                            value: 'Add Note', child: Text("Add Note")),
                        PopupMenuItem(
                            value: 'View slip notes',
                            child: Text("View slip notes")),
                        PopupMenuItem(
                            value: ' Site Pic', child: Text("Upload Site Pic")),
                        PopupMenuItem(
                            value: 'Site current location',
                            child: Text("Site current location")),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),

                shrinkWrap: true,
                itemCount:
                    savedItems.length + 1, // Add 1 for the total row at the end
                itemBuilder: (context, index) {
                  // If it's the last item, show the total
                  if (index == savedItems.length) {
                    int totalQty = 0;
                    int totalWeight = 0;
                    int totalRate = 0;

                    // Calculate the totals for Qty, Weight, and Rate
                    for (var item in savedItems) {
                      totalQty += num.parse(item['Qty'].toString()).toInt();
                      totalWeight +=
                          num.parse(item['weight'].toString()).toInt();
                      totalRate += (num.parse(item['Qty'].toString()) * 120)
                          .toInt(); // Modify rate as needed
                    }

                    return Column(
                      children: [
                        ListTile(
                          tileColor: widget.bgColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          dense: true,
                          title: Row(
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const Spacer(),
                              Text(
                                "PCS $totalQty",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ), // Total Quantity
                              const Spacer(),
                              Text(
                                "₹3090",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ), // Total Weight
                              const Spacer(),
                              Text(
                                "Kg 8000",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              // Total Rate
                              const SizedBox(
                                width: 30,
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final item = savedItems[index];

                  // if (index == 0) {
                  //   return const ListTile(
                  //     dense: true,
                  //     title: Row(
                  //       children: [
                  //         Text("Item Name"),
                  //         Spacer(),
                  //         Text("Qty"),
                  //         Spacer(),
                  //         Text("Weight"),
                  //         Spacer(),
                  //         Text("Rate"),
                  //         Spacer(),
                  //         Text("Edit"),
                  //       ],
                  //     ),
                  //   );
                  // }

                  return ListTile(
                    dense: true,
                    title: Row(
                      children: [
                        // Item details
                        Expanded(
                            flex: 4, child: Text(item['item'].toString()!)),
                        Expanded(flex: 2, child: Text(item['Qty'].toString()!)),
                        Expanded(
                            flex: 2, child: Text(item['rate'].toString()!)),
                        Expanded(
                            flex: 2, child: Text(item['weight'].toString()!)),

                        // Dropdown Menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String value) {
                            // Handle menu selection
                            if (value == 'edit') {
                              _showEditDialog(context, index);
                            } else if (value == 'delete') {
                              _showDeleteConfirmationDialog(context, index);
                            } else if (value == 'move') {
                              _showMoveChallanDialog(context, index);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'move',
                              child: Text('Move to other challan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> otherChallanNumbers = ['CH-1002', 'CH-1005', 'CH-1008'];

  // Function to show Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete the item and update the state
                setState(() {
                  savedItems.removeAt(index);
                });
                // Close the dialog
                Navigator.of(ctx).pop();
                // Optional: Show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Function to show Move to Challan Dialog
  void _showMoveChallanDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SimpleDialog(
            title: Text('Select Challan to Move'),
            children: [
              SizedBox(
                height: 12,
              ),
              Center(
                child: CustomText(
                  text: "No Other Challan Found",
                  color: Colors.black,
                  weight: FontWeight.w300,
                ),
              )
            ]
            // otherChallanNumbers.map((challanNumber) {
            //   return SimpleDialogOption(
            //     onPressed: () {
            //       // --- YAHAN APNA LOGIC LIKHEIN ---
            //       // 1. Remove item from current list `savedItems`
            //       // 2. Add item to the list of the selected challan
            //       final itemToMove = savedItems[index];
            //       print(
            //           'Moving "${itemToMove['item']}" to challan $challanNumber');

            //       setState(() {
            //         savedItems.removeAt(index);
            //       });

            //       Navigator.of(context).pop(); // Dialog ko band karein
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text('Item moved to $challanNumber')),
            //       );
            //     },
            //     child: Text(challanNumber),
            //   );
            // }).toList(),
            );
      },
    );
  }

  Future<void> _showViewReasonDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // MODIFICATION START
          title: Row(
            children: [
              // Back button
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.arrow_back,
                  color: ThemeColors.kPrimaryThemeColor,
                ),
                onPressed: () {
                  // Closes the dialog
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 12),
              // Title text
              const Text('Saved Cancellation'),
            ],
          ),
          // MODIFICATION END
          content: const Text(
            "Party Denied",
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove Cancel'),
              onPressed: () {
                Navigator.pop(context);
                // Add your logic here
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    final item = savedItems[index];
    final name = item["item"];
    final TextEditingController qtyController =
        TextEditingController(text: item['Qty'].toString());
    final TextEditingController weightController =
        TextEditingController(text: item['weight'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Item: $name"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Rate"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Update the item in savedItems
                setState(() {
                  savedItems[index]['Qty'] = qtyController.text;
                  savedItems[index]['weight'] = weightController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}

class SlipDetailRow extends StatelessWidget {
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

  void _onPopupMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Edit':
        Navigator.pushNamed(context, '/edit');
        break;
      case 'Move to other challan':
        Navigator.pushNamed(context, '/move-challan');
        break;
      case 'Delete':
        Navigator.pushNamed(context, '/delete');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: iconColor, size: 12),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(title),
          ),
          const SizedBox(width: 12),
          Text(value),
          const SizedBox(width: 78.0),
          Text(issueCount),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.green),
            onSelected: (value) => _onPopupMenuSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Edit', child: Text("Edit")),
              PopupMenuItem(
                  value: 'Move to other challan',
                  child: Text("Move to other challan")),
              PopupMenuItem(
                  value: 'Delete',
                  child: Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

class SlipDetailRow2 extends StatelessWidget {
  final String title;
  final String value;
  final String issueCount;
  final String weight;
  final Color iconColor;

  const SlipDetailRow2({
    required this.title,
    required this.value,
    required this.issueCount,
    required this.iconColor,
    super.key,
    required this.weight,
  });

  void _onPopupMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Edit':
        Navigator.pushNamed(context, '/edit');
        break;
      case 'Move to other challan':
        Navigator.pushNamed(context, '/move-challan');
        break;
      case 'Delete':
        Navigator.pushNamed(context, '/delete');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: iconColor, size: 12),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(title),
          ),
          const Spacer(),
          Text(weight),
          const Spacer(),
          Text(value),
          const Spacer(),
          Text(issueCount),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.green),
            onSelected: (value) => _onPopupMenuSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Edit', child: Text("Edit")),
              PopupMenuItem(
                  value: 'Move to other challan',
                  child: Text("Move to other challan")),
              PopupMenuItem(
                  value: 'Delete',
                  child: Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

final itemsData = [
  ['Standard 1mtr', '250', '73084000', '13.5', '3375', '65', '2', '500'],
  ['Standard 2.0mtr', '400', '73084000', '5', '2000', '65', '1.5', '600'],
  ['Coupler', '50', '73084000', '100', '120', '120', '3', '500'],
  [
    'Scaffolding Area (10*10*1)',
    '100',
    '-',
    '-',
    '-',
    '-',
    '200',
    '-'
  ], // 👈 Added area item
];
