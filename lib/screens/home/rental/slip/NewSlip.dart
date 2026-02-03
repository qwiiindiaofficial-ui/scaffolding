import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/App%20Setting.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip.dart'; // Add this import

class NewslipScreen extends StatefulWidget {
  const NewslipScreen({super.key});

  @override
  State<NewslipScreen> createState() => _NewslipScreenState();
}

class _NewslipScreenState extends State<NewslipScreen> {
  // Dropdown values
  String? selectedSlip;
  String? selectedAreaName;
  String? selectedAreaUnit = "Square Feet";
  String? selectedStaffDesignation;
  DateTime? selectedDate;

  // Text controllers
  final slipNoController = TextEditingController();
  final lengthController = TextEditingController();
  final heightController = TextEditingController();
  final widthController = TextEditingController();
  final rateController = TextEditingController();
  final staffQtyController = TextEditingController();
  final dateController = TextEditingController();

  // List to store items
  List<Map<String, dynamic>> itemsList = [];
  List<Map<String, dynamic>> staffList = [];

  // Dummy data
  final areaNames = [
    'Scaffolding Fixing',
    'Scaffolding Closing',
    'Scaffolding Fixing & Closing',
    'Shuttering Fixing',
    'Shuttering Closing',
    'Shuttering Fixing & Closing',
    'Scaffolding Set',
    'Wheel Set',
    'H-Frame',
    'Aluminium Scaffolding Set',
    'Others'
  ];

  final areaUnits = [
    'Square Feet',
    'Cubic Feet',
    'Cubic Meter',
    'Square Meter'
  ];

  final staffDesignations = [
    'Mayank Bajaj',
  ];

