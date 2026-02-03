import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:scaffolding_sale/screens/purchase/service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PartyLedgerScreen extends StatefulWidget {
  final String partyName;

  const PartyLedgerScreen({super.key, required this.partyName});

  @override
  State<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends State<PartyLedgerScreen> {
  final PurchaseService _purchaseService = PurchaseService();

  String _filterType = 'All';
  DateTime? _startDate;
  DateTime? _endDate;
  List<LedgerEntry> _filteredEntries = [];
  List<LedgerEntry> _allEntries = [];

  @override
  void initState() {
    super.initState();
    _loadLedgerData();
  }

  void _loadLedgerData() {
    _allEntries = _purchaseService.getPartyLedger(widget.partyName);
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      if (_filterType == 'All') {
        _filteredEntries = List.from(_allEntries);
      } else if (_filterType == 'Today') {
        final today = DateTime.now();
        _filteredEntries = _allEntries.where((entry) {
          return entry.date.year == today.year &&
              entry.date.month == today.month &&
              entry.date.day == today.day;
        }).toList();
      } else if (_filterType == 'This Week') {
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(Duration(days: 6));
        _filteredEntries = _allEntries.where((entry) {
          return entry.date.isAfter(weekStart.subtract(Duration(days: 1))) &&
              entry.date.isBefore(weekEnd.add(Duration(days: 1)));
        }).toList();
      } else if (_filterType == 'This Month') {
        final now = DateTime.now();
        _filteredEntries = _allEntries.where((entry) {
          return entry.date.year == now.year && entry.date.month == now.month;
        }).toList();
      } else if (_filterType == 'Last Month') {
        final now = DateTime.now();
        final lastMonth = DateTime(now.year, now.month - 1);
        _filteredEntries = _allEntries.where((entry) {
          return entry.date.year == lastMonth.year &&
              entry.date.month == lastMonth.month;
        }).toList();
      } else if (_filterType == 'Custom' &&
          _startDate != null &&
          _endDate != null) {
        _filteredEntries = _allEntries.where((entry) {
          return entry.date.isAfter(_startDate!.subtract(Duration(days: 1))) &&
              entry.date.isBefore(_endDate!.add(Duration(days: 1)));
        }).toList();
      }
    });
  }

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
              title: Text('Filter Transactions'),
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
                      title: Text('Last Month'),
                      value: 'Last Month',
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

  Future<void> _generateAndSharePDF() async {
    final pdf = pw.Document();

    // Calculate totals
    double totalDebit = 0;
    double totalCredit = 0;
    for (var entry in _filteredEntries) {
      totalDebit += entry.debit;
      totalCredit += entry.credit;
    }
    double balance = totalDebit - totalCredit;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Party Ledger Statement',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    widget.partyName,
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Period: $_filterType',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Generated: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Box
            pw.Container(
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Purchases',
                          style: pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '₹${totalDebit.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Payments',
                          style: pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '₹${totalCredit.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Balance',
                          style: pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '₹${balance.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: balance > 0 ? PdfColors.red : PdfColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Transactions Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Date',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Type',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Ref No',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Debit',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Credit',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('Balance',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10),
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                // Data Rows
                ..._filteredEntries.map((entry) {
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          DateFormat('dd/MM/yy').format(entry.date),
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          entry.type,
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          entry.referenceNo,
                          style: pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          entry.debit > 0
                              ? '₹${entry.debit.toStringAsFixed(0)}'
                              : '-',
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          entry.credit > 0
                              ? '₹${entry.credit.toStringAsFixed(0)}'
                              : '-',
                          style: pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          '₹${entry.balance.toStringAsFixed(0)}',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    // Save and share PDF
    try {
      final output = await getTemporaryDirectory();
      final file = File(
          '${output.path}/ledger_${widget.partyName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Party Ledger - ${widget.partyName}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  void _showShareOptions() {
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
                'Share Ledger',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Share as PDF'),
                subtitle: Text('Generate and share PDF document'),
                onTap: () {
                  Navigator.pop(context);
                  _generateAndSharePDF();
                },
              ),
              ListTile(
                leading: Icon(Icons.preview, color: Colors.blue),
                title: Text('Preview PDF'),
                subtitle: Text('Preview before sharing'),
                onTap: () async {
                  Navigator.pop(context);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async {
                      final pdf = pw.Document();
                      // Same PDF generation code as above
                      // (You can extract this into a separate method)
                      return pdf.save();
                    },
                  );
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
    // Calculate totals from filtered entries
    double totalDebit = 0;
    double totalCredit = 0;
    for (var entry in _filteredEntries) {
      totalDebit += entry.debit;
      totalCredit += entry.credit;
    }
    double balance = totalDebit - totalCredit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Ledger'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _showShareOptions,
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Party Info Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.partyName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              _filterType,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_filteredEntries.length} Transactions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryColumn(
                          'Total Purchases', totalDebit, Colors.red),
                      _buildSummaryColumn(
                          'Total Payments', totalCredit, Colors.green),
                      _buildSummaryColumn('Balance', balance,
                          balance > 0 ? Colors.red : Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Ledger Header
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Type',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Ref No',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('Debit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text('Credit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text('Balance',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right)),
              ],
            ),
          ),

          // Ledger Entries
          Expanded(
            child: _filteredEntries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (_filterType != 'All')
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
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.white : Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey[300]!, width: 0.5),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat('dd/MM/yy').format(entry.date),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: entry.type == 'Purchase'
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.type,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: entry.type == 'Purchase'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.referenceNo,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.debit > 0
                                    ? '₹${entry.debit.toStringAsFixed(0)}'
                                    : '-',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red,
                                  fontWeight: entry.debit > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.credit > 0
                                    ? '₹${entry.credit.toStringAsFixed(0)}'
                                    : '-',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: entry.credit > 0
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${entry.balance.toStringAsFixed(0)}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: entry.balance > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
