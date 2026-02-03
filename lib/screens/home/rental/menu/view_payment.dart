import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:scaffolding_sale/widgets/button.dart';

// lib/models/payment_model.dart
class PaymentClass {
  final String id;
  final String partyName;
  final String partyGst;
  final String chargeType;
  final DateTime date;
  final double amount;
  final String method;
  final String description;

  PaymentClass({
    required this.id,
    required this.partyName,
    required this.partyGst,
    required this.chargeType,
    required this.date,
    required this.amount,
    required this.method,
    required this.description,
  });
}
// आवश्यक मॉडल को आयात करें
// import 'lib/models/payment_model.dart';

// मान लेते हैं कि Payment मॉडल आयातित है।

class PaymentSlip extends StatelessWidget {
  final PaymentClass payment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewPdf;

  const PaymentSlip({
    super.key,
    required this.payment,
    required this.onEdit,
    required this.onDelete,
    required this.onViewPdf,
  });

  // Number to words converter
  String _convertNumberToWords(double number) {
    if (number == 0) return 'Zero Rupees Only';

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

    int rupees = number.floor();
    int paise = ((number - rupees) * 100).round();

    String result = '';

    // Crore (10,000,000)
    if (rupees >= 10000000) {
      int croreDigit = rupees ~/ 10000000;
      if (croreDigit < ones.length) {
        result += ones[croreDigit] + ' Crore ';
      }
      rupees %= 10000000;
    }

    // Lakh (100,000)
    if (rupees >= 100000) {
      int lakhValue = rupees ~/ 100000;
      if (lakhValue >= 10 && lakhValue < 20) {
        result += teens[lakhValue - 10] + ' Lakh ';
      } else if (lakhValue >= 20) {
        int tensDigit = lakhValue ~/ 10;
        int onesDigit = lakhValue % 10;
        if (tensDigit < tens.length) result += tens[tensDigit] + ' ';
        if (onesDigit > 0 && onesDigit < ones.length)
          result += ones[onesDigit] + ' ';
        result += 'Lakh ';
      } else if (lakhValue > 0 && lakhValue < ones.length) {
        result += ones[lakhValue] + ' Lakh ';
      }
      rupees %= 100000;
    }

    // Thousand (1,000)
    if (rupees >= 1000) {
      int thousandValue = rupees ~/ 1000;
      if (thousandValue >= 10 && thousandValue < 20) {
        result += teens[thousandValue - 10] + ' Thousand ';
      } else if (thousandValue >= 20) {
        int tensDigit = thousandValue ~/ 10;
        int onesDigit = thousandValue % 10;
        if (tensDigit < tens.length) result += tens[tensDigit] + ' ';
        if (onesDigit > 0 && onesDigit < ones.length)
          result += ones[onesDigit] + ' ';
        result += 'Thousand ';
      } else if (thousandValue > 0 && thousandValue < ones.length) {
        result += ones[thousandValue] + ' Thousand ';
      }
      rupees %= 1000;
    }

    // Hundred (100)
    if (rupees >= 100) {
      int hundredDigit = rupees ~/ 100;
      if (hundredDigit > 0 && hundredDigit < ones.length) {
        result += ones[hundredDigit] + ' Hundred ';
      }
      rupees %= 100;
    }

    // Tens and Ones
    if (rupees >= 20) {
      int tensDigit = rupees ~/ 10;
      if (tensDigit < tens.length) {
        result += tens[tensDigit] + ' ';
      }
      rupees %= 10;
    }

    if (rupees >= 10 && rupees < 20) {
      result += teens[rupees - 10] + ' ';
      rupees = 0;
    }

    if (rupees > 0 && rupees < ones.length) {
      result += ones[rupees] + ' ';
    }

    result += 'Rupees';

    if (paise > 0) {
      result += ' and $paise Paise';
    }

    result += ' Only';

    return result.trim();
  }

  Future<void> _generatePaymentSlipPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final logoBytes = await rootBundle.load('images/logo.png');
      final nameBytes = await rootBundle.load('images/name.png');
      final stampBytes = await rootBundle.load('images/stamp.jpeg');

