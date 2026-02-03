import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/outward.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

// ============= MODELS =============
class GatePassModel {
  final String id;
  final DateTime dateTime;
  final String vehicleNo;
  final String kattaName;
  final List<GatePassItem> items;

  GatePassModel({
    required this.id,
    required this.dateTime,
    required this.vehicleNo,
    required this.kattaName,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'vehicleNo': vehicleNo,
        'kattaName': kattaName,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory GatePassModel.fromJson(Map<String, dynamic> json) => GatePassModel(
        id: json['id'],
        dateTime: DateTime.parse(json['dateTime']),
        vehicleNo: json['vehicleNo'],
        kattaName: json['kattaName'],
        items: (json['items'] as List)
            .map((e) => GatePassItem.fromJson(e))
            .toList(),
      );
}

class GatePassItem {
  final String itemName;
  int qty;
  double weight;
  double rate;

  GatePassItem({
    required this.itemName,
    required this.qty,
    required this.weight,
    required this.rate,
  });

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'qty': qty,
        'weight': weight,
        'rate': rate,
      };

  factory GatePassItem.fromJson(Map<String, dynamic> json) => GatePassItem(
        itemName: json['itemName'],
        qty: json['qty'],
        weight: json['weight'].toDouble(),
        rate: json['rate'].toDouble(),
      );
}

// ============= STORAGE SERVICE =============
class StorageService {
  static const String _gatePassKey = 'gate_passes';
  static const String _stockKey = 'stock_items';

  // Save Gate Pass
  static Future<void> saveGatePass(GatePassModel gatePass) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> gatePasses = prefs.getStringList(_gatePassKey) ?? [];
    gatePasses.add(jsonEncode(gatePass.toJson()));
    await prefs.setStringList(_gatePassKey, gatePasses);

    // Update stock
    // await _updateStock(gatePass.items, isAdding: true);
  }

