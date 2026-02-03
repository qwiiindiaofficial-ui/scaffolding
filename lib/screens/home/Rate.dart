// lib/screens/rate.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:scaffolding_sale/screens/home/item.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class Rate extends StatefulWidget {
  const Rate({super.key});

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {
  // State variables
  List<StockItem> _stockItems = [];
  StockItem? _selectedItem;
  bool _isLoading = true;

  // Text editing controllers (ab rent aur sale ke liye alag)
  final TextEditingController _rentRateController = TextEditingController();
  final TextEditingController _saleRateController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  @override
  void dispose() {
    _rentRateController.dispose();
    _saleRateController.dispose();
    _sizeController.dispose();
    _unitController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _loadStockItems() async {
    setState(() => _isLoading = true);
    final items = await StockService.getStockItems();
    setState(() {
      _stockItems = items;
      _isLoading = false;
    });
  }

  void _onItemSelected(StockItem? item) {
    if (item == null) return;
    setState(() {
      _selectedItem = item;
      // FIX 2: Dono rate controllers ko populate karein
      _rentRateController.text = item.rate.toString();
      _saleRateController.text = item.saleRate.toString();
      _sizeController.text = item.size;
      _qtyController.text = item.quantity.toString();
      _unitController.text = "pcs";
    });
  }

  Future<void> _submitChanges() async {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item first.')),
      );
      return;
    }

    // FIX 2: Dono rates ko controllers se parse karein
    final double? rentRate = double.tryParse(_rentRateController.text);
    final double? saleRate = double.tryParse(_saleRateController.text);
    final int? quantity = int.tryParse(_qtyController.text);

    if (rentRate == null || saleRate == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter valid numbers for rates and quantity.')),
      );
      return;
    }

    final updatedItem = _selectedItem!.copyWith(
      rate: rentRate, // Rent Rate
      saleRate: saleRate, // Sale Rate
      quantity: quantity,
      size: _sizeController.text,
      available: quantity - _selectedItem!.dispatch,
    );

    await StockService.updateStockItem(updatedItem);
    await _loadStockItems(); // List ko refresh karein

    // FIX 1: Dropdown error se bachne ke liye _selectedItem ko nayi list se update karein
    setState(() {
      // Usi item ko ID se dhoondhein jo abhi update hua hai
      _selectedItem = _stockItems.firstWhere(
          (item) => item.id == updatedItem.id,
          orElse: () => StockItem(
              id: "45",
              image: "image",
              title: "title",
              category: "category",
              size: "size",
              quantity: quantity,
              rate: 2,
              saleRate: saleRate,
              weight: 2,
              value: 2,
              available: 2,
              dispatch: 2));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rate updated successfully!')),
    );
  }

  Future<void> _generateAndSharePdf() async {
    final items = await StockService.getStockItems();
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Stock Items Rate List',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Table.fromTextArray(
            headers: ['Item Name', 'Size', 'Rent Rate (Per Day)', 'Sale Rate'],
            data: items
                .map((item) => [
                      item.title,
                      item.size,
                      (item.rate.toStringAsFixed(2)),
                      (item.saleRate.toStringAsFixed(2))
                    ])
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellStyle: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/updated_rates.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Rate', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            // FIX 3: Button ka text change kiya gaya
            label: CustomText(
              text: "View/Share PDF",
              size: 12,
              color: ThemeColors.kWhiteTextColor,
              weight: FontWeight.w500,
            ),
            onPressed: _generateAndSharePdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                        text: "Select Item", weight: FontWeight.w600),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<StockItem>(
                      value: _selectedItem,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      hint: const Text('Select an item'),
                      items: _stockItems.map((StockItem item) {
                        return DropdownMenuItem<StockItem>(
                          value: item,
                          child: Text(item.title),
                        );
                      }).toList(),
                      onChanged: _onItemSelected,
                    ),
                    const SizedBox(height: 20),

                    // FIX 2: Rent Rate aur Sale Rate ke liye alag fields
                    const Row(
                      children: [
                        Expanded(
                            child: Text('Rent Rate',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(width: 14),
                        Expanded(
                            child: Text('Sale Rate',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                                controller: _rentRateController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'Rent Rate (Per Day)',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))))),
                        const SizedBox(width: 14.0),
                        Expanded(
                            child: TextFormField(
                                controller: _saleRateController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'Sale Rate',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))))),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Expanded(
                            child: Text('Size',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(width: 14),
                        Expanded(
                            child: Text('Qty',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                                controller: _sizeController,
                                decoration: InputDecoration(
                                    hintText: 'Write Size',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))))),
                        const SizedBox(width: 14.0),
                        Expanded(
                            child: TextFormField(
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'Write Qty',
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))))),
                      ],
                    ),
                    const SizedBox(height: 60.0),

                    Center(
                      child: ElevatedButton(
                        onPressed: _submitChanges,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: ThemeColors.kSecondaryThemeColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 120),
                        ),
                        child: const Text('Submit',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
    );
  }
}