      final linkStyle = pw.TextStyle(
        color: PdfColors.blue,
        decoration: pw.TextDecoration.underline,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
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
                        width: 70, height: 70, fit: pw.BoxFit.fill),
                    pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(nameBytes.buffer.asUint8List()),
                            width: 160, height: 75, fit: pw.BoxFit.fill),
                        pw.Text('(A/N ISO 9001:2015 Certified Company)',
                            style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'PAYMENT RECEIPT',
                          style: pw.TextStyle(
                              fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text('Slip No: ${payment.id}               ',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9)),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Date: ${DateFormat('dd-MMM-yyyy').format(payment.date)}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 5),

                // Company Address (Full Width)
                // pw.Container(
                //   width: pageWidth,
                //   padding: const pw.EdgeInsets.all(4),
                //   decoration:
                //       pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                //   child: pw.RichText(
                //     textAlign: pw.TextAlign.center,
                //     text: pw.TextSpan(
                //       style: const pw.TextStyle(fontSize: 8),
                //       children: [
                //         const pw.TextSpan(
                //             text:
                //                 'PLOT NO-23 KHASRA NO 14/1 RANI LAXMI BAI NAGAR, DUNDA HERA, GHAZIABAD (U.P) - 201001 MOBILE NO: '),
                //         pw.TextSpan(
                //             text: '9871227048',
                //             style: linkStyle,
                //             annotation: pw.AnnotationUrl('tel:9871227048')),
                //         const pw.TextSpan(text: ', '),
                //         pw.TextSpan(
                //             text: '9213449692',
                //             style: linkStyle,
                //             annotation: pw.AnnotationUrl('tel:9213449692')),
                //       ],
                //     ),
                //   ),
                // ),

                // Our Details & Party Details (Two Boxes)
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Row(
                    children: [
                      // Our Details (Left Box)
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Our Details:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                            pw.SizedBox(height: 3),
                            pw.Text('M/S: Pal Scaffolding',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.Text(
                                'Address: PLOT NO-23 KHASRA NO 14/1 RANI LAXMI BAI NAGAR, DUNDA HERA, GHAZIABAD (U.P) - 201001',
                                style: const pw.TextStyle(fontSize: 7)),
                            pw.Text('GST NO: 09AXXXX0000X1ZX',
                                style: const pw.TextStyle(fontSize: 8)),
                            pw.RichText(
                              text: pw.TextSpan(
                                style: const pw.TextStyle(fontSize: 8),
                                children: [
                                  const pw.TextSpan(text: 'Phone: '),
                                  pw.TextSpan(
                                      text: '9871227048',
                                      style: linkStyle,
                                      annotation:
                                          pw.AnnotationUrl('tel:9871227048')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical Divider
                      pw.Container(
                          width: 1, color: PdfColors.black, height: 70),

                      // Party Details (Right Box)
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 6),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Party Details:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                              pw.SizedBox(height: 3),
                              pw.Text('M/S: ${payment.partyName ?? "N/A"}',
                                  style: const pw.TextStyle(fontSize: 8)),
                              pw.Text(
                                  'Address: B 240 GRD FLOOR B NOIDA SECTOR 50 NOIDA, Uttar Pradesh, India - 201301"}',
                                  style: const pw.TextStyle(fontSize: 7)),
                              if (payment.partyGst != null &&
                                  payment.partyGst!.isNotEmpty)
                                pw.Text('GST NO: ${payment.partyGst}',
                                    style: const pw.TextStyle(fontSize: 8)),
                              pw.RichText(
                                text: pw.TextSpan(
                                  style: const pw.TextStyle(fontSize: 8),
                                  children: [
                                    const pw.TextSpan(text: 'Phone: '),
                                    pw.TextSpan(
                                        text: "7303408500",
                                        style: linkStyle,
                                        annotation:
                                            pw.AnnotationUrl('tel:7303408500')),
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

                pw.SizedBox(height: 10),

                // Payment Details Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Details',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 15),

                      // Payment Info Table
                      pw.Table(
                        border: pw.TableBorder.all(width: 0.5),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(2),
                          1: const pw.FlexColumnWidth(3),
                        },
                        children: [
                          _buildTableRow(
                              'Received From:', payment.partyName ?? 'N/A'),
                          _buildTableRow(
                              'Payment Mode:', payment.method ?? 'Cash'),
                          _buildTableRow('Reference No:', payment.id ?? 'N/A'),
                          _buildTableRow('Date:',
                              DateFormat('dd-MMM-yyyy').format(payment.date)),
                          if (payment.description != null &&
                              payment.description!.isNotEmpty)
                            _buildTableRow('Remarks:', payment.description!),
                        ],
                      ),

                      pw.SizedBox(height: 20),

                      // Amount in Words
                      pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(width: 0.5),
                            color: PdfColors.grey200,
                          ),
                          child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    ' ${_convertNumberToWords(payment.amount)}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 9,
                                        fontStyle: pw.FontStyle.italic),
                                  ),
                                ),
                                pw.Spacer(),
                                pw.Text(
                                  payment.amount.toStringAsFixed(
                                      0), // 'Amount: ${(payment.amount.toStringAsFixed(0))}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 12,
                                      color: PdfColors.green,
                                      fontStyle: pw.FontStyle.italic),
                                )
                              ])),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer Section
                pw.Container(
                  height: 100,
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Image(
                              pw.MemoryImage(logoBytes.buffer.asUint8List()),
                              width: 70,
                              height: 70,
                              fit: pw.BoxFit.fill),
                          pw.UrlLink(
                            destination: 'https://scaffoldingappindia.com/',
                            child: pw.Text('POWERED BY SCAFFOLDING APP INDIA',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue,
                                    decoration: pw.TextDecoration.underline)),
                          ),
                        ],
                      ),
                      pw.Spacer(),
                      pw.VerticalDivider(color: PdfColors.black),
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 90,
                            height: 80,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Image(
                                    pw.MemoryImage(
                                        stampBytes.buffer.asUint8List()),
                                    height: 60,
                                    width: 85,
                                    fit: pw.BoxFit.contain),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  'Authorized Signature',
                                  style: pw.TextStyle(
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 5),

                // Bottom Note
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                    color: PdfColors.grey100,
                  ),
                  child: pw.Text(
                    'Note: This is a computer-generated payment slip and does not require a physical signature.',
                    style: const pw.TextStyle(fontSize: 7),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/payment_slip_${payment.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      Fluttertoast.showToast(msg: 'Payment Slip PDF Generated Successfully!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error generating PDF: $e');
    }
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Slip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Slip No: ${payment.id}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          DateFormat('dd-MMM-yyyy').format(payment.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          payment.amount.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => _generatePaymentSlipPdf(context),
                  child:
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    } else if (value == 'view_pdf') {
                      _generatePaymentSlipPdf(context);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'view_pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text('View PDF'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ViewPayment extends StatefulWidget {
  final Party? party;
  const ViewPayment({super.key, this.party});

  @override
  _ViewPaymentState createState() => _ViewPaymentState();
}

class _ViewPaymentState extends State<ViewPayment> {
  String otherCharge = "Other Charges";
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String _paymentMethod = "Select Method";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Payment"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              Fluttertoast.showToast(msg: "Generating PDF...");
              try {
                final Uint8List pdfData = await _generatePdf(PdfPageFormat.a4);
                final output = await getTemporaryDirectory();
                final file = File(
                    "${output.path}/payment_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf");
                await file.writeAsBytes(pdfData);
                await OpenFile.open(file.path);
              } catch (e) {
                Fluttertoast.showToast(msg: "Error generating PDF: $e");
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.business, color: Colors.blue),
                  title: Text(
                      widget.party == null
                          ? ""
                          : "Paying to: ${widget.party!.name}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(widget.party == null ? "" : widget.party!.gst),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Type',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showChargeTypeSheet(context),
                          child: RegisterField(
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              hint: otherCharge,
                              enabled: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now());
                            if (selectedDate != null) {
                              setState(() {
                                dateController.text = DateFormat('yyyy-MM-dd')
                                    .format(selectedDate);
                              });
                            }
                          },
                          child: IgnorePointer(
                            child: RegisterField(
                                controller: dateController,
                                hint: "Select Date"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deposit Amount',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        RegisterField(
                          controller: amountController,
                          hint: "Amount",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Method',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showPaymentMethodSheet(context),
                          child: RegisterField(
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                              hint: _paymentMethod,
                              enabled: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Description / Notes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              RegisterField(
                controller: descriptionController,
                hint: "Description",
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                  onTap: () {
                    // In a real app, you would save this payment record
                    Fluttertoast.showToast(msg: "Payment Added Successfully");
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 2);
                  },
                  text: "Save Payment"),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showChargeTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => ChargeTypeBottomSheet(
        onSelect: (selectedCharge) {
          setState(() => otherCharge = selectedCharge);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showPaymentMethodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => _PaymentMethodSheet(
        onSelect: (selectedMethod) {
          setState(() => _paymentMethod = selectedMethod);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // --- PDF Generation Logic ---
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final receiptNo =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final receiptDate = dateController.text.isNotEmpty
        ? dateController.text
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    final firstParty = {
      "companyName": "PAL SCAFFOLDING",
      "isoNumber": "(An ISO 9001:2015 Certifed Company)",
      "companyAddress":
          "PLOT NO 23 KHASRA NO 14/1 RANI LAXMI BAI NAGAR DUND HERA GHAZIABAD\n201009",
      "companyGst": "09ASJPP9292N1ZL",
      "companyPhones": ["9871227048"]
    };

    final headerAndAddress = await buildPdfHeaderAndAddressSection(
      challanNo: receiptNo,
      challanType: "Payment Receipt",
      date: receiptDate,
      companyName: firstParty["companyName"]!.toString(),
      companyAddress: firstParty["companyAddress"]!.toString(),
      companyGst: firstParty["companyGst"]!.toString(),
      isoNumber: firstParty["isoNumber"]!.toString(),
      phoneNumbers: firstParty["companyPhones"] as List<String>,
      billToName: "Elatio By Gards LLP",
      billToAddress: "",
      billToGst: "",
      billToMobile: "",
      shipToName: "",
      shipToAddress: "",
      shipToContact: "",
    );

    final footerSection = await buildPdfFooterSection("Payment Receipt", true);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              headerAndAddress,
              pw.SizedBox(height: 20),
              pw.Text('Payment Summary',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Divider(),
              pw.Table.fromTextArray(
                headers: ['Description', 'Details'],
                data: [
                  ['Payment For', otherCharge],
                  ['Payment Method', _paymentMethod],
                  if (descriptionController.text.isNotEmpty)
                    ['Notes', descriptionController.text],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                },
              ),
              pw.Spacer(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Amount Received:',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      pw.Text('${amountController.text}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 20,
                              color: PdfColors.green)),
                    ])
              ]),
              pw.SizedBox(height: 30),
              footerSection,
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<pw.Widget> buildPdfHeaderAndAddressSection({
    required String challanNo,
    required String challanType,
    required String date,
    required String companyName,
    required String isoNumber,
    required String companyAddress,
    required String companyGst,
    required List<String> phoneNumbers,
    required String billToName,
    required String billToAddress,
    required String billToGst,
    required String billToMobile,
    required String shipToName,
    required String shipToAddress,
    required String shipToContact,
    bool showShipTo = true,
  }) async {
    Uint8List? logoImage;
    Uint8List? nameImage;
    try {
      logoImage =
          (await rootBundle.load('images/logo.png')).buffer.asUint8List();
    } catch (e) {
      print("Could not load logo.png: $e");
    }
    try {
      nameImage =
          (await rootBundle.load('images/name.png')).buffer.asUint8List();
    } catch (e) {
      print("Could not load name.png: $e");
    }

    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoImage != null)
              pw.Image(pw.MemoryImage(logoImage), width: 80, height: 80),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (nameImage != null)
                    pw.Image(pw.MemoryImage(nameImage),
                        height: 80, width: 300, fit: pw.BoxFit.contain)
                  else
                    pw.Text(
                      companyName,
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                  pw.Text(isoNumber),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(challanType,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('No: $challanNo'),
                pw.Text('Date: $date'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
            },
            border: const pw.TableBorder(verticalInside: pw.BorderSide()),
            children: [
              pw.TableRow(
                children: [
                  _buildAddressBox('From:', [
                    pw.Text(companyAddress),
                    pw.Text('GST: $companyGst'),
                    pw.Wrap(
                      children: phoneNumbers
                          .map((number) => pw.Text(number))
                          .toList(),
                    ),
                  ]),
                  _buildAddressBox('Bill To:', [
                    pw.Text('M/S: $billToName'),
                    pw.Text('Address: $billToAddress'),
                    pw.Text('GST: $billToGst'),
                    pw.Text('Mobile: $billToMobile'),
                  ]),
                  _buildAddressBox('Ship To:', [
                    pw.Text('Name: $shipToName'),
                    pw.Text('Address: $shipToAddress'),
                    pw.Text('Contact: $shipToContact'),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAddressBox(String title, List<pw.Widget> children) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Divider(),
          ...children,
        ],
      ),
    );
  }

  Future<pw.Widget> buildPdfFooterSection(
      String challanType, bool withstamp) async {
    Uint8List? appLogoImage;
    Uint8List? stampImage;
    try {
      appLogoImage =
          (await rootBundle.load('images/logo.png')).buffer.asUint8List();
    } catch (e) {
      print("Could not load logo.png for footer: $e");
    }
    try {
      stampImage =
          (await rootBundle.load('images/stamp.jpeg')).buffer.asUint8List();
    } catch (e) {
      print("Could not load stamp.jpeg: $e");
    }

    final String termsAndConditions =
        "1. Our items are available for rent only, not for sale.\n2. In the event of a dispute, as a customer, you do not have the authority to prevent us from reclaiming our items.\n3. If any disputes arise between you and the building owner (or their representative), we shall not be held responsible.";
    final currentDateTime =
        DateFormat('dd-MMM-yyyy hh:mm a').format(DateTime.now());

    return pw.Column(
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  height: 100,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide())),
                  child: pw.Center(
                      child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                        if (appLogoImage != null)
                          pw.Image(pw.MemoryImage(appLogoImage),
                              width: 40, height: 40),
                        pw.SizedBox(height: 4),
                        pw.Text("Powered by\nScaffolding App India",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                color: PdfColors.blue,
                                fontWeight: pw.FontWeight.bold,
                                decoration: pw.TextDecoration.underline))
                      ])),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  height: 100,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(right: pw.BorderSide())),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [pw.Text('Customer Signature')]),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  height: 100,
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      if (stampImage != null && withstamp)
                        pw.Image(pw.MemoryImage(stampImage), height: 40),
                      pw.Spacer(),
                      pw.Text('Authorized Signature'),
                      pw.SizedBox(height: 5),
                      pw.Text(currentDateTime,
                          style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Terms & Conditions:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(termsAndConditions, textAlign: pw.TextAlign.justify),
            ],
          ),
        ),
      ],
    );
  }
}

class ChargeTypeBottomSheet extends StatelessWidget {
  final Function(String) onSelect;
  const ChargeTypeBottomSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final chargeTypes = [
      'Security Deposit',
      'Security Refund',
      'Security Adjust',
      'Bill Payment',
      'Site Visit Charge',
      'Payment Settlement',
      'TDS'
    ];
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Charge Type",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...chargeTypes
                .map((type) =>
                    ListTile(title: Text(type), onTap: () => onSelect(type)))
                .toList()
          ],
        ));
  }
}

class _PaymentMethodSheet extends StatelessWidget {
  final Function(String) onSelect;
  const _PaymentMethodSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final paymentMethods = [
      'Cash',
      'UPI',
      'RTGS',
      'NEFT',
      'IMPS',
      'Net Banking'
    ];
    return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...paymentMethods
                .map((type) =>
                    ListTile(title: Text(type), onTap: () => onSelect(type)))
                .toList()
          ],
        ));
  }
}