  // Get all Gate Passes
  static Future<List<GatePassModel>> getAllGatePasses() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> gatePasses = prefs.getStringList(_gatePassKey) ?? [];
    return gatePasses
        .map((e) => GatePassModel.fromJson(jsonDecode(e)))
        .toList();
  }

  // Get Gate Pass by ID
  static Future<GatePassModel?> getGatePassById(String id) async {
    final gatePasses = await getAllGatePasses();
    try {
      return gatePasses.firstWhere((gp) => gp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update stock when gate pass is created or bill is received
  static Future<void> _updateStock(List<GatePassItem> items,
      {required bool isAdding}) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> stock = {};

    String? stockString = prefs.getString(_stockKey);
    if (stockString != null) {
      stock = jsonDecode(stockString);
    }

    for (var item in items) {
      int currentQty = stock[item.itemName] ?? 0;
      stock[item.itemName] =
          isAdding ? currentQty + item.qty : currentQty - item.qty;

      // Don't let stock go negative
      if (stock[item.itemName]! < 0) {
        stock[item.itemName] = 0;
      }
    }

    await prefs.setString(_stockKey, jsonEncode(stock));
  }

  // Get current stock
  static Future<Map<String, int>> getCurrentStock() async {
    final prefs = await SharedPreferences.getInstance();
    String? stockString = prefs.getString(_stockKey);
    if (stockString == null) return {};

    Map<String, dynamic> stockJson = jsonDecode(stockString);
    return stockJson.map((key, value) => MapEntry(key, value as int));
  }

  // Update stock after bill creation (deduct from stock)
  static Future<void> deductFromStock(List<GatePassItem> items) async {
    await _updateStock(items, isAdding: false);
  }
}

// ============= GATE PASS SCREEN =============
class GatePass extends StatefulWidget {
  const GatePass({super.key});

  @override
  State<GatePass> createState() => _GatePassState();
}

class _GatePassState extends State<GatePass> {
  String? selectedItem;
  DateTime? selectedDate;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _kattaNameController = TextEditingController();
  final List<Map<String, dynamic>> savedItems = [];
  final List<String> items = ['Standar 1.0m', 'Standar 1.5m'];

  @override
  void dispose() {
    _qtyController.dispose();
    _vehicleNoController.dispose();
    _kattaNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addItem() {
    if (selectedItem != null && _qtyController.text.isNotEmpty) {
      final qty = int.tryParse(_qtyController.text);
      if (qty == null || qty <= 0) {
        Fluttertoast.showToast(msg: "Please enter a valid quantity.");
        return;
      }
      setState(() {
        double randomWeight = (Random().nextDouble() * 5) + 5;
        double randomRate = (Random().nextDouble() * 100) + 150;

        savedItems.add({
          'item': selectedItem!,
          'Qty': qty,
          'weight': randomWeight,
          'rate': randomRate,
        });

        selectedItem = null;
        _qtyController.clear();
      });
      Fluttertoast.showToast(msg: "Item Added!");
    } else {
      Fluttertoast.showToast(msg: "Please select an item and enter quantity.");
    }
  }

  int _getTotalQty() {
    return savedItems.fold(0, (sum, item) => sum + (item['Qty'] as int));
  }

  double _getTotalWeight() {
    return savedItems.fold(
        0.0, (sum, item) => sum + (item['Qty'] * item['weight']));
  }

  void _navigateToEditScreen() async {
    if (savedItems.isEmpty) {
      Fluttertoast.showToast(msg: "Please add at least one item to save.");
      return;
    }

    await _saveGatePass();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditableTableScreen(
          initialItems: savedItems,
        ),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        savedItems.clear();
        savedItems.addAll(result);
      });
    }
  }

  Future<void> _saveGatePass() async {
    if (selectedDate == null) {
      Fluttertoast.showToast(msg: "Please select date and time");
      return;
    }

    // Generate Gate Pass ID
    final gatePasses = await StorageService.getAllGatePasses();
    final gatePassId =
        'GP${(gatePasses.length + 1).toString().padLeft(3, '0')}';

    // Create Gate Pass Model
    final items = savedItems
        .map((item) => GatePassItem(
              itemName: item['item'],
              qty: item['Qty'],
              weight: item['weight'],
              rate: item['rate'],
            ))
        .toList();

    final gatePass = GatePassModel(
      id: gatePassId,
      dateTime: selectedDate!,
      vehicleNo: _vehicleNoController.text,
      kattaName: _kattaNameController.text,
      items: items,
    );

    await StorageService.saveGatePass(gatePass);

    Fluttertoast.showToast(msg: "Gate Pass $gatePassId Saved Successfully!");

    // Clear all fields
    setState(() {
      savedItems.clear();
      selectedDate = null;
      _vehicleNoController.clear();
      _kattaNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Gate Pass", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Select Date',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () => _selectDateTime(context),
                ),
                const Spacer(),
                if (selectedDate != null)
                  Text(
                    "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} "
                    "${selectedDate!.hour}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                const Spacer(),
                const Text('GP01',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            // const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: _vehicleNoController,
            //         decoration: InputDecoration(
            //           hintText: "Vehicle No.",
            //           border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(8)),
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 12, vertical: 14),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     Expanded(
            //       child: TextField(
            //         controller: _kattaNameController,
            //         decoration: InputDecoration(
            //           hintText: "Katta Name",
            //           border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(8)),
            //           contentPadding: const EdgeInsets.symmetric(
            //               horizontal: 12, vertical: 14),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Select Item',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 12.0),
                    ),
                    value: selectedItem,
                    items: items.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Qty",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: _addItem,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: savedItems.isEmpty
                  ? const Center(child: Text("No items added yet."))
                  : ListView.builder(
                      itemCount: savedItems.length,
                      itemBuilder: (context, index) {
                        final item = savedItems[index];
                        return Dismissible(
                          key: ValueKey(item['item'] + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            setState(() {
                              savedItems.removeAt(index);
                            });
                            Fluttertoast.showToast(msg: "Item removed");
                          },
                          child: Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(item['item']!),
                              trailing: Text("Qty: ${item['Qty']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //     'Approx Weight: ${_getTotalWeight().toStringAsFixed(2)} Kg',
                //     style: const TextStyle(
                //         fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Total Qty: ${_getTotalQty()}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToEditScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Save All",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============= EDITABLE TABLE SCREEN =============
class EditableTableScreen extends StatefulWidget {
  final List<Map<String, dynamic>> initialItems;

  const EditableTableScreen({Key? key, required this.initialItems})
      : super(key: key);

  @override
  State<EditableTableScreen> createState() => _EditableTableScreenState();
}

class _EditableTableScreenState extends State<EditableTableScreen> {
  late List<Map<String, dynamic>> editableItems;
  late List<List<TextEditingController>> _controllers;

  @override
  void initState() {
    super.initState();
    editableItems = widget.initialItems
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    _controllers = editableItems.map((item) {
      return [
        TextEditingController(text: item['item'].toString()),
        TextEditingController(text: item['Qty'].toString()),
      ];
    }).toList();
  }

  @override
  void dispose() {
    for (var controllerList in _controllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  int _getTotalQty() {
    return editableItems.fold(
        0, (sum, item) => sum + (int.tryParse(item['Qty'].toString()) ?? 0));
  }

  double _getTotalWeight() {
    return editableItems.fold(
        0.0,
        (sum, item) =>
            sum +
            ((double.tryParse(item['weight'].toString()) ?? 0.0) *
                (int.tryParse(item['Qty'].toString()) ?? 0)));
  }

  double _getTotalAmount() {
    return editableItems.fold(
        0.0,
        (sum, item) =>
            sum +
            ((double.tryParse(item['rate'].toString()) ?? 0.0) *
                (int.tryParse(item['Qty'].toString()) ?? 0)));
  }

  void _updateItemValue(int rowIndex, int colIndex, String value) {
    final key = ['item', 'Qty', 'weight', 'rate'][colIndex];
    dynamic parsedValue = value;
    if (key == 'Qty') {
      parsedValue = int.tryParse(value) ?? 0;
    } else if (key == 'weight' || key == 'rate') {
      parsedValue = double.tryParse(value) ?? 0.0;
    }

    setState(() {
      editableItems[rowIndex][key] = parsedValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Edit Items", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnSpacing: 40,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.grey.shade200),
                  columns: const [
                    DataColumn(label: Text('Item Name')),
                    DataColumn(label: Text('Qty')),
                  ],
                  rows: [
                    ...List.generate(editableItems.length, (index) {
                      return DataRow(cells: [
                        DataCell(SizedBox(
                          width: 280,
                          child: TextFormField(
                            controller: _controllers[index][0],
                            onChanged: (value) =>
                                _updateItemValue(index, 0, value),
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          ),
                        )),
                        DataCell(SizedBox(
                          width: 60,
                          child: TextFormField(
                            controller: _controllers[index][1],
                            keyboardType: TextInputType.number,
                            onChanged: (value) =>
                                _updateItemValue(index, 1, value),
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          ),
                        )),
                      ]);
                    }),
                    DataRow(
                      color: WidgetStateProperty.all(Colors.blue.shade50),
                      cells: [
                        const DataCell(Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text('${_getTotalQty()}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showChallanTransportSheet(context);

                  Navigator.pop(context, editableItems);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Confirm & Save",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ============= BILLS SCREEN =============
class PreviewGatePass extends StatefulWidget {
  const PreviewGatePass({super.key});

  @override
  State<PreviewGatePass> createState() => _PreviewGatePassState();
}

class _PreviewGatePassState extends State<PreviewGatePass> {
  String? selectedGatePassId;
  String? selectedBillNo;

  List<GatePassModel> availableGatePasses = [];
  List<String> availableBillNo = ["1"];

  List<GatePassItem> billItems = [];
  Map<String, int> currentStock = {};

  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  // Kaanta Weight Controllers
  final TextEditingController _kaantaItemController = TextEditingController();
  final TextEditingController _kaantaQtyController = TextEditingController();
  final TextEditingController _kaantaRateController = TextEditingController();
  final TextEditingController _kaantaValueController = TextEditingController();
  final TextEditingController _kaantaHsnController = TextEditingController();
  String? selectedGstType;
  String? selectedUnit;

  String? selectedItem;
  final List<String> items = [
    'Standar 1.0m',
    'Standar 1.5m',
  ];

  // GST Types with percentage in brackets
  final List<Map<String, dynamic>> gstOptions = [
    {'label': 'IGST (18%)', 'type': 'IGST', 'percentage': 18.0},
    {
      'label': 'CGST+SGST (9%+9%)',
      'type': 'CGST+SGST',
      'percentage': 18.0,
      'isSplit': true
    },
    {'label': 'GST Free (0%)', 'type': 'GST Free', 'percentage': 0.0},
  ];

  final List<String> units = ['Pcs', 'Kgs'];

  double _gstPercentage = 0.0;
  bool _isSplitGst = false;

  @override
  void initState() {
    super.initState();
    _loadGatePasses();
    _loadStock();
  }

  @override
  void dispose() {
    _billNoController.dispose();
    _qtyController.dispose();
    _kaantaItemController.dispose();
    _kaantaQtyController.dispose();
    _kaantaRateController.dispose();
    _kaantaValueController.dispose();
    _kaantaHsnController.dispose();
    super.dispose();
  }

  Future<void> _loadGatePasses() async {
    final gatePasses = await StorageService.getAllGatePasses();
    setState(() {
      availableGatePasses = gatePasses;
    });
  }

  void _calculateKaantaValue() {
    final qty = double.tryParse(_kaantaQtyController.text) ?? 0;
    final rate = double.tryParse(_kaantaRateController.text) ?? 0;
    final value = qty * rate;
    _kaantaValueController.text = value.toStringAsFixed(2);
  }

  double _getGstAmount() {
    final taxableValue = double.tryParse(_kaantaValueController.text) ?? 0;
    return (taxableValue * _gstPercentage) / 100;
  }

  double _getCgstAmount() {
    if (!_isSplitGst) return 0;
    final taxableValue = double.tryParse(_kaantaValueController.text) ?? 0;
    return (taxableValue * 9) / 100;
  }

  double _getSgstAmount() {
    if (!_isSplitGst) return 0;
    final taxableValue = double.tryParse(_kaantaValueController.text) ?? 0;
    return (taxableValue * 9) / 100;
  }

  double _getGrandTotal() {
    final taxableValue = double.tryParse(_kaantaValueController.text) ?? 0;
    final gstAmount = _getGstAmount();
    return taxableValue + gstAmount;
  }

  Future<void> _loadStock() async {
    final stock = await StorageService.getCurrentStock();
    setState(() {
      currentStock = stock;
    });
  }

  void _receiveAllFromGatePass() async {
    if (selectedGatePassId == null) {
      Fluttertoast.showToast(msg: "Please select a Gate Pass first");
      return;
    }

    final gatePass = await StorageService.getGatePassById(selectedGatePassId!);
    if (gatePass == null) {
      Fluttertoast.showToast(msg: "Gate Pass not found");
      return;
    }

    setState(() {
      billItems = List.from(gatePass.items);
    });

    Fluttertoast.showToast(msg: "All items from ${gatePass.id} added to bill");
  }

  void _addManualItem() {
    if (selectedItem == null || _qtyController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please select item and enter quantity");
      return;
    }

    final qty = int.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      Fluttertoast.showToast(msg: "Please enter valid quantity");
      return;
    }

    // Check stock availability
    final availableStock = currentStock[selectedItem] ?? 0;
    if (availableStock < qty) {
      Fluttertoast.showToast(
          msg: "Insufficient stock! Available: $availableStock");
      return;
    }

    setState(() {
      // Check if item already exists in bill
      final existingIndex =
          billItems.indexWhere((item) => item.itemName == selectedItem);

      if (existingIndex != -1) {
        billItems[existingIndex].qty += qty;
      } else {
        billItems.add(GatePassItem(
          itemName: selectedItem!,
          qty: qty,
          weight: (Random().nextDouble() * 5) + 5,
          rate: (Random().nextDouble() * 100) + 150,
        ));
      }

      selectedItem = null;
      _qtyController.clear();
    });

    Fluttertoast.showToast(msg: "Item added to bill");
  }

  int _getTotalQty() {
    return billItems.fold(0, (sum, item) => sum + item.qty);
  }

  double _getTotalWeight() {
    return billItems.fold(0.0, (sum, item) => sum + (item.qty * item.weight));
  }

  double _getTotalAmount() {
    return billItems.fold(0.0, (sum, item) => sum + (item.qty * item.rate));
  }

  void _showKaantaWeightBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Item Name & Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _kaantaItemController,
                            decoration: InputDecoration(
                              hintText: "Item Name & Description",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _kaantaHsnController,
                            decoration: InputDecoration(
                              hintText: "HSN Code",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _kaantaQtyController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setModalState(() {
                                _calculateKaantaValue();
                              });
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: "Qty",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: 'Unit',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            value: selectedUnit,
                            items: units.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() {
                                selectedUnit = value;
                              });
                              setState(() {
                                selectedUnit = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _kaantaRateController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setModalState(() {
                                _calculateKaantaValue();
                              });
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: "Rate",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _kaantaValueController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Taxable Value",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: 'GST Type',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            value: selectedGstType,
                            items: gstOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option['type'],
                                child: Text(option['label']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setModalState(() {
                                selectedGstType = value;
                                final option = gstOptions.firstWhere(
                                  (opt) => opt['type'] == value,
                                  orElse: () =>
                                      {'percentage': 0.0, 'isSplit': false},
                                );
                                _gstPercentage = option['percentage'] as double;
                                _isSplitGst = option['isSplit'] ?? false;
                              });
                              setState(() {
                                selectedGstType = value;
                                final option = gstOptions.firstWhere(
                                  (opt) => opt['type'] == value,
                                  orElse: () =>
                                      {'percentage': 0.0, 'isSplit': false},
                                );
                                _gstPercentage = option['percentage'] as double;
                                _isSplitGst = option['isSplit'] ?? false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.blue.shade200, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Taxable Value:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "₹ ${_kaantaValueController.text.isEmpty ? '0.00' : _kaantaValueController.text}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_isSplitGst) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "CGST (9%):",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹ ${_getCgstAmount().toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "SGST (9%):",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹ ${_getSgstAmount().toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${selectedGstType ?? 'GST'} ($_gstPercentage%):",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "₹ ${_getGstAmount().toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Grand Total:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                "₹ ${_getGrandTotal().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _saveBill();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Save PI",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveBill() async {
    if (billItems.isEmpty) {
      Fluttertoast.showToast(msg: "Please add items to the bill");
      return;
    }

    Fluttertoast.showToast(
        msg: "PI ${_billNoController.text} saved successfully!");

    Navigator.pop(context);
    setState(() {
      billItems.clear();
      _billNoController.clear();
      selectedGatePassId = null;
      _kaantaItemController.clear();
      _kaantaQtyController.clear();
      _kaantaRateController.clear();
      _kaantaValueController.clear();
      _kaantaHsnController.clear();
      selectedGstType = null;
      selectedUnit = null;
      _gstPercentage = 0.0;
      _isSplitGst = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Bills", style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _receiveAllFromGatePass,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Receive All',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'PI No.',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                    value: selectedBillNo,
                    items: availableBillNo.map((gp) {
                      return DropdownMenuItem<String>(
                        value: gp,
                        child: Text(gp),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBillNo = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Gate Pass',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                    value: selectedGatePassId,
                    items: availableGatePasses.map((gp) {
                      return DropdownMenuItem<String>(
                        value: gp.id,
                        child: Text(gp.id),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGatePassId = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Select Item',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                    ),
                    value: selectedItem,
                    items: items.map((String value) {
                      final stock = currentStock[value] ?? 0;
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text("$value (Stock: $stock)"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Qty",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: _addManualItem,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: billItems.isEmpty
                  ? const Center(
                      child: Text(
                          "No items in bill yet.\nUse 'Receive All' or add items manually.",
                          textAlign: TextAlign.center))
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text("Item Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              Expanded(
                                  flex: 1,
                                  child: Text("Qty",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: billItems.length,
                            itemBuilder: (context, index) {
                              final item = billItems[index];
                              return Dismissible(
                                key: ValueKey(item.itemName + index.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  setState(() {
                                    billItems.removeAt(index);
                                  });
                                  Fluttertoast.showToast(msg: "Item removed");
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade300)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 3, child: Text(item.itemName)),
                                      Expanded(
                                          flex: 1,
                                          child: Text("${item.qty}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(8)),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                  flex: 3,
                                  child: Text("Total",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                              Expanded(
                                  flex: 1,
                                  child: Text("${_getTotalQty()}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16))),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (billItems.isEmpty) {
                    Fluttertoast.showToast(msg: "Please add items to the bill");
                    return;
                  }
                  _showKaantaWeightBottomSheet();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Save PI",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
