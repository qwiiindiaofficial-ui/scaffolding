// lib/screens/LostItems.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/item.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/bills.dart';
// StockService
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';
import 'package:uuid/uuid.dart';

class LostItems extends StatefulWidget {
  const LostItems({super.key});

  @override
  State<LostItems> createState() => _LostItemsState();
}

class _LostItemsState extends State<LostItems> {
  // State variables
  DateTime _selectedDate = DateTime.now();
  String? _selectedChallanNo;
  LostItemType _selectedType = LostItemType.Short;

  List<StockItem> _stockItems = [];
  StockItem? _selectedStockItem;

  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();

  // Temporary list to hold entries before saving
  final List<LostItemEntry> _entries = [];

  // Mock challan numbers, aap ise apne real data se replace kar sakte hain
  final List<String> _challanOptions = [
    'Challan 101',
    'Challan 102',
    'Challan 103'
  ];

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _loadStockItems() async {
    final items = await StockService.getStockItems();
    setState(() {
      _stockItems = items;
    });
  }

  void _addEntryToList() {
    if (_selectedStockItem == null ||
        _quantityController.text.isEmpty ||
        _rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all item details.')));
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    final rate = double.tryParse(_rateController.text);

    if (quantity == null || rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter valid quantity and rate.')));
      return;
    }

    final newEntry = LostItemEntry(
      stockItemId: _selectedStockItem!.id,
      stockItemName: _selectedStockItem!.title,
      type: _selectedType,
      quantity: quantity,
      rate: rate,
      totalAmount: quantity * rate,
    );

    setState(() {
      _entries.add(newEntry);
      // Reset fields for next entry
      _selectedStockItem = null;
      _quantityController.clear();
      _rateController.clear();
    });
  }

  void _saveAllEntries() async {
    if (_selectedChallanNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a challan number.')));
      return;
    }
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item.')));
      return;
    }

    final newChallan = LostItemsChallan(
      id: const Uuid().v4(),
      originalChallanNo: _selectedChallanNo!,
      date: _selectedDate,
      entries: _entries,
    );

    await LostItemService.saveLostItemsChallan(newChallan);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lost/Repair items saved successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now());
              if (pickedDate != null) {
                setState(() => _selectedDate = pickedDate);
              }
            },
            icon: const Icon(Icons.date_range, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
                child: Text(DateFormat.yMMMd().format(_selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 16))),
          )
        ],
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
            text: "Short or Repairing items",
            color: ThemeColors.kWhiteTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
                text: 'In Which Challan?', size: 18, weight: FontWeight.w500),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  hintText: 'Select Challan No.',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              items: _challanOptions
                  .map((challan) =>
                      DropdownMenuItem(value: challan, child: Text(challan)))
                  .toList(),
              value: _selectedChallanNo,
              onChanged: (value) => setState(() => _selectedChallanNo = value),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Select Type:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Row(children: [
                  Radio<LostItemType>(
                      value: LostItemType.Short,
                      groupValue: _selectedType,
                      onChanged: (v) => setState(() => _selectedType = v!)),
                  const Text("Short")
                ]),
                Row(children: [
                  Radio<LostItemType>(
                      value: LostItemType.Repair,
                      groupValue: _selectedType,
                      onChanged: (v) => setState(() => _selectedType = v!)),
                  const Text("Repair")
                ]),
              ],
            ),
            const SizedBox(height: 16),
            const CustomText(
                text: 'Select Item', size: 18, weight: FontWeight.w500),
            const SizedBox(height: 8),
            DropdownButtonFormField<StockItem>(
              decoration: InputDecoration(
                  hintText: 'Select Items',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              value: _selectedStockItem,
              isExpanded: true,
              items: _stockItems.map((item) {
                return DropdownMenuItem<StockItem>(
                  value: item,
                  child: Text(
                      item.title), // Dropdown mein sirf naam dikhana behtar hai
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStockItem = value;
                  // Auto-fill the rate from stock item
                  _rateController.text = value?.rate.toString() ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: RegisterField(
                        hint: "Quantity",
                        controller: _quantityController,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 18),
                SizedBox(
                    width: 102,
                    child: RegisterField(
                        hint: "Rate",
                        controller: _rateController,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                IconButton.filled(
                    onPressed: _addEntryToList, icon: const Icon(Icons.add))
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text("Added Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text("No items added yet."))
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return Card(
                          child: ListTile(
                            title: Text(entry.stockItemName),
                            subtitle: Text(
                                'Qty: ${entry.quantity}, Rate: ${entry.rate}, Type: ${entry.type.name}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () =>
                                  setState(() => _entries.removeAt(index)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(onTap: _saveAllEntries, text: "Save All"),
          ],
        ),
      ),
    );
  }
}
