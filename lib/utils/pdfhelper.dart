import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

Future<pw.Widget> buildPdfHeaderAndAddressSection(
    {required String challanNo,
    required String challanType,
    required String billToName,
    required String billToAddress,
    required String billToGst,
    required String billToMobile,
    required String shipToAddress,
    required String date,
    required String shipToName,
    required String shipToContact,
    String? billtype}) async {
  final prefs = await SharedPreferences.getInstance();

  // Data fetch from session
  final companyName = prefs.getString('companyName') ?? '';
  final companyAddress = prefs.getString('companyAddress') ?? '';
  final companyGst = prefs.getString('companyGst') ?? '';
  final phoneNumbers = prefs.getStringList('companyPhones') ?? [];
  final isoNumber = prefs.getString('isoNumber') ?? '';
  final companyLogoPath = prefs.getString('companyLogoPath');
  final companyNameImagePath = prefs.getString('companyNameImagePath');

  Uint8List? logoImage;
  Uint8List? nameImage;

  if (companyLogoPath != null) {
    try {
      logoImage = await File(companyLogoPath).readAsBytes();
    } catch (_) {}
  }
  if (companyNameImagePath != null) {
    try {
      nameImage = await File(companyNameImagePath).readAsBytes();
    } catch (_) {}
  }

  return pw.Column(
    children: [
      // Header with logo and company name
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoImage != null)
            pw.Image(pw.MemoryImage(logoImage), width: 80, height: 80),
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
                    companyName.isNotEmpty ? companyName : 'xx',
                    style: pw.TextStyle(
                        fontSize: 30, fontWeight: pw.FontWeight.bold),
                  ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(challanType),
              pw.SizedBox(height: 5),
              pw.Text('No: $challanNo'),
              pw.Text('Date: $date'),
              billtype == null
                  ? pw.Container()
                  : pw.Text("Bill Type: $billtype")
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
                pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: pw.Text(
                          'From:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: double.infinity,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(isoNumber),
                            pw.Text(companyAddress),
                            pw.Text('GST: $companyGst'),
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
                      ),
                    ],
                  ),
                ),
                // Bill To Address (from parameters)
                pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: pw.Text(
                          'Bill To:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: double.infinity,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('M/S: $billToName'),
                            pw.Text('Address: $billToAddress'),
                            pw.Text('GST: $billToGst'),
                            pw.UrlLink(
                              destination: 'tel:$billToMobile',
                              child: pw.Text(
                                'Mobile: $billToMobile',
                                style: pw.TextStyle(
                                  color: PdfColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Ship To Address (from parameters)
                pw.Container(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: pw.Text(
                          'Ship To:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: double.infinity,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Address: $shipToAddress'),
                            pw.Text('Name: $shipToName'),
                            pw.UrlLink(
                              destination: 'tel:$shipToContact',
                              child: pw.Text(
                                'Contact: $shipToContact',
                                style: pw.TextStyle(
                                  color: PdfColors.blue,
                                ),
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
          ],
        ),
      ),
    ],
  );
}

Future<pw.Widget> buildPdfFooterSection(
    String challanType, bool withstamp) async {
  final prefs = await SharedPreferences.getInstance();
  final companyStampPath = prefs.getString('companyStampPath');
  final billTerms = prefs.getString('billTerms') ?? 'Default Bill Terms: xxx';
  final quotationTerms =
      prefs.getString('quotationTerms') ?? 'Default Quotation Terms: xxx';
  final estimateTerms =
      prefs.getString('estimateTerms') ?? 'Default Estimate Terms: xxx';
  final challanTerms =
      prefs.getString('challanTerms') ?? 'Default Challan Terms: xxx';

  Uint8List? appLogoImage;
  Uint8List? stampImage;

  try {
    final ByteData data = await rootBundle.load('images/logo.png');
    appLogoImage = data.buffer.asUint8List();
  } catch (_) {}

  if (companyStampPath != null) {
    try {
      stampImage = await File(companyStampPath).readAsBytes();
    } catch (_) {}
  }
  final currentDateTime =
      DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());

  // Default: Bill terms, aap chahein to index pass krke select bhi kar sakte hain
  final selectedTerms = challanType.contains("Challan")
      ? challanTerms
      : challanType.contains("Tax Invoice")
          ? billTerms
          : challanType.contains("Estimate")
              ? estimateTerms
              : quotationTerms;

  return pw.Column(
    children: [
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
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
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
                            destination: 'tel:08069640939',
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
            // pw.Expanded(
            //   flex: 2,
            //   child: pw.Container(
            //     height: 100,
            //     padding: const pw.EdgeInsets.all(8),
            //     decoration: const pw.BoxDecoration(
            //       border: pw.Border(right: pw.BorderSide()),
            //     ),
            //     child: pw.Column(
            //       mainAxisAlignment: pw.MainAxisAlignment.start,
            //       children: [
            //         pw.Text('Bank Details'),
            //         pw.SizedBox(height: 5),
            //         pw.Text(bankDetails),
            //       ],
            //     ),
            //   ),
            // ),
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
                      if (withstamp)
                        pw.Image(pw.MemoryImage(stampImage), height: 60)
                      else
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Authorized Signature'),
                            pw.SizedBox(height: 5),
                          ],
                        ),
                    pw.SizedBox(height: 5),
                    pw.Text(currentDateTime, style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      pw.Container(
        child: pw.Row(children: [
          pw.Expanded(
            // This allows the column to use available space
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Terms & Conditions:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(
                  selectedTerms,
                  textAlign: pw
                      .TextAlign.justify, // optional: for better paragraph feel
                ),
              ],
            ),
          ),
        ]),
      ),

      pw.SizedBox(height: 10),
    ],
  );
}
