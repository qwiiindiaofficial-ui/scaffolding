import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:scaffolding_sale/screens/pdf.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:typed_data';

// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TestingSplash extends StatefulWidget {
  const TestingSplash({Key? key}) : super(key: key);

  @override
  _TestingSplashState createState() => _TestingSplashState();
}

class _TestingSplashState extends State<TestingSplash> {
  @override
  void initState() {
    super.initState();
    checkCompanyDetails();
  }

  Future<void> checkCompanyDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if essential company details are saved
      final hasCompanyName =
          prefs.getString('companyName')?.isNotEmpty ?? false;
      final hasCompanyAddress =
          prefs.getString('companyAddress')?.isNotEmpty ?? false;
      final hasCompanyGst = prefs.getString('companyGst')?.isNotEmpty ?? false;
      final hasPhoneNumbers =
          prefs.getStringList('companyPhones')?.isNotEmpty ?? false;
      final hasBankDetails =
          prefs.getString('bankDetails')?.isNotEmpty ?? false;

      // Add a slight delay for splash screen visibility
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate based on whether company details are complete
      if (hasCompanyName &&
          hasCompanyAddress &&
          hasCompanyGst &&
          hasPhoneNumbers &&
          hasBankDetails) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ChallanFormScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CompanyDetailsScreen()),
        );
      }
    } catch (e) {
      print('Error checking company details: $e');
      if (!mounted) return;

      // In case of error, default to CompanyDetailsScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CompanyDetailsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'images/logo.png', // Make sure to add this in pubspec.yaml
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),

            // App Name
            const Text(
              'Scaffolding App India',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({Key? key}) : super(key: key);

  @override
  _CompanyDetailsScreenState createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Image paths
  String? companyLogoPath;
  String? companyStampPath;
  String? companyNameImagePath;

  // Basic company details controllers
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();
  TextEditingController companyGstController = TextEditingController();
  TextEditingController companyPhoneController = TextEditingController();

  // Terms and conditions controllers
  TextEditingController billTermsController = TextEditingController();
  TextEditingController quotationTermsController = TextEditingController();
  TextEditingController estimateTermsController = TextEditingController();
  TextEditingController challanTermsController = TextEditingController();

  // Bank details controller
  TextEditingController bankDetailsController = TextEditingController();

  // ISO certification number
  TextEditingController isoNumberController = TextEditingController();

  // Other variables
  List<String> phoneNumbers = [];
  int _selectedTermsIndex = 0;

  @override
  void initState() {
    super.initState();
    loadCompanyDetails();
  }

  Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final companyImagesDir = Directory('${directory.path}/company_images');
    if (!await companyImagesDir.exists()) {
      await companyImagesDir.create(recursive: true);
    }
    return companyImagesDir.path;
  }

  Future<String> copyFileToAppDirectory(File sourceFile, String type) async {
    final appDir = await getAppDirectory();
    final fileName =
        '${type}_${DateTime.now().millisecondsSinceEpoch}${path.extension(sourceFile.path)}';
    final destinationPath = path.join(appDir, fileName);

    try {
      final File newImage = await sourceFile.copy(destinationPath);
      print('Image saved to: ${newImage.path}');
      return newImage.path;
    } catch (e) {
      print('Error copying file: $e');
      return sourceFile.path;
    }
  }

  Future<void> loadCompanyDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        // Load basic company details
        companyNameController.text = prefs.getString('companyName') ?? '';
        companyAddressController.text = prefs.getString('companyAddress') ?? '';
        companyGstController.text = prefs.getString('companyGst') ?? '';
        phoneNumbers = prefs.getStringList('companyPhones') ?? [];
        isoNumberController.text = prefs.getString('isoNumber') ?? '';

        // Load terms for different types
        billTermsController.text =
            prefs.getString('billTerms') ?? 'Default Bill Terms: xxx';
        quotationTermsController.text =
            prefs.getString('quotationTerms') ?? 'Default Quotation Terms: xxx';
        estimateTermsController.text =
            prefs.getString('estimateTerms') ?? 'Default Estimate Terms: xxx';
        challanTermsController.text =
            prefs.getString('challanTerms') ?? 'Default Challan Terms: xxx';

        // Load bank details
        bankDetailsController.text =
            prefs.getString('bankDetails') ?? 'Bank Details: xxx';

        // Load image paths
        companyLogoPath = prefs.getString('companyLogoPath');
        companyStampPath = prefs.getString('companyStampPath');
        companyNameImagePath = prefs.getString('companyNameImagePath');

        // Verify if files exist
        if (companyLogoPath != null) {
          final file = File(companyLogoPath!);
          if (!file.existsSync()) {
            companyLogoPath = null;
            prefs.remove('companyLogoPath');
          }
        }

        if (companyStampPath != null) {
          final file = File(companyStampPath!);
          if (!file.existsSync()) {
            companyStampPath = null;
            prefs.remove('companyStampPath');
          }
        }

        if (companyNameImagePath != null) {
          final file = File(companyNameImagePath!);
          if (!file.existsSync()) {
            companyNameImagePath = null;
            prefs.remove('companyNameImagePath');
          }
        }
      });
    } catch (e) {
      print('Error loading company details: $e');
    }
  }

  Future<void> saveCompanyDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();

        // Save all the company details (same as before)
        await prefs.setString('companyName', companyNameController.text);
        await prefs.setString('companyAddress', companyAddressController.text);
        await prefs.setString('companyGst', companyGstController.text);
        await prefs.setStringList('companyPhones', phoneNumbers);
        await prefs.setString('isoNumber', isoNumberController.text);
        await prefs.setString('billTerms', billTermsController.text);
        await prefs.setString('quotationTerms', quotationTermsController.text);
        await prefs.setString('estimateTerms', estimateTermsController.text);
        await prefs.setString('challanTerms', challanTermsController.text);
        await prefs.setString('bankDetails', bankDetailsController.text);

        if (companyLogoPath != null) {
          await prefs.setString('companyLogoPath', companyLogoPath!);
        }
        if (companyStampPath != null) {
          await prefs.setString('companyStampPath', companyStampPath!);
        }
        if (companyNameImagePath != null) {
          await prefs.setString('companyNameImagePath', companyNameImagePath!);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company details saved successfully!')),
        );

        // Check if terms are already accepted
        bool termsAccepted = prefs.getBool('termsAccepted') ?? false;

        if (!termsAccepted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              bool isChecked = false;
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Terms and Conditions'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                            'Please accept our terms and conditions to proceed.'),
                        const SizedBox(height: 10),
                        const Text(
                          'Your data is securely stored on your device only. We do not have access to any of your personal information.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text('I accept the terms and conditions'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Back'),
                      ),
                      TextButton(
                        onPressed: isChecked
                            ? () async {
                                await prefs.setBool('termsAccepted', true);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChallanFormScreen(),
                                  ),
                                );
                              }
                            : null,
                        child: const Text('Proceed'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ChallanFormScreen()),
          );
        }
      } catch (e) {
        print('Error saving company details: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving company details')),
        );
      }
    }
  }

  pw.Widget buildAddressCell({
    required String title,
    required List<pw.Widget> contentWidgets,
  }) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title with top padding
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),

          // Full-width line without horizontal padding
          pw.Container(
            width: double.infinity,
            height: 1,
            color: PdfColors.black,
          ),

          // Remaining content with side padding
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: contentWidgets,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepPurple,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Image',
            ),
          ],
        );

        if (croppedFile != null) {
          final permanentPath =
              await copyFileToAppDirectory(File(croppedFile.path), type);

          setState(() {
            if (type == 'logo') {
              companyLogoPath = permanentPath;
            } else if (type == 'stamp') {
              companyStampPath = permanentPath;
            } else if (type == 'name') {
              companyNameImagePath = permanentPath;
            }
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> generateCompanyDetailsPdf() async {
    try {
      final pdf = pw.Document();

      // Load images
      Uint8List? logoImage;
      Uint8List? stampImage;
      Uint8List? nameImage;
      Uint8List? appLogoImage;

      if (companyLogoPath != null) {
        try {
          logoImage = await File(companyLogoPath!).readAsBytes();
        } catch (e) {
          print('Error loading logo: $e');
        }
      }

      if (companyStampPath != null) {
        try {
          stampImage = await File(companyStampPath!).readAsBytes();
        } catch (e) {
          print('Error loading stamp: $e');
        }
      }

      if (companyNameImagePath != null) {
        try {
          nameImage = await File(companyNameImagePath!).readAsBytes();
        } catch (e) {
          print('Error loading name image: $e');
        }
      }

      try {
        final ByteData data = await rootBundle.load('images/logo.png');
        appLogoImage = data.buffer.asUint8List();
      } catch (e) {
        print('Error loading app logo: $e');
      }

      pdf.addPage(
        pw.MultiPage(
          margin: const pw.EdgeInsets.all(20),
          pageFormat: PdfPageFormat.a4,
          header: (pw.Context context) {
            return pw.Column(
              children: [
                // Header with logo and company name
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Image(pw.MemoryImage(logoImage),
                          width: 80, height: 80),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (nameImage != null)
                            pw.Image(pw.MemoryImage(nameImage),
                                height: 80, width: 300, fit: pw.BoxFit.fill)
                          else
                            pw.Text(
                              companyNameController.text.isNotEmpty
                                  ? companyNameController.text
                                  : 'xx',
                              style: pw.TextStyle(
                                  fontSize: 30, fontWeight: pw.FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('PREVIEW'),
                        pw.SizedBox(height: 5),
                        pw.Text('No: xx'),
                        pw.Text(
                            'Date: ${DateTime.now().toString().split(' ')[0]}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Three address boxes in one container
                pw.Container(
                  decoration: pw.BoxDecoration(border: pw.Border.all()),
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                    },
                    border: const pw.TableBorder(
                      verticalInside: pw.BorderSide(),
                    ),
                    children: [
                      pw.TableRow(
                        children: [
                          // From Address
                          buildAddressCell(
                            title: 'From:',
                            contentWidgets: [
                              pw.Text(isoNumberController.text),
                              pw.Text(companyAddressController.text),
                              pw.Text('GST: ${companyGstController.text}'),
                              pw.Wrap(
                                spacing: 4,
                                children: phoneNumbers.map((number) {
                                  return pw.UrlLink(
                                    destination: 'tel:$number',
                                    child: pw.Text(
                                      number,
                                      style: const pw.TextStyle(
                                        color: PdfColors.blue,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                          // Bill To Address
                          buildAddressCell(
                            title: 'Bill To:',
                            contentWidgets: [
                              pw.Text('M/S: xx'),
                              pw.Text('Address: xx'),
                              pw.Text('GST: xx'),
                            ],
                          ),

                          // Ship To Address
                          buildAddressCell(
                            title: 'Ship To:',
                            contentWidgets: [
                              pw.Text('Address: xx'),
                              pw.Text('Contact: xx'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              // Items Table with Headers
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Item Name
                  1: const pw.FlexColumnWidth(0.8), // Qty
                  2: const pw.FlexColumnWidth(0.8), // HSN
                  3: const pw.FlexColumnWidth(0.8), // Weight/pc
                  4: const pw.FlexColumnWidth(0.8), // Total Weight
                  5: const pw.FlexColumnWidth(0.8), // Rate
                  6: const pw.FlexColumnWidth(0.8), // Rent/Day
                  7: const pw.FlexColumnWidth(1.2), // Amount
                },
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      for (final header in [
                        'Item Name',
                        'Qty',
                        'HSN\nCode',
                        'Weight\nper pc',
                        'Total\nWeight',
                        'Rate/kg',
                        'Rent/\nDay',
                        'Amount',
                      ])
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  // Sample Row with xx
                  pw.TableRow(
                    children: [
                      for (var i = 0; i < 8; i++)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'xx',
                            style: const pw.TextStyle(fontSize: 8),
                            textAlign: i == 0
                                ? pw.TextAlign.left
                                : pw.TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Transport Details Table
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Table.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  headerStyle:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                  cellStyle: const pw.TextStyle(fontSize: 8),
                  headers: [
                    'E-way Bill No',
                    'Vehicle Number',
                    'Driver Name',
                    'Driver Mobile',
                    'Driving License'
                  ],
                  data: [
                    ['xx', 'xx', 'xx', 'xx', 'xx']
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Terms and Bank Details

              // Signatures Section with three boxes
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Row(
                  children: [
                    // Powered By
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        height: 100,
                        padding: const pw.EdgeInsets.all(8),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide()),
                        ),
                        child: pw.Center(
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              if (appLogoImage != null)
                                pw.Image(pw.MemoryImage(appLogoImage),
                                    width: 50, height: 50),
                              pw.SizedBox(width: 8),
                              pw.Column(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Powered by\nScaffolding App India',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.blue,
                                      fontWeight: pw.FontWeight.bold,
                                      decoration: pw.TextDecoration.underline,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.UrlLink(
                                    destination:
                                        'tel:+9108069640939', // 👉 Replace with your number
                                    child: pw.RichText(
                                      text: pw.TextSpan(
                                        style: const pw.TextStyle(
                                          color: PdfColors.black,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          const pw.TextSpan(text: "Help: 0"),
                                          pw.TextSpan(
                                            text: "80",
                                            style: pw.TextStyle(
                                              color: PdfColors.deepOrange900,
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.normal,
                                            ),
                                          ),
                                          const pw.TextSpan(text: "696"),
                                          pw.TextSpan(
                                            text: "40",
                                            style: pw.TextStyle(
                                              color: PdfColors.deepOrange900,
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.normal,
                                            ),
                                          ),
                                          const pw.TextSpan(text: "939"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        height: 100,
                        padding: const pw.EdgeInsets.all(8),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide()),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Text('Bank Details'),
                            pw.SizedBox(height: 5),
                            pw.Text(bankDetailsController.text),
                          ],
                        ),
                      ),
                    ),
                    // Customer Signature
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        height: 100,
                        padding: const pw.EdgeInsets.all(8),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(right: pw.BorderSide()),
                        ),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Customer Signature'),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                    // Company Stamp/Signature
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        height: 100,
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            if (stampImage != null)
                              pw.Image(pw.MemoryImage(stampImage), height: 60)
                            else
                              pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.end,
                                children: [
                                  pw.Text('Authorized Signature'),
                                  pw.SizedBox(height: 5),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                // padding: const pw.EdgeInsets.all(10),
                // decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Row(children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Terms & Conditions:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text(_selectedTermsIndex == 0
                          ? billTermsController.text
                          : _selectedTermsIndex == 1
                              ? quotationTermsController.text
                              : _selectedTermsIndex == 2
                                  ? estimateTermsController.text
                                  : challanTermsController.text),
                    ],
                  ),
                ]),
              ),

              pw.SizedBox(height: 10),
            ];
          },
        ),
      );

      // Save and open the PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/company_details_preview.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  Widget _buildImageUploadSection(
      String type, String label, String? imagePath) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text('Upload $label'),
            onPressed: () => _pickImage(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          if (imagePath != null) ...[
            const SizedBox(height: 8),
            Image.file(
              File(imagePath),
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            Text(
              path.basename(imagePath),
              style: const TextStyle(fontSize: 12),
            ),
            TextButton(
              onPressed: () => removeImage(type),
              child: Text('Remove $label'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneNumbersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: companyPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Company Phone Number',
                  border: OutlineInputBorder(),
                  hintText: 'Enter 10-digit phone number',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (phoneNumbers.isEmpty) {
                    return 'Please add at least one phone number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addPhoneNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (phoneNumbers.isNotEmpty) ...[
          const Text(
            'Added Phone Numbers:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: phoneNumbers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(phoneNumbers[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePhoneNumber(phoneNumbers[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> removeImage(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? pathToRemove;

      if (type == 'logo') {
        pathToRemove = companyLogoPath;
        companyLogoPath = null;
        await prefs.remove('companyLogoPath');
      } else if (type == 'stamp') {
        pathToRemove = companyStampPath;
        companyStampPath = null;
        await prefs.remove('companyStampPath');
      } else if (type == 'name') {
        pathToRemove = companyNameImagePath;
        companyNameImagePath = null;
        await prefs.remove('companyNameImagePath');
      }

      if (pathToRemove != null) {
        final file = File(pathToRemove);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {});
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  void _addPhoneNumber() {
    final phone = companyPhoneController.text.trim();
    if (phone.length == 10 && phone.contains(RegExp(r'^[0-9]+$'))) {
      setState(() {
        if (!phoneNumbers.contains(phone)) {
          phoneNumbers.add(phone);
          companyPhoneController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This number is already added')),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number')),
      );
    }
  }

  void _removePhoneNumber(String phone) {
    setState(() {
      phoneNumbers.remove(phone);
    });
  }

  Widget _buildTermsAndConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Terms and Conditions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ToggleButtons(
            isSelected: [
              _selectedTermsIndex == 0,
              _selectedTermsIndex == 1,
              _selectedTermsIndex == 2,
              _selectedTermsIndex == 3,
            ],
            onPressed: (index) {
              setState(() {
                _selectedTermsIndex = index;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Bills'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Quotation'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Estimate'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Challan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _selectedTermsIndex == 0
              ? billTermsController
              : _selectedTermsIndex == 1
                  ? quotationTermsController
                  : _selectedTermsIndex == 2
                      ? estimateTermsController
                      : challanTermsController,
          decoration: const InputDecoration(
            labelText: 'Terms and Conditions',
            border: OutlineInputBorder(),
          ),
          maxLines: 8,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter terms and conditions';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () async {
            launchUrlString("tel://08069640939");
          },
          child: Row(
            children: [
              const Text(
                "(Help) ",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              const Icon(
                Icons.phone,
                color: Colors.green,
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                  children: [
                    const TextSpan(text: " 0"),
                    TextSpan(
                      text: "80",
                      style: TextStyle(
                        color: Colors.deepOrange[900],
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: "696"),
                    TextSpan(
                      text: "40",
                      style: TextStyle(
                        color: Colors.deepOrange[900],
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: "939"),
                  ],
                ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf,
              color: Colors.teal,
            ),
            onPressed: generateCompanyDetailsPdf,
            tooltip: 'Preview PDF',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Company Details Setup",
                weight: FontWeight.normal,
                size: 18,
              ),
              SizedBox(
                height: 18,
              ),
              TextFormField(
                controller: companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true && companyNameImagePath == null) {
                    return 'Please enter company name or upload name image';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: companyAddressController,
                decoration: const InputDecoration(
                  labelText: 'Company Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter company address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                textCapitalization: TextCapitalization.characters,
                controller: companyGstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter GST number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPhoneNumbersList(),
              const SizedBox(height: 16),
              TextFormField(
                controller: isoNumberController,
                decoration: const InputDecoration(
                  labelText: 'ISO Certification Number (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter ISO certification number if available',
                ),
              ),
              const SizedBox(height: 16),
              _buildImageUploadSection('logo', 'Company Logo', companyLogoPath),
              const SizedBox(height: 16),
              _buildImageUploadSection(
                  'name', 'Company Name Image', companyNameImagePath),
              const SizedBox(height: 16),
              _buildImageUploadSection(
                  'stamp', 'Company Stamp', companyStampPath),
              const SizedBox(height: 16),
              TextFormField(
                controller: bankDetailsController,
                decoration: const InputDecoration(
                  labelText: 'Bank Details',
                  border: OutlineInputBorder(),
                  hintText: 'Enter complete bank details',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter bank details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTermsAndConditions(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: saveCompanyDetails,
                  child: const Text(
                    'Save and Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    companyAddressController.dispose();
    companyGstController.dispose();
    companyPhoneController.dispose();
    billTermsController.dispose();
    quotationTermsController.dispose();
    estimateTermsController.dispose();
    challanTermsController.dispose();
    bankDetailsController.dispose();
    isoNumberController.dispose();
    super.dispose();
  }
}
