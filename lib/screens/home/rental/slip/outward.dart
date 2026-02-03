// ignore_for_file: unnecessary_string_interpolations

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/home/item.dart';
import 'package:scaffolding_sale/screens/home/stock.dart';
import 'package:scaffolding_sale/transporter/models/transporter_models.dart';
import 'package:scaffolding_sale/transporter/screens/add_driver_screen.dart';
import 'package:scaffolding_sale/transporter/screens/add_transporter_screen.dart';
import 'package:scaffolding_sale/transporter/screens/add_vehicle_screen.dart';
import 'package:scaffolding_sale/transporter/services/transporter_service.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/button.dart';

class OutwardScreen extends StatefulWidget {
  const OutwardScreen({super.key});

  @override
  State<OutwardScreen> createState() => _OutwardScreenState();
}

class _OutwardScreenState extends State<OutwardScreen> {
  String? selectedChallan = "3";
  String? selectedDate = "5 Oct 2025";
  String? selectedType;
  List<CategoryItem> categories = [];
  CategoryItem? selectedCategory;
  StockItem? selectedSize;
  List<StockItem> sizes = [];
  List<OutwardItem> outwardItems = [];
  bool isLoading = false;

  final quantityController = TextEditingController();
  final widthController = TextEditingController();
  final lengthController = TextEditingController();
  final heightController = TextEditingController();

  double totalAmount = 0;
  double totalWeight = 0;
  int totalQuantity = 0;

