import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class CalculatorHistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> calculationHistory;
  final Function(List<Map<String, dynamic>>) onHistoryUpdated;

  const CalculatorHistoryScreen({
    Key? key,
    required this.calculationHistory,
    required this.onHistoryUpdated,
  }) : super(key: key);

  @override
  _CalculatorHistoryScreenState createState() =>
      _CalculatorHistoryScreenState();
}

class _CalculatorHistoryScreenState extends State<CalculatorHistoryScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<bool> selectedItems = [];
  bool selectAll = false;
  bool isLoading = false;
  String searchQuery = '';
  String sortBy = 'date'; // 'date', 'name', 'value'
  bool sortAscending = false;

  // Constants
  final String historyKey = 'calculation_history';

  @override
  void initState() {
    super.initState();
    selectedItems =
        List.generate(widget.calculationHistory.length, (_) => false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CalculatorHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.calculationHistory.length !=
        widget.calculationHistory.length) {
      _updateSelectedItemsList();
    }
  }

  void _updateSelectedItemsList() {
    setState(() {
      selectedItems =
          List.generate(widget.calculationHistory.length, (_) => false);
      selectAll = false;
    });
  }

  // Helper function to format numbers without unnecessary decimals
  String _formatNumber(dynamic value) {
    if (value == null) return '0';

    double? doubleValue = double.tryParse(value.toString());
    if (doubleValue == null) return value.toString();

    // Check if the number is a whole number
    if (doubleValue == doubleValue.truncate()) {
      return doubleValue.toInt().toString();
    } else {
      // Return with 2 decimal places if it has decimal part
      return doubleValue.toInt().toString();
    }
  }

  Map<String, dynamic> _sanitizeCalculation(Map<String, dynamic> calculation) {
    try {
      return {
        'name': calculation['name'] ?? 'Unnamed',
        'timestamp':
            calculation['timestamp'] ?? DateTime.now().toIso8601String(),
        'isAreaBased': calculation['isAreaBased'] ?? false,
        'items': (calculation['items'] as List<dynamic>?)?.map((item) {
              return {
                'itemName': item['itemName'] ?? 'Unknown Item',
                'length': item['length']?.toString() ?? '0',
                'width': item['width']?.toString() ?? '0',
                'height': item['height']?.toString() ?? '0',
                'area': item['area']?.toString() ?? '0',
                'quantity': item['quantity']?.toString() ?? '0',
                'weightKg': item['weightKg']?.toString() ?? '0',
                'ratePerKg': item['ratePerKg']?.toString() ?? '0',
                'rentPerDay': item['rentPerDay']?.toString() ?? '0',
                'goodValue': item['goodValue']?.toString() ?? '0',
              };
            }).toList() ??
            [],
        'totals': {
          'area': calculation['totals']?['area'] ?? 0.0,
          'quantity': calculation['totals']?['quantity'] ?? 0,
          'weightKg': calculation['totals']?['weightKg'] ?? 0.0,
          'rentPerDay': calculation['totals']?['rentPerDay'] ?? 0,
          'goodValue': calculation['totals']?['goodValue'] ?? 0.0,
        },
      };
    } catch (e) {
      print('Error sanitizing calculation: $e');
      return {
        'name': 'Error in Data',
        'timestamp': DateTime.now().toIso8601String(),
        'isAreaBased': false,
        'items': [],
        'totals': {
          'area': 0.0,
          'quantity': 0,
          'weightKg': 0.0,
          'rentPerDay': 0,
          'goodValue': 0.0,
        },
      };
    }
  }

  Future<void> _deleteSelected() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete the selected items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> updatedHistory = [];
      for (int i = 0; i < widget.calculationHistory.length; i++) {
        if (!selectedItems[i]) {
          updatedHistory.add(widget.calculationHistory[i]);
        }
      }

      // Update SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(historyKey, json.encode(updatedHistory));

      // Update parent state
      widget.onHistoryUpdated(updatedHistory);

      // Update local state
      setState(() {
        selectedItems = List.generate(updatedHistory.length, (_) => false);
        selectAll = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected items deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting items: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<List<String>> _generateTableData(Map<String, dynamic> calculation) {
    try {
      final List<dynamic> rawItems = calculation['items'] ?? [];
      final List<Map<String, dynamic>> items = rawItems
          .map((item) =>
              item is Map<String, dynamic> ? item : <String, dynamic>{})
          .toList();
      final bool isAreaBased = calculation['isAreaBased'] ?? false;

      return items.map((item) {
        if (isAreaBased) {
          return [
            item['itemName']?.toString() ?? '',
            '${item['length'] ?? 0}×${item['width'] ?? 0}×${item['height'] ?? 0}',
            _formatNumber(item['area']),
            item['ratePerKg']?.toString() ?? '0',
            item['rentPerDay']?.toString() ?? '0',
            _formatNumber(item['goodValue']),
          ];
        } else {
          return [
            item['itemName']?.toString() ?? '',
            item['quantity']?.toString() ?? '0',
            _formatNumber(item['weightKg']),
            item['ratePerKg']?.toString() ?? '0',
            item['rentPerDay']?.toString() ?? '0',
            _formatNumber(item['goodValue']),
          ];
        }
      }).toList();
    } catch (e) {
      print('Error generating table data: $e');
      return [
        ['Error generating table data']
      ];
    }
  }

  List<Map<String, dynamic>> getSortedHistory() {
    List<Map<String, dynamic>> filteredList =
        List.from(widget.calculationHistory);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((calc) =>
              calc['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              calc['items'].any((item) => item['itemName']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase())))
          .toList();
    }

    // Apply sorting
    filteredList.sort((a, b) {
      switch (sortBy) {
        case 'date':
          return sortAscending
              ? DateTime.parse(a['timestamp'])
                  .compareTo(DateTime.parse(b['timestamp']))
              : DateTime.parse(b['timestamp'])
                  .compareTo(DateTime.parse(a['timestamp']));
        case 'name':
          return sortAscending
              ? (a['name'] ?? '').compareTo(b['name'] ?? '')
              : (b['name'] ?? '').compareTo(a['name'] ?? '');
        case 'value':
          return sortAscending
              ? (a['totals']['goodValue'] as num)
                  .compareTo(b['totals']['goodValue'] as num)
              : (b['totals']['goodValue'] as num)
                  .compareTo(a['totals']['goodValue'] as num);
        default:
          return 0;
      }
    });

    return filteredList;
  }

  Future<void> _generatePDF(Map<String, dynamic> calculation) async {
    setState(() => isLoading = true);
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            List<List<String>> tableData = _generateTableData(calculation);
            if (calculation['isAreaBased']) {
              tableData.add([
                'Total',
                '',
                '${_formatNumber(calculation['totals']['area'])} m³',
                '',
                '₹${calculation['totals']['rentPerDay']}',
                '₹${_formatNumber(calculation['totals']['goodValue'])}',
              ]);
            } else {
              tableData.add([
                'Total',
                '${calculation['totals']['quantity']}',
                '${_formatNumber(calculation['totals']['weightKg'])} kg',
                '',
                '${calculation['totals']['rentPerDay']}',
                _formatNumber(calculation['totals']['goodValue']),
              ]);
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Website link at top
                pw.Center(
                  child: pw.UrlLink(
                    destination: 'https://scaffoldingappindia.com',
                    child: pw.Text(
                      'Created by scaffoldingappindia.com',
                      style: pw.TextStyle(
                        color: PdfColors.blue,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                pw.SizedBox(height: 10),

                // Header with First Party and Client Details - Fixed height containers
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // First Party Details (Left Side)
                    pw.Container(
                      width: 200,
                      height: 120, // Fixed height
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('First Party',
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text('Your Company Name'),
                          pw.Text('Address Line 1'),
                          pw.Text('Address Line 2'),
                          pw.Text('Phone: +91 XXXXXXXXXX'),
                          pw.Text('Email: example@email.com'),
                        ],
                      ),
                    ),

                    // Client Details (Right Side)
                    pw.Container(
                      width: 200,
                      height: 120, // Fixed height - same as left container
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Client Details',
                              style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text('Name: ${calculation['name']}'),
                          pw.Text(
                              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(calculation['timestamp']))}'),
                          pw.Text(
                              'Calculation Type: ${calculation['isAreaBased'] ? 'Area Based' : 'Item Based'}'),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 10),

                // Title
                pw.Center(
                  child: pw.Text('Scaffolding Calculation',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),

                pw.SizedBox(height: 10),

                // Items Table with Totals
                pw.Table.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.center,
                    3: pw.Alignment.center,
                    4: pw.Alignment.center,
                    5: pw.Alignment.center,
                  },
                  headers: calculation['isAreaBased']
                      ? [
                          'Item',
                          'Dimensions',
                          'Area (m³)',
                          'Rate/m³',
                          'Rent/Day',
                          'Amount'
                        ]
                      : [
                          'Item',
                          'Qty',
                          'Weight',
                          'Rate/kg',
                          'Rent/Day',
                          'Amount'
                        ],
                  data: tableData,
                ),

                // Footer
                pw.Positioned(
                  bottom: 20,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('Thank you for your business!'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save and open the PDF
      final output = await getApplicationDocumentsDirectory();
      final String fileName =
          'Scaffolding_${calculation['name']}_${DateFormat('dd_MM_yyyy_HH_mm').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');

      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        await OpenFile.open(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved and opened successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedHistory = getSortedHistory();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Calculation History',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Sort By'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Date'),
                          leading: Radio<String>(
                            value: 'date',
                            groupValue: sortBy,
                            onChanged: (String? value) {
                              setState(() {
                                sortBy = value!;
                                if (sortBy == 'date')
                                  sortAscending = !sortAscending;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Name'),
                          leading: Radio<String>(
                            value: 'name',
                            groupValue: sortBy,
                            onChanged: (String? value) {
                              setState(() {
                                sortBy = value!;
                                if (sortBy == 'name')
                                  sortAscending = !sortAscending;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Value'),
                          leading: Radio<String>(
                            value: 'value',
                            groupValue: sortBy,
                            onChanged: (String? value) {
                              setState(() {
                                sortBy = value!;
                                if (sortBy == 'value')
                                  sortAscending = !sortAscending;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          if (selectedItems.contains(true))
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or item...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              if (widget.calculationHistory.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectAll,
                        onChanged: (bool? value) {
                          setState(() {
                            selectAll = value ?? false;
                            selectedItems = List.generate(
                                widget.calculationHistory.length,
                                (_) => selectAll);
                          });
                        },
                      ),
                      const Text('Select All'),
                      const Spacer(),
                      Text('${sortedHistory.length} items'),
                    ],
                  ),
                ),

              Expanded(
                child: sortedHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('No calculation history available',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: sortedHistory.length,
                        itemBuilder: (context, index) {
                          final calculation =
                              _sanitizeCalculation(sortedHistory[index]);
                          final DateTime timestamp =
                              DateTime.parse(calculation['timestamp']);
                          final bool isAreaBased = calculation['isAreaBased'];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ExpansionTile(
                              leading: Checkbox(
                                value: selectedItems[widget.calculationHistory
                                    .indexOf(sortedHistory[index])],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedItems[widget.calculationHistory
                                            .indexOf(sortedHistory[index])] =
                                        value ?? false;
                                    selectAll =
                                        selectedItems.every((item) => item);
                                  });
                                },
                              ),
                              title: Text(calculation['name'] ?? 'Unnamed',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy HH:mm')
                                      .format(timestamp)),
                                  const SizedBox(height: 4),
                                  if (isAreaBased)
                                    Text(
                                        'Total Area: ${_formatNumber(calculation['totals']['area'])} m³')
                                  else
                                    Text(
                                        'Total Weight: ${_formatNumber(calculation['totals']['weightKg'])} kg'),
                                  Text(
                                      'Total Value: ₹${_formatNumber(calculation['totals']['goodValue'])}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.print),
                                    onPressed: () => _generatePDF(calculation),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Share functionality coming soon'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: [
                                      const DataColumn(label: Text('Item')),
                                      if (isAreaBased) ...[
                                        const DataColumn(
                                            label: Text('Dimensions')),
                                        const DataColumn(label: Text('Area')),
                                      ] else ...[
                                        const DataColumn(label: Text('Qty')),
                                        const DataColumn(label: Text('Weight')),
                                      ],
                                      const DataColumn(label: Text('Value')),
                                    ],
                                    rows:
                                        (calculation['items'] as List<dynamic>)
                                            .map<DataRow>((item) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(
                                              item['itemName']?.toString() ??
                                                  '')),
                                          if (isAreaBased) ...[
                                            DataCell(Text(
                                                '${item['length']}×${item['width']}×${item['height']}')),
                                            DataCell(Text(
                                                '${_formatNumber(item['area'])} m³')),
                                          ] else ...[
                                            DataCell(Text(
                                                item['quantity']?.toString() ??
                                                    '0')),
                                            DataCell(Text(
                                                '${_formatNumber(item['weightKg'])} kg')),
                                          ],
                                          DataCell(Text(
                                              '₹${_formatNumber(item['goodValue'])}')),
                                        ],
                                      );
                                    }).toList(),
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
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
