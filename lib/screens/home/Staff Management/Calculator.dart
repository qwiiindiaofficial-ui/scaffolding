import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/calculator_history.dart';
import 'package:scaffolding_sale/screens/home/stock.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  // Static stock data with item weights
  final Map<String, Map<String, double>> stockData = {
    'Standar': {'pcWeight': 0.5},
    'Coupler': {'pcWeight': 4.2},
    'U-Jack Head': {'pcWeight': 8.5},
    // 'Challie mt': {'pcWeight': 3.0},
    // 'Base/Jack': {'pcWeight': 3.5},
  };

  // Static area types
  final List<String> areaTypes = [
    'Add Name',
    'Scaffolding Fixing',
    'Shuttering Closing',
    'Shuttering Fixing & Closing',
    'Scaffolding Set',
    'Wheel Set',
    'H-Frame',
    'Alumunium Scaffolding Set',
  ];

  List<CalculatedItem> calculatedItems = [];
  List<Map<String, dynamic>> calculationHistory = [];
  final String historyKey = 'calculation_history';

  String? selectedItem;
  String? selectedAreaType;
  bool isAreaBasedCalculation = false;
  bool isRentCalculation = false;

  // Controllers for input fields
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(historyKey);
    if (historyJson != null) {
      setState(() {
        calculationHistory =
            List<Map<String, dynamic>>.from(json.decode(historyJson));
      });
    }
  }

  Future<void> saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentCalculation = {
      'timestamp': DateTime.now().toIso8601String(),
      'name': nameController.text,
      'isAreaBased': isAreaBasedCalculation,
      'isRentCalculation': isRentCalculation,
      'items': calculatedItems
          .map((item) => {
                'itemName': item.itemName,
                'quantity': item.quantity,
                'rentPerDay': item.rentPerDay,
                'days': item.days,
                'pcWeight': item.pcWeight,
                'weightKg': item.weightKg,
                'ratePerKg': item.ratePerKg,
                'goodValue': item.goodValue,
                'length': item.length,
                'width': item.width,
                'height': item.height,
                'area': item.area,
                'isAreaBased': isAreaBasedCalculation,
                'isRentCalculation': isRentCalculation,
              })
          .toList(),
      'totals': calculateTotals(),
    };

    calculationHistory.add(currentCalculation);
    await prefs.setString(historyKey, json.encode(calculationHistory));
  }

  void addItem() {
    if (isAreaBasedCalculation) {
      addAreaBasedItem();
    } else {
      addItemBasedItem();
    }
  }

  void addItemBasedItem() {
    // if (selectedItem == null ||
    //     quantityController.text.isEmpty ||
    //     (isRentCalculation
    //         ? (rentController.text.isEmpty || daysController.text.isEmpty)
    //         : rateController.text.isEmpty)) {
    //   // ScaffoldMessenger.of(context).showSnackBar(
    //   //     const SnackBar(content: Text('Please fill all required fields')));
    //   return;
    // }

    double quantity = double.parse(quantityController.text);
    double pcWeight = stockData[selectedItem]!['pcWeight']!;
    double weightKg = quantity * pcWeight;
    double goodValue;

    if (isRentCalculation) {
      double rentPerDay = double.parse(rentController.text);
      int days = int.parse(daysController.text);
      goodValue = quantity * rentPerDay * days;
    } else {
      double ratePerKg = double.parse(rateController.text);
      goodValue = weightKg * ratePerKg;
    }

    setState(() {
      calculatedItems.add(CalculatedItem(
        itemName: selectedItem!,
        quantity: quantity,
        rentPerDay: isRentCalculation ? double.parse(rentController.text) : 0,
        days: isRentCalculation ? int.parse(daysController.text) : null,
        pcWeight: pcWeight,
        weightKg: weightKg,
        ratePerKg: isRentCalculation ? 0 : double.parse(rateController.text),
        goodValue: goodValue,
        length: 0,
        width: 0,
        height: 0,
        area: 0,
      ));
    });

    clearInputFields();
  }

  void addAreaBasedItem() {
    if (lengthController.text.isEmpty ||
        widthController.text.isEmpty ||
        heightController.text.isEmpty ||
        (isRentCalculation
            ? (rentController.text.isEmpty || daysController.text.isEmpty)
            : rateController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    double length = double.parse(lengthController.text);
    double width = double.parse(widthController.text);
    double height = double.parse(heightController.text);
    double area = length * width * height;
    double goodValue;

    if (isRentCalculation) {
      double rentPerDay = double.parse(rentController.text);
      int days = int.parse(daysController.text);
      goodValue = area * rentPerDay * days;
    } else {
      double ratePerArea = double.parse(rateController.text);
      goodValue = area * ratePerArea;
    }

    setState(() {
      calculatedItems.add(CalculatedItem(
        itemName: "WHeel Set"!,
        quantity: 1,
        rentPerDay: isRentCalculation ? double.parse(rentController.text) : 0,
        days: isRentCalculation ? int.parse(daysController.text) : null,
        pcWeight: 0,
        weightKg: 0,
        ratePerKg: isRentCalculation ? 0 : double.parse(rateController.text),
        goodValue: goodValue,
        length: length,
        width: width,
        height: height,
        area: area,
      ));
    });

    clearInputFields();
  }

  void clearInputFields() {
    quantityController.clear();
    rentController.clear();
    lengthController.clear();
    widthController.clear();
    heightController.clear();
    daysController.clear();
    rateController.clear();
    selectedItem = null;
    selectedAreaType = null;
  }

  void showHistoryDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorHistoryScreen(
          calculationHistory: calculationHistory,
          onHistoryUpdated: (updatedHistory) {
            setState(() {
              calculationHistory = updatedHistory;
            });
          },
        ),
      ),
    );
  }

  Map<String, double> calculateTotals() {
    double totalQuantity = 0;
    double totalRentPerDay = 0;
    double totalWeightKg = 0;
    double totalGoodValue = 0;
    double totalArea = 0;

    for (var item in calculatedItems) {
      totalQuantity += item.quantity;
      totalRentPerDay += item.rentPerDay;
      totalWeightKg += item.weightKg;
      totalGoodValue += item.goodValue;
      totalArea += item.area;
    }
    return {
      'quantity': totalQuantity,
      'rentPerDay': totalRentPerDay,
      'weightKg': totalWeightKg,
      'goodValue': totalGoodValue,
      'area': totalArea,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Scaffolding Calculator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: showHistoryDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCombinedSection(),
            buildDetailsSection(),
            buildTableSection(totals),
            buildActionButtonsSection(),
          ],
        ),
      ),
    );
  }

  Widget buildCombinedSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Details Row
          Row(
            children: [
              // const Text(
              //   'Customer Details',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.teal,
              //   ),
              // ),
              // const SizedBox(width: 10),
              Expanded(
                child: RegisterField(
                  hint: "Name & Address",
                  controller: nameController,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Calculation Type Row
          Row(
            children: [
              const Text(
                'Type:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      isExpanded: true,
                      value: isAreaBasedCalculation,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('Item Based'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Area Based'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          isAreaBasedCalculation = value!;
                          clearInputFields();
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<bool>(
                      isExpanded: true,
                      value: isRentCalculation,
                      items: const [
                        DropdownMenuItem(
                          value: false,
                          child: Text('Sale'),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Rent'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          isRentCalculation = value!;
                          clearInputFields();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final TextEditingController customTypeController = TextEditingController();
  final TextEditingController customItemController = TextEditingController();
  // String? selectedAreaType;
  Widget buildDetailsSection() {
    final dropDownKey = GlobalKey<DropdownSearchState>();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          if (isAreaBasedCalculation) ...[
            // Area Based Fields
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 40,
                    child: DropdownSearch<String>(
                      key: dropDownKey,
                      selectedItem: "Menu",
                      items: (filter, infiniteScrollProps) =>
                          [...areaTypes, "Others"], // Added "Others" option
                      onChanged: (value) {
                        setState(() {
                          selectedAreaType = value;
                          if (value == "Others") {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Stock();
                            }));
                          }
                        });
                      },
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Type',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                          // fit: FlexFit.loose,
                          // constraints: BoxConstraints(),
                          ),
                    ),
                  ),
                ),
                if (selectedAreaType == "Others") ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'Enter Type',
                      controller: customTypeController,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'L(m)',
                      controller: lengthController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'W(m)',
                      controller: widthController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'H(m)',
                      controller: heightController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Item Based Fields
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: DropdownButtonFormField<String>(
                      value: selectedItem,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Item',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: [...stockData.keys, "Others"].map((String value) {
                        // Added "Others" option
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedItem = value;
                          if (value == "Others") {
                            // Clear the custom input when switching to Others
                            customItemController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                if (selectedItem == "Others") ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 40,
                      child: RegisterField(
                        hint: 'Enter Item Name',
                        controller: customItemController,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'Qty',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (isRentCalculation) ...[
                // Rent Fields
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'Rent/Day',
                      controller: rentController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: 'Days',
                      controller: daysController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ] else ...[
                // Sale Fields
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: RegisterField(
                      hint: isAreaBasedCalculation ? 'Rate/m³' : 'Rate/kg',
                      controller: rateController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTableSection(Map<String, double> totals) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
          columns: [
            const DataColumn(label: Text('Item')),
            if (isAreaBasedCalculation) ...[
              const DataColumn(label: Text('Dimensions')),
              const DataColumn(label: Text('Area (m³)')),
              if (isRentCalculation) ...[
                const DataColumn(label: Text('Rent/Day')),
                const DataColumn(label: Text('Days')),
              ] else ...[
                const DataColumn(label: Text('Rate/m³')),
              ],
            ] else ...[
              const DataColumn(label: Text('Qty')),
              if (!isRentCalculation) ...[
                const DataColumn(label: Text('Wt/pc')),
                const DataColumn(label: Text('Total Wt')),
                const DataColumn(label: Text('Rate/kg')),
              ] else ...[
                const DataColumn(label: Text('Rent/Day')),
                const DataColumn(label: Text('Days')),
              ],
            ],
            const DataColumn(label: Text('Value')),
            const DataColumn(label: Text('Action')),
          ],
          rows: [
            ...calculatedItems.map((item) {
              return DataRow(
                cells: [
                  DataCell(Text(item.itemName)),
                  if (isAreaBasedCalculation) ...[
                    DataCell(
                        Text('${item.length}×${item.width}×${item.height}')),
                    DataCell(Text(item.area.toStringAsFixed(2))),
                    if (isRentCalculation) ...[
                      DataCell(Text(item.rentPerDay.toString())),
                      DataCell(Text(item.days.toString())),
                    ] else ...[
                      DataCell(Text(item.ratePerKg.toString())),
                    ],
                  ] else ...[
                    DataCell(Text(item.quantity.toString())),
                    if (!isRentCalculation) ...[
                      DataCell(Text(item.pcWeight.toStringAsFixed(2))),
                      DataCell(Text(item.weightKg.toStringAsFixed(2))),
                      DataCell(Text(item.ratePerKg.toString())),
                    ] else ...[
                      DataCell(Text(item.rentPerDay.toString())),
                      DataCell(Text(item.days.toString())),
                    ],
                  ],
                  DataCell(Text(item.goodValue.toStringAsFixed(2))),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          calculatedItems.remove(item);
                        });
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
            // Total Row
            DataRow(
              cells: [
                const DataCell(Text('Total',
                    style: TextStyle(fontWeight: FontWeight.bold))),
                if (isAreaBasedCalculation) ...[
                  const DataCell(Text('')),
                  DataCell(Text(
                    totals['area']!.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  if (isRentCalculation) ...[
                    DataCell(Text(
                      totals['rentPerDay']!.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataCell(Text('')),
                  ] else ...[
                    const DataCell(Text('')),
                  ],
                ] else ...[
                  DataCell(Text(
                    totals['quantity']!.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                  if (!isRentCalculation) ...[
                    const DataCell(Text('')),
                    DataCell(Text(
                      totals['weightKg']!.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataCell(Text('')),
                  ] else ...[
                    DataCell(Text(
                      totals['rentPerDay']!.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                    const DataCell(Text('')),
                  ],
                ],
                DataCell(Text(
                  totals['goodValue']!.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
                const DataCell(Text('')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtonsSection() {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: showResetDialog,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await saveHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calculation saved to history'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Calculator'),
          content: const Text('How would you like to reset?'),
          actions: [
            TextButton(
              onPressed: () {
                resetCalculator(false);
                Navigator.pop(context);
              },
              child: const Text('Reset without Saving'),
            ),
            ElevatedButton(
              onPressed: () async {
                await saveHistory();
                resetCalculator(true);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Reset and Save History'),
            ),
          ],
        );
      },
    );
  }

  void resetCalculator(bool saved) {
    setState(() {
      calculatedItems.clear();
      nameController.clear();
      clearInputFields();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Calculator reset and history saved'
              : 'Calculator reset without saving',
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class CalculatedItem {
  final String itemName;
  final double quantity;
  final double rentPerDay;
  final int? days;
  final double pcWeight;
  final double weightKg;
  final double ratePerKg;
  final double goodValue;
  final double length;
  final double width;
  final double height;
  final double area;

  CalculatedItem({
    required this.itemName,
    required this.quantity,
    required this.rentPerDay,
    this.days,
    required this.pcWeight,
    required this.weightKg,
    required this.ratePerKg,
    required this.goodValue,
    required this.length,
    required this.width,
    required this.height,
    required this.area,
  });
}