  @override
  void dispose() {
    slipNoController.dispose();
    lengthController.dispose();
    heightController.dispose();
    widthController.dispose();
    rateController.dispose();
    staffQtyController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text =
            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
    }
  }

  void _addItem() {
    if (selectedAreaName == null ||
        lengthController.text.isEmpty ||
        heightController.text.isEmpty ||
        widthController.text.isEmpty ||
        rateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields including rate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      itemsList.add({
        'areaName': selectedAreaName,
        'areaUnit': selectedAreaUnit ?? 'Square Feet',
        'length': lengthController.text,
        'height': heightController.text,
        'width': widthController.text,
        'rate': rateController.text,
      });
    });

    lengthController.clear();
    heightController.clear();
    widthController.clear();
    rateController.clear();
    selectedAreaName = null;
    selectedAreaUnit = "Square Feet";

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added successfully'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addStaff() {
    if (selectedStaffDesignation == null ||
        selectedStaffDesignation == '+Add Staff' ||
        staffQtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select staff and enter quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      staffList.add({
        'designation': selectedStaffDesignation,
        'qty': staffQtyController.text,
      });
    });

    staffQtyController.clear();
    selectedStaffDesignation = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Staff added successfully'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showInputDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        String inputValue = '';
        return AlertDialog(
          title: Text('Enter $title'),
          content: TextField(
            onChanged: (value) => inputValue = value,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (inputValue.isNotEmpty) {
                  setState(() {
                    areaNames.add(inputValue);
                    selectedAreaName = inputValue;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title added: $inputValue'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<double> _splitValues(String value) {
    return value.split('+').map((v) => double.tryParse(v.trim()) ?? 0).toList();
  }

  double _calculateItemTotal(var item) {
    List<double> lengths = _splitValues(item['length'].toString());
    List<double> heights = _splitValues(item['height'].toString());
    List<double> widths = _splitValues(item['width'].toString());

    bool isMulti = lengths.length > 1 || heights.length > 1;

    double width = isMulti ? 1 : (widths.isNotEmpty ? widths.first : 1);
    int pairCount =
        lengths.length > heights.length ? lengths.length : heights.length;

    double total = 0;
    for (int i = 0; i < pairCount; i++) {
      double l = i < lengths.length ? lengths[i] : lengths.last;
      double h = i < heights.length ? heights[i] : heights.last;
      total += l * h * width;
    }

    return total;
  }

  double _calculateItemAmount(var item) {
    double total = _calculateItemTotal(item);
    double rate = double.tryParse(item['rate'].toString()) ?? 0;
    return total * rate;
  }

  double _calculateTotalArea() {
    double total = 0;
    for (var item in itemsList) {
      total += _calculateItemTotal(item);
    }
    return total;
  }

  double _calculateTotalAmount() {
    double total = 0;
    for (var item in itemsList) {
      total += _calculateItemAmount(item);
    }
    return total;
  }

  selectLatestSlip() {
    setState(() {
      selectedSlip = "1";
    });
  }

  @override
  void initState() {
    selectLatestSlip();
    super.initState();
  }

  List<String> slipList = [
    '1',
  ]; // put this in your state

  void _saveAll() {
    if (selectedSlip == null ||
        dateController.text.isEmpty ||
        itemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all sections'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final data = {
      'slipNo': selectedSlip,
      'slipNumber': slipNoController.text,
      'date': dateController.text,
      'items': itemsList,
      'staff': staffList,
      'totalArea': _calculateTotalArea(),
      'totalAmount': _calculateTotalAmount(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✓ Slip Saved Successfully',
            style: TextStyle(color: Colors.teal)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Slip No:', data['slipNo'].toString()),
              _buildInfoRow('Slip Number:', data['slipNumber'].toString()),
              _buildInfoRow('Date:', data['date'].toString()),
              _buildInfoRow(
                  'Total Items:', data['items'].toString().length.toString()),
              _buildInfoRow(
                  'Total Staff:', data['staff'].toString().length.toString()),
              const Divider(),
              _buildInfoRow(
                'Total Area:',
                '${data['totalArea'].toString()} sq units',
                isBold: true,
              ),
              _buildInfoRow(
                'Total Amount:',
                '₹${data['totalAmount'].toString()}',
                isBold: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );

    print('Saved Data: $data');
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.teal : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text('New Slips',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== SLIP SELECTION & DATE ==========
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Slip No.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 11)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: selectedSlip,
                            decoration: InputDecoration(
                              hintText: 'Select',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(
                                  value: 'new', child: Text('New')),
                              ...slipList.reversed.map((e) => DropdownMenuItem(
                                  value: e, child: Text('Slip $e'))),
                            ],
                            onChanged: (value) {
                              setState(() {
                                if (value == 'new') {
                                  int nextSlipNumber = slipList.length + 1;
                                  slipList.add(nextSlipNumber.toString());
                                  selectedSlip = nextSlipNumber.toString();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'New Slip $selectedSlip created!')),
                                  );
                                } else {
                                  selectedSlip = value;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date & Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 11)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: dateController,
                            decoration: InputDecoration(
                              hintText: 'Select date & time',
                              hintStyle: const TextStyle(fontSize: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today,
                                  color: Colors.teal, size: 18),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              isDense: true,
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );

                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (time != null) {
                                  final selectedDateTime = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );

                                  // Format: 12 Nov 2025, 04:30 PM
                                  final formattedDateTime =
                                      DateFormat('dd MMM yyyy, hh:mm a')
                                          .format(selectedDateTime);

                                  dateController.text = formattedDateTime;
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Staff',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 11)),
                          const SizedBox(height: 4),

                          // Custom multi-select dropdown
                          GestureDetector(
                            onTap: () => _showMultiSelectDropdown(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedDesignations.isEmpty
                                          ? 'Select'
                                          : selectedDesignations.join(', '),
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
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
            ),

            // ========== AREA & DIMENSIONS ==========
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Area Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: selectedAreaName,
                                decoration: InputDecoration(
                                  hintText: 'Select',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  isDense: true,
                                ),
                                items: areaNames
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e,
                                              maxLines: 1,
                                              style: TextStyle(fontSize: 12)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value == 'Others') {
                                    _showInputDialog('Area Name');
                                  } else {
                                    setState(() => selectedAreaName = value);
                                  }
                                },
                                isExpanded: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rate',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: rateController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.currency_rupee,
                                      color: Colors.teal, size: 16),
                                  hintText: '0',
                                  hintStyle: const TextStyle(fontSize: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Unit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: selectedAreaUnit,
                                decoration: InputDecoration(
                                  hintText: 'Unit',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  isDense: true,
                                ),
                                items: areaUnits
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e,
                                              style: TextStyle(fontSize: 12)),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => selectedAreaUnit = value);
                                },
                                isExpanded: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Length',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: lengthController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.add,
                                        color: Colors.teal, size: 16),
                                    onPressed: () async {
                                      final newLength =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (context) {
                                          final secondLengthController =
                                              TextEditingController();
                                          return AlertDialog(
                                            title: const Text('Add Length'),
                                            content: TextFormField(
                                              controller:
                                                  secondLengthController,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter length',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, null),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context,
                                                      secondLengthController
                                                          .text
                                                          .trim());
                                                },
                                                child: const Text('Add'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (newLength != null &&
                                          newLength.isNotEmpty) {
                                        lengthController.text = lengthController
                                                .text.isEmpty
                                            ? newLength
                                            : '${lengthController.text} + $newLength';
                                      }
                                    },
                                  ),
                                  hintText: '0',
                                  hintStyle: const TextStyle(fontSize: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Height',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: heightController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.add,
                                        color: Colors.teal, size: 16),
                                    onPressed: () async {
                                      final newHeight =
                                          await showDialog<String>(
                                        context: context,
                                        builder: (context) {
                                          final secondHeightController =
                                              TextEditingController();
                                          return AlertDialog(
                                            title: const Text('Add Height'),
                                            content: TextFormField(
                                              controller:
                                                  secondHeightController,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter height',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, null),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context,
                                                      secondHeightController
                                                          .text
                                                          .trim());
                                                },
                                                child: const Text('Add'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (newHeight != null &&
                                          newHeight.isNotEmpty) {
                                        heightController.text = heightController
                                                .text.isEmpty
                                            ? newHeight
                                            : '${heightController.text} + $newHeight';
                                      }
                                    },
                                  ),
                                  hintText: '0',
                                  hintStyle: const TextStyle(fontSize: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Width',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: widthController,
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle: const TextStyle(fontSize: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ThemeColors.kSecondaryThemeColor,
                            ),
                            child: InkWell(
                              onTap: () {
                                _addItem();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ========== ITEMS LIST ==========
            if (itemsList.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Items (${itemsList.length})',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.teal)),
                      const SizedBox(height: 6),
                      ...itemsList.asMap().entries.map((e) {
                        int index = e.key;
                        var item = e.value;

                        bool isMulti =
                            item['length'].toString().contains('+') ||
                                item['height'].toString().contains('+');

                        double itemTotal = _calculateItemTotal(item);
                        double itemAmount = _calculateItemAmount(item);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['areaName'] + " " + item['areaUnit'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'L:${item['length']} × H:${item['height']} × W:${isMulti ? item['width'] : item['width']} = '
                                          '${itemTotal.toStringAsFixed(0)} × ${item['rate']} =',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                        ),
                                        Text(
                                          '${itemAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: ThemeColors
                                                  .kSecondaryThemeColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 18),
                                onPressed: () {
                                  setState(() => itemsList.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

            // ========== STAFF SECTION ==========

            // ========== STAFF LIST ==========
            if (staffList.isNotEmpty)
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Staff (${staffList.length})',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.teal)),
                      const SizedBox(height: 6),
                      ...staffList.asMap().entries.map((e) {
                        int index = e.key;
                        var staff = e.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      staff['designation'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                    Text(
                                      'Qty: ${staff['qty']}',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 18),
                                onPressed: () {
                                  setState(() => staffList.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

            Spacer(),
            // ========== SUMMARY ==========
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.teal.shade50,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoTile('Staff', "1"),
                        _verticalDivider(),
                        _infoTile('Total Area',
                            _calculateTotalArea().toStringAsFixed(0)),
                        _verticalDivider(),
                        _infoTile('Amount',
                            _calculateTotalAmount().toStringAsFixed(0)),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: _saveAll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 3,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: const Text(
                                'Save Slip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ========== SAVE BUTTON ==========
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Staff Designations',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ...staffDesignations.map((designation) {
                    final isSelected =
                        selectedDesignations.contains(designation);
                    return CheckboxListTile(
                      title: Text(
                        designation,
                        style: TextStyle(
                          fontSize: 12,
                          color: designation == '+Add Staff'
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isSelected,
                      onChanged: (checked) {
                        setModalState(() {
                          if (checked == true) {
                            selectedDesignations.add(designation);
                          } else {
                            selectedDesignations.remove(designation);
                          }
                        });
                        setState(() {}); // update UI outside modal
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper widgets
  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey.shade400,
    );
  }

  List<String> selectedDesignations = [];
}