  List<String> challanList = ["New Challan", "3"];
  List<String> addItemOptions = ["Add Item & Area"];
  int challanCounter = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() => isLoading = true);
    try {
      final loadedCategories = await CategoryService.getCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Error loading categories");
    }
  }

  Future<void> loadSizes(String categoryId) async {
    setState(() => isLoading = true);
    try {
      final loadedSizes = await StockService.getItemsByCategory(categoryId);
      setState(() {
        sizes = loadedSizes;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sizes: $e');
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Error loading sizes");
    }
  }

  void updateTotals() {
    double amount = 0;
    double weight = 0;
    int quantity = 0;
    for (var item in outwardItems) {
      amount += item.totalAmount;
      weight += item.totalWeight;
      quantity += item.isArea ? 1 : item.quantity;
    }
    setState(() {
      totalAmount = amount;
      totalWeight = weight;
      totalQuantity = quantity;
    });
  }

  // void _showSelectionTypeDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       contentPadding: EdgeInsets.zero,
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             decoration: const BoxDecoration(
  //               color: Colors.teal,
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(4),
  //                 topRight: Radius.circular(4),
  //               ),
  //             ),
  //             child: Row(
  //               children: [
  //                 IconButton(
  //                   icon: const Icon(Icons.arrow_back, color: Colors.white),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //                 const Text(
  //                   'Select Type',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               children: [
  //                 ListTile(
  //                   title: const Text('Select by Item'),
  //                   onTap: () {
  //                     setState(() => selectedType = 'item');
  //                     Navigator.pop(context);
  //                     _showCategoryDialog();
  //                   },
  //                 ),
  //                 const Divider(),
  //                 ListTile(
  //                   title: const Text('Select by Area'),
  //                   onTap: () {
  //                     setState(() => selectedType = 'area');
  //                     Navigator.pop(context);
  //                     _showAreaInputDialog();
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showCategoryDialog() {
    String searchQuery = '';
    List<CategoryItem> filteredCategories = List.from(categories);
    bool isDropdownOpen = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSelectionTypeDialog();
                      },
                    ),
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          // Search field that looks like dropdown header
                          InkWell(
                            onTap: () {
                              setState(() {
                                isDropdownOpen = !isDropdownOpen;
                              });
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Search Category',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                          filteredCategories = categories
                                              .where((category) => category.name
                                                  .toLowerCase()
                                                  .contains(
                                                      value.toLowerCase()))
                                              .toList();
                                          isDropdownOpen = true;
                                        });
                                      },
                                      onTap: () {
                                        setState(() {
                                          isDropdownOpen = true;
                                        });
                                      },
                                    ),
                                  ),
                                  Icon(
                                    isDropdownOpen
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Dropdown items
                          if (isDropdownOpen)
                            Container(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Add New Category Option
                                    ListTile(
                                      title: const Text(
                                        "Add New Category",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const Stock()),
                                        ).then((_) => loadCategories());
                                      },
                                    ),
                                    const Divider(height: 1),
                                    // Filtered Categories
                                    ...filteredCategories.map((category) =>
                                        Column(
                                          children: [
                                            ListTile(
                                              title: Text(category.name),
                                              selected:
                                                  selectedCategory == category,
                                              onTap: () {
                                                this.setState(() =>
                                                    selectedCategory =
                                                        category);
                                                Navigator.pop(context);
                                                loadSizes(category.name).then(
                                                    (_) => _showSizeDialog());
                                              },
                                            ),
                                            if (category !=
                                                filteredCategories.last)
                                              const Divider(height: 1),
                                          ],
                                        )),
                                  ],
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
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    try {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedTime != null) {
          final DateTime combinedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          setState(() {
            selectedDate =
                DateFormat('dd-MM-yyyy HH:mm').format(combinedDateTime);
          });
        }
      }
    } catch (e) {
      print('Error selecting date/time: $e');
      Fluttertoast.showToast(msg: "Error selecting date/time");
    }
  }

  Future<void> _generateNewChallan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int lastNumber = prefs.getInt('last_challan_number') ?? 0;
      lastNumber++;

      final now = DateTime.now();
      final challanNumber =
          'CH${now.year}${now.month.toString().padLeft(2, '0')}${lastNumber.toString().padLeft(5, '0')}';

      await prefs.setInt('last_challan_number', lastNumber);

      setState(() {
        selectedChallan = challanNumber;
      });

      _selectDateTime();
    } catch (e) {
      print('Error generating challan: $e');
      Fluttertoast.showToast(msg: "Error generating challan number");
    }
  }

  void _showSizeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      _showCategoryDialog();
                    },
                  ),
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<StockItem>(
                      value: selectedSize,
                      isExpanded: true,
                      hint: const Text('Select Size'),
                      underline: const SizedBox(),
                      items: sizes.map((size) {
                        return DropdownMenuItem<StockItem>(
                          value: size,
                          child: Text('${size.size}'),
                        );
                      }).toList(),
                      onChanged: (StockItem? value) {
                        if (value != null) {
                          setState(() => selectedSize = value);
                          Navigator.pop(context);
                          _showQuantityDialog();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog() {
    int availableStock = selectedSize!.available;
    TextEditingController tempQuantityController = TextEditingController();

    bool isQuantityExceedingStock() {
      int enteredQuantity = int.tryParse(quantityController.text) ?? 0;
      return enteredQuantity > availableStock;
    }

    void updateAvailableStock(String value) {
      int enteredQuantity = int.tryParse(value) ?? 0;
      setState(() {
        availableStock = selectedSize!.available - enteredQuantity;
      });
    }

    void _showAddStockDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Add Stock',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: tempQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter quantity to add',
                          labelText: 'Additional Quantity',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () {
                        int? additionalQuantity =
                            int.tryParse(tempQuantityController.text);
                        if (additionalQuantity != null &&
                            additionalQuantity > 0) {
                          setState(() {
                            selectedSize!.available += additionalQuantity;
                            availableStock = selectedSize!.available;
                          });
                          Navigator.pop(context);
                          // Update the stock display
                          updateAvailableStock(quantityController.text);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please enter a valid quantity");
                        }
                      },
                      child: const Text('Add Stock'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSizeDialog();
                      },
                    ),
                    Expanded(
                      child: Text(
                        '${selectedSize!.size}\n(Available: $availableStock)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.white),
                      onPressed: _showAddStockDialog,
                      tooltip: 'Add more stock',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isQuantityExceedingStock()
                              ? Colors.red
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter quantity',
                          labelText: 'Quantity',
                          errorText: isQuantityExceedingStock()
                              ? 'Exceeds available stock'
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            updateAvailableStock(value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () {
                        int? quantity = int.tryParse(quantityController.text);
                        if (quantity != null &&
                            quantity <= selectedSize!.available) {
                          if (_addItemToTable()) {
                            Navigator.pop(context);
                            _showSizeDialog();
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg:
                                "Please enter a valid quantity within available stock",
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAreaInputDialog() {
    String? selectedAreaType;
    TextEditingController otherAreaController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSelectionTypeDialog();
                      },
                    ),
                    const Text(
                      'Enter Area Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Area Type Dropdown
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedAreaType,
                          isExpanded: true,
                          hint: const Text('Select Area Type'),
                          items: const [
                            DropdownMenuItem(
                                value: 'others', child: Text('Others')),
                            DropdownMenuItem(
                                value: 'MS Scaffolding Material',
                                child: Text('MS Scaffolding Material')),
                            DropdownMenuItem(
                                value: 'Scaffolding Set',
                                child: Text('Scaffolding Set')),
                            DropdownMenuItem(
                                value: 'Wheel Set', child: Text('Wheel Set')),
                            DropdownMenuItem(
                                value: 'Wheel Set', child: Text('H-Frame')),
                            DropdownMenuItem(
                                value: 'Alumunium Scaffolding Set',
                                child: Text('Alumunium Scaffolding Set')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedAreaType = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Others TextField (only shown when 'others' is selected)
                    if (selectedAreaType == 'others')
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: otherAreaController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter area type',
                            labelText: 'Other Area Type',
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter width',
                          labelText: 'Width',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: lengthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter length',
                          labelText: 'Length',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter height',
                          labelText: 'Height',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () {
                        // Validate area type selection
                        if (selectedAreaType == null) {
                          Fluttertoast.showToast(
                              msg: "Please select area type");
                          return;
                        }

                        // Validate others input if selected
                        if (selectedAreaType == 'others' &&
                            otherAreaController.text.trim().isEmpty) {
                          Fluttertoast.showToast(msg: "Please enter area type");
                          return;
                        }

                        if (_addAreaToTable()) {
                          Navigator.pop(context);
                          _showSelectionTypeDialog();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _addItemToTable() {
    if (selectedSize == null) {
      Fluttertoast.showToast(msg: "Please select a size");
      return false;
    }

    final quantity = int.tryParse(quantityController.text);
    if (quantity == null || quantity <= 0) {
      Fluttertoast.showToast(msg: "Please enter a valid quantity");
      return false;
    }

    if (quantity > selectedSize!.available) {
      Fluttertoast.showToast(msg: "Quantity exceeds available stock");
      return false;
    }

    setState(() {
      outwardItems.add(OutwardItem(
        item: selectedSize!,
        quantity: quantity,
        isArea: false,
      ));
      quantityController.clear();
      updateTotals();
    });
    return true;
  }

  final List<Map<String, dynamic>> predefinedItems = [
    {
      'name': 'Standard 1mtr',
      'quantity': 250,
      'hsn': '73084000',
      'rate': 13.5,
      'amount': 3375,
      'weight': 65,
      'available': 2,
      'totalStock': 500
    },
    {
      'name': 'Standard 2.0mtr',
      'quantity': 400,
      'hsn': '73084000',
      'rate': 5,
      'amount': 2000,
      'weight': 65,
      'available': 1.5,
      'totalStock': 600
    },
    {
      'name': 'Coupler',
      'quantity': 50,
      'hsn': '73084000',
      'rate': 100,
      'amount': 120,
      'weight': 120,
      'available': 3,
      'totalStock': 500
    },
  ];

  // Replace receiverAll() method with this:
  void receiverAll() {
    setState(() {
      outwardItems.clear();
      for (var item in predefinedItems) {
        outwardItems.add(OutwardItem(
          item: StockItem(
            id: "2",
            title: item['name'],
            size: item['name'],
            quantity: item['quantity'],
            rate: num.parse(item['rate'].toString()).toDouble(),
            weight: num.parse(item['weight'].toString()).toDouble(),
            available: item['quantity'],
            image: '',
            category: '',
            saleRate: num.parse(item['rate'].toString()).toDouble(),
            value: 1,
            dispatch: 1,
          ),
          quantity: item['quantity'],
          isArea: false,
        ));
      }
      updateTotals();
    });
  }

  // Replace _showSelectionTypeDialog() with this simplified version:
  void _showSelectionTypeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Select Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<Map<String, dynamic>>(
                      isExpanded: true,
                      hint: const Text('Select Item'),
                      underline: const SizedBox(),
                      items: predefinedItems.map((item) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: item,
                          child: Text(item['name']),
                        );
                      }).toList(),
                      onChanged: (Map<String, dynamic>? value) {
                        if (value != null) {
                          Navigator.pop(context);
                          _showQuantityDialogForPredefined(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this new method for quantity selection:
  void _showQuantityDialogForPredefined(Map<String, dynamic> selectedItem) {
    int availableStock = selectedItem['quantity'].toInt();
    TextEditingController tempQuantityController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSelectionTypeDialog();
                      },
                    ),
                    Expanded(
                      child: Text(
                        '${selectedItem['name']}\n(Available: $availableStock)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: tempQuantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter quantity',
                          labelText: 'Quantity',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: () {
                        Fluttertoast.showToast(msg: "Item Already Added");
                        // int? quantity =
                        //     int.tryParse(tempQuantityController.text);
                        // if (quantity != null &&
                        //     quantity > 0 &&
                        //     quantity <= availableStock) {
                        //   this.setState(() {
                        //     outwardItems.add(OutwardItem(
                        //       item: StockItem(
                        //         title: selectedItem['name'],
                        //         size: selectedItem['name'],
                        //         quantity: selectedItem['quantity'],
                        //         rate: selectedItem['rate'],
                        //         weight: selectedItem['weight'],
                        //         available: selectedItem['available'].toInt(),
                        //         id: '',
                        //         image: '',
                        //         category: '',
                        //         saleRate: selectedItem['rate'],
                        //         value: 1,
                        //         dispatch: 1,
                        //       ),
                        //       quantity: quantity,
                        //       isArea: false,
                        //     ));
                        //     updateTotals();
                        //   });
                        //   Navigator.pop(context);
                        //   Fluttertoast.showToast(
                        //       msg: "Item added successfully");
                        // } else {
                        //   Fluttertoast.showToast(
                        //     msg:
                        //         "Please enter a valid quantity within available stock",
                        //   );
                        // }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _addAreaToTable() {
    final width = double.tryParse(widthController.text);
    final length = double.tryParse(lengthController.text);
    final height = double.tryParse(heightController.text);

    if (width == null ||
        length == null ||
        height == null ||
        width <= 0 ||
        length <= 0 ||
        height <= 0) {
      Fluttertoast.showToast(msg: "Please enter valid dimensions");
      return false;
    }

    setState(() {
      outwardItems.add(OutwardItem(
        width: width,
        length: length,
        height: height,
        isArea: true,
      ));
      widthController.clear();
      lengthController.clear();
      heightController.clear();
      updateTotals();
    });
    return true;
  }

  TableRow _buildTableRow(OutwardItem item, VoidCallback onDelete) {
    // onDelete कॉलबैक जोड़ा गया
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.isArea
                ? 'Area: ${item.length}x${item.width}x${item.height}'
                : '${item.item!.size}'),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.isArea
                ? item.area.toStringAsFixed(2)
                : item.quantity.toString()),
          ),
        ),
        // नया डिलीट आइकन TableCell
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              iconSize: 20,
              onPressed: onDelete, // onDelete फ़ंक्शन को कॉल करें
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: [
            Text('Inward', style: TextStyle(color: Colors.white)),
            Spacer(),
            InkWell(
              onTap: () {
                receiverAll();
              },
              child: Container(
                color: ThemeColors.kSecondaryThemeColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: CustomText(
                    text: "Receive All",
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),

            // Checkbox(value: true, onChanged: (value) {})
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: selectedChallan,
                          hint: const Text('Select Challan'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedChallan = newValue!;
                            });
                            if (newValue == "New Challan") {
                              _generateNewChallan();
                            }
                          },
                          items: challanList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: "Add Item & Area",
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            if (newValue == "Add Item & Area") {
                              _showSelectionTypeDialog();
                            }
                          },
                          items: addItemOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: _selectDateTime,
                      icon: const Icon(Icons.date_range),
                    ),
                    Text(selectedDate ?? "Select Date"),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1.5),
                  },
                  children: const [
                    TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Item Name',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Qty',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Delete',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // TableCell(
                        //   child: Padding(
                        //     padding: EdgeInsets.all(8.0),
                        //     child: Text('1 - Day Amount',
                        //         style: TextStyle(fontWeight: FontWeight.bold)),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                        // 2: FlexColumnWidth(1),
                        // 3: FlexColumnWidth(1.5),
                      },
                      children: [
                        ...outwardItems.map((item) => _buildTableRow(item, () {
                              setState(() {
                                outwardItems.remove(item);
                                updateTotals();
                              });
                            })),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1.5),
                    },
                    children: [
                      TableRow(
                        children: [
                          const TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "$totalQuantity Pcs",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${totalWeight.toStringAsFixed(2)} KG",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          // TableCell(
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Text(
                          //       '₹${totalAmount.toStringAsFixed(2)}',
                          //       style: const TextStyle(
                          //           fontWeight: FontWeight.bold),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.92,
              child: PrimaryButton(
                onTap: _saveOutward,
                text: "Save All",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOutward() async {
    // Navigator.pop(context);

    await showChallanTransportSheet(context);
    if (selectedChallan == null) {
      Fluttertoast.showToast(msg: "Please generate a challan number");
      return;
    }

    if (selectedDate == null) {
      Fluttertoast.showToast(msg: "Please select date and time");
      return;
    }

    if (outwardItems.isEmpty) {
      Fluttertoast.showToast(msg: "Please add at least one item");
      return;
    }

    try {
      final outward = Outward(
        challanNumber: selectedChallan!,
        dateTime: selectedDate!,
        items: outwardItems,
        totalAmount: totalAmount,
        totalWeight: totalWeight,
      );

      await OutwardService.saveOutward(outward);

      for (var item in outwardItems) {
        if (!item.isArea && item.item != null) {
          await StockService.updateItemQuantity(
            item.item!.id,
            item.item!.quantity - item.quantity,
          );
        }
      }

      // Navigator.pop(context);
      // Fluttertoast.showToast(msg: "Outward saved successfully");
    } catch (e) {
      print('Error saving outward: $e');
      Fluttertoast.showToast(msg: "Error saving outward");
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    widthController.dispose();
    lengthController.dispose();
    heightController.dispose();
    super.dispose();
  }
}

Future<void> showChallanTransportSheet(BuildContext context) async {
  final transporterService = TransporterService();
  final transportAmountController = TextEditingController();
  final amountInBillController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final List<Transporter> allTransporters =
      await transporterService.getTransporters();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      // Controllers for each Autocomplete field
      final transporterController = TextEditingController();
      final driverController = TextEditingController();
      final vehicleController = TextEditingController();

      // State variables to hold the selected objects
      Transporter? selectedTransporter;
      Driver? selectedDriver;
      Vehicle? selectedVehicle;

      // --- NEW: State for the checkbox ---
      bool isPaidByClient = true;

      final formKey = GlobalKey<FormState>();

      // --- Helper function to build the Autocomplete UI ---
      Widget buildAutocompleteField<T extends Object>({
        required String label,
        required IconData icon,
        required TextEditingController controller,
        required List<T> items,
        required String Function(T) displayStringForOption,
        required void Function(T) onSelected,
        required Future<void> Function() onAddNew,
        String? Function(String?)? validator,
      }) {
        return Autocomplete<T>(
          displayStringForOption: displayStringForOption,
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            controller.value = textEditingController.value;
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add New $label',
                  onPressed: onAddNew,
                ),
              ),
              validator: validator,
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable.empty();
            }
            return items.where((T option) {
              return displayStringForOption(option)
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: onSelected,
        );
      }

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Enter or Select Transport Details",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // --- 1. Transporter Autocomplete ---
                  buildAutocompleteField<Transporter>(
                    label: "Transporter",
                    icon: Icons.local_shipping_outlined,
                    controller: transporterController,
                    items: allTransporters,
                    displayStringForOption: (t) => t.name,
                    onAddNew: () async => await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddTransporterScreen())),
                    onSelected: (Transporter selection) {
                      setModalState(() {
                        selectedTransporter = selection;
                        transporterController.text = selection.name;
                        selectedDriver = selection.drivers.isNotEmpty
                            ? selection.drivers.first
                            : null;
                        driverController.text = selectedDriver?.name ?? '';
                        selectedVehicle = selection.vehicles.isNotEmpty
                            ? selection.vehicles.first
                            : null;
                        vehicleController.text =
                            selectedVehicle?.vehicleNumber ?? '';
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select or enter a transporter'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // --- 2. Driver Autocomplete ---
                  buildAutocompleteField<Driver>(
                    label: "Driver",
                    icon: Icons.badge_outlined,
                    controller: driverController,
                    items: selectedTransporter?.drivers ?? [],
                    displayStringForOption: (d) => d.name,
                    onAddNew: () async => await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => AddDriverScreen(
                                transporterId: selectedTransporter!.id))),
                    onSelected: (Driver selection) {
                      setModalState(() {
                        selectedDriver = selection;
                        driverController.text = selection.name;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select or enter a driver'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // --- 3. Vehicle Autocomplete ---
                  buildAutocompleteField<Vehicle>(
                    label: "Vehicle",
                    icon: Icons.directions_car_outlined,
                    controller: vehicleController,
                    items: selectedTransporter?.vehicles ?? [],
                    displayStringForOption: (v) => v.vehicleNumber,
                    onAddNew: () async => await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => AddVehicleScreen(
                                transporterId: selectedTransporter!.id))),
                    onSelected: (Vehicle selection) {
                      setModalState(() {
                        selectedVehicle = selection;
                        vehicleController.text = selection.vehicleNumber;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select or enter a vehicle'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // --- MODIFIED: Amount TextFields with Checkbox ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: transportAmountController,
                          keyboardType: TextInputType.number,
                          // --- MODIFIED: Disable field based on checkbox state ---
                          enabled: !isPaidByClient,
                          decoration: InputDecoration(
                            labelText: "Transport Amount",
                            prefixIcon: const Icon(Icons.currency_rupee),
                            // --- NEW: Change fill color when disabled ---
                            filled: true,
                            fillColor: isPaidByClient
                                ? Colors.grey.shade200
                                : Colors.transparent,
                          ),
                          // --- MODIFIED: Validator only runs if field is enabled ---
                          validator: (value) {
                            if (!isPaidByClient &&
                                (value == null || value.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text("Pay By Client"),
                          value: isPaidByClient,
                          onChanged: (newValue) {
                            setModalState(() {
                              isPaidByClient = newValue!;
                              // Clear the text field if checkbox is ticked
                              if (isPaidByClient) {
                                transportAmountController.clear();
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.only(left: 8),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    enabled: !isPaidByClient,
                    controller: amountInBillController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        fillColor: isPaidByClient
                            ? Colors.grey.shade200
                            : Colors.transparent,
                        labelText: "Transport Amount to Show In Bill",
                        prefixIcon: Icon(Icons.currency_rupee)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Challan Added");
                      }
                    },
                    child: const Text("Continue"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class Outward {
  final String challanNumber;
  final String dateTime;
  final List<OutwardItem> items;
  final double totalAmount;
  final double totalWeight;

  Outward({
    required this.challanNumber,
    required this.dateTime,
    required this.items,
    required this.totalAmount,
    required this.totalWeight,
  });

  Map<String, dynamic> toJson() => {
        'challanNumber': challanNumber,
        'dateTime': dateTime,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'totalWeight': totalWeight,
      };

  factory Outward.fromJson(Map<String, dynamic> json) => Outward(
        challanNumber: json['challanNumber'],
        dateTime: json['dateTime'],
        items: (json['items'] as List)
            .map((item) => OutwardItem.fromJson(item))
            .toList(),
        totalAmount: json['totalAmount'].toDouble(),
        totalWeight: json['totalWeight'].toDouble(),
      );
}

class OutwardItem {
  final StockItem? item;
  final int quantity;
  final double width;
  final double length;
  final double height;
  final bool isArea;

  OutwardItem({
    this.item,
    this.quantity = 0,
    this.width = 0,
    this.length = 0,
    this.height = 0,
    required this.isArea,
  });

  double get area => isArea ? width * length * height : 0;
  double get totalAmount => isArea
      ? area * 0 // Replace with area rate
      : quantity * (item?.rate ?? 0);
  double get totalWeight => isArea
      ? 0 // Replace with area weight calculation
      : quantity * (item?.weight ?? 0);

  Map<String, dynamic> toJson() => {
        'item': item?.toMap(),
        'quantity': quantity,
        'width': width,
        'length': length,
        'height': height,
        'isArea': isArea,
      };

  factory OutwardItem.fromJson(Map<String, dynamic> json) => OutwardItem(
        item: json['item'] != null ? StockItem.fromMap(json['item']) : null,
        quantity: json['quantity'],
        width: json['width'].toDouble(),
        length: json['length'].toDouble(),
        height: json['height'].toDouble(),
        isArea: json['isArea'],
      );
}

// lib/services/outward_service.dart

class OutwardService {
  static const String _key = 'outwards';

  static Future<List<Outward>> getOutwards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outwardsJson = prefs.getString(_key);
      if (outwardsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(outwardsJson);
      return decoded.map((json) => Outward.fromJson(json)).toList();
    } catch (e) {
      print('Error getting outwards: $e');
      return [];
    }
  }

  static Future<void> saveOutward(Outward outward) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outwards = await getOutwards();
      outwards.add(outward);

      await prefs.setString(
          _key, jsonEncode(outwards.map((o) => o.toJson()).toList()));
    } catch (e) {
      print('Error saving outward: $e');
      throw Exception('Failed to save outward');
    }
  }

  static Future<List<Outward>> getOutwardsByDate(DateTime date) async {
    try {
      final outwards = await getOutwards();
      return outwards.where((outward) {
        final outwardDate = DateTime.parse(outward.dateTime);
        return outwardDate.year == date.year &&
            outwardDate.month == date.month &&
            outwardDate.day == date.day;
      }).toList();
    } catch (e) {
      print('Error getting outwards by date: $e');
      return [];
    }
  }

  static Future<void> deleteOutward(String challanNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outwards = await getOutwards();
      outwards.removeWhere((outward) => outward.challanNumber == challanNumber);

      await prefs.setString(
          _key, jsonEncode(outwards.map((o) => o.toJson()).toList()));
    } catch (e) {
      print('Error deleting outward: $e');
      throw Exception('Failed to delete outward');
    }
  }
}
