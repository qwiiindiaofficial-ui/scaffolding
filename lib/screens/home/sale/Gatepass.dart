// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
// import 'dart:math';

// import 'package:scaffolding_sale/utils/colors.dart';
// import 'package:scaffolding_sale/widgets/button.dart';
// import 'package:scaffolding_sale/widgets/text.dart';

// // --- Dummy Classes to make the code runnable ---
// // (Replace these with your actual widget implementations)

// // --- End of Dummy Classes ---

// class GatePass extends StatefulWidget {
//   const GatePass({super.key});

//   @override
//   State<GatePass> createState() => _GatePassState();
// }

// class _GatePassState extends State<GatePass> {
//   // State variables
//   String? selectedItem;
//   DateTime? selectedDate;
//   final TextEditingController _qtyController = TextEditingController();
//   final TextEditingController _vehicleNoController = TextEditingController();
//   final TextEditingController _kattaNameController = TextEditingController();

//   // The list that holds all items added by the user.
//   // It now stores maps with dynamic values to accommodate numbers.
//   final List<Map<String, dynamic>> savedItems = [];

//   // Simplified list of items as per your request.
//   final List<String> items = ['Standar 1.0m', 'Standar 1.5m'];

//   @override
//   void dispose() {
//     _qtyController.dispose();
//     _vehicleNoController.dispose();
//     _kattaNameController.dispose();
//     super.dispose();
//   }

//   // Function to show date and time picker
//   Future<void> _selectDateTime(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null && context.mounted) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );

//       if (pickedTime != null) {
//         setState(() {
//           selectedDate = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   // Function to add a new item to the list
//   void _addItem() {
//     if (selectedItem != null && _qtyController.text.isNotEmpty) {
//       final qty = int.tryParse(_qtyController.text);
//       if (qty == null || qty <= 0) {
//         Fluttertoast.showToast(msg: "Please enter a valid quantity.");
//         return;
//       }
//       setState(() {
//         // Generate random weight and rate for demonstration
//         double randomWeight =
//             (Random().nextDouble() * 5) + 5; // e.g., 5.0 to 10.0
//         double randomRate =
//             (Random().nextDouble() * 100) + 150; // e.g., 150.0 to 250.0

//         savedItems.add({
//           'item': selectedItem!,
//           'Qty': qty,
//           'weight': randomWeight, // Store as number
//           'rate': randomRate, // Store as number
//         });

//         // Reset fields
//         selectedItem = null;
//         _qtyController.clear();
//       });
//       Fluttertoast.showToast(msg: "Item Added!");
//     } else {
//       Fluttertoast.showToast(msg: "Please select an item and enter quantity.");
//     }
//   }

//   // Calculate total quantity from the list
//   int _getTotalQty() {
//     return savedItems.fold(0, (sum, item) => sum + (item['Qty'] as int));
//   }

//   // Calculate total approximate weight
//   double _getTotalWeight() {
//     return savedItems.fold(
//         0.0, (sum, item) => sum + (item['Qty'] * item['weight']));
//   }

//   // Navigate to the edit screen and wait for the result
//   void _navigateToEditScreen() async {
//     if (savedItems.isEmpty) {
//       Fluttertoast.showToast(msg: "Please add at least one item to save.");
//       return;
//     }

//     // `await` waits for the EditableTableScreen to pop and return data
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditableTableScreen(
//           initialItems: savedItems,
//         ),
//       ),
//     );

//     // If the edit screen returned an updated list, update the state here
//     if (result != null && result is List<Map<String, dynamic>>) {
//       setState(() {
//         savedItems.clear();
//         savedItems.addAll(result);
//       });
//       Fluttertoast.showToast(msg: "Changes Saved Successfully!");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: ThemeColors.kPrimaryThemeColor,
//         foregroundColor: Colors.white,
//         title: CustomText(
//           text: "Gate Pass",
//           color: ThemeColors.kWhiteTextColor,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),
//             // Date Selection
//             Row(
//               children: [
//                 const CustomText(
//                   text: 'Select Date',
//                   size: 18,
//                   weight: FontWeight.w500,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.calendar_today, color: Colors.blue),
//                   onPressed: () => _selectDateTime(context),
//                 ),
//                 const Spacer(),
//                 if (selectedDate != null)
//                   Text(
//                     "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} "
//                     "${selectedDate!.hour}:${selectedDate!.minute.toString().padLeft(2, '0')}",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Vehicle No and Katta Name
//             Row(
//               children: [
//                 Expanded(
//                   child: RegisterField(
//                     hint: "Vehicle No.",
//                     controller: _vehicleNoController,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: RegisterField(
//                     hint: "Katta Name",
//                     controller: _kattaNameController,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // Item, Qty, and Add Button
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       hintText: 'Select Item',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 14.0,
//                         horizontal: 12.0,
//                       ),
//                     ),
//                     value: selectedItem,
//                     items: items.map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedItem = value;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   flex: 1,
//                   child: RegisterField(
//                     hint: "Qty",
//                     controller: _qtyController,
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4.0),
//                   child: IconButton(
//                     style: IconButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12))),
//                     icon: const Icon(Icons.check, color: Colors.white),
//                     onPressed: _addItem,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(),

//             // List of Added Items
//             Expanded(
//               child: savedItems.isEmpty
//                   ? const Center(child: Text("No items added yet."))
//                   : ListView.builder(
//                       itemCount: savedItems.length,
//                       itemBuilder: (context, index) {
//                         final item = savedItems[index];
//                         return Dismissible(
//                           key: ValueKey(item['item'] + index.toString()),
//                           direction: DismissDirection.endToStart,
//                           background: Container(
//                             color: Colors.red,
//                             alignment: Alignment.centerRight,
//                             padding: const EdgeInsets.only(right: 20.0),
//                             child:
//                                 const Icon(Icons.delete, color: Colors.white),
//                           ),
//                           onDismissed: (direction) {
//                             setState(() {
//                               savedItems.removeAt(index);
//                             });
//                             Fluttertoast.showToast(msg: "Item removed");
//                           },
//                           child: Card(
//                             elevation: 1,
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             child: ListTile(
//                               title: Text(item['item']!),
//                               subtitle: Text(
//                                   "Weight: ${item['weight'].toStringAsFixed(2)} kg/Pcs"),
//                               trailing: Text(
//                                 "Qty: ${item['Qty']}",
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//             const Divider(),
//             const SizedBox(height: 16),

//             // Totals
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Approx Weight: ${_getTotalWeight().toStringAsFixed(2)} Kg',
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   'Total Qty: ${_getTotalQty()}',
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             PrimaryButton(
//               onTap: _navigateToEditScreen,
//               text: "Save All",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // --- Editable Table Screen ---

// class EditableTableScreen extends StatefulWidget {
//   // Receive the list of items from the previous screen
//   final List<Map<String, dynamic>> initialItems;

//   const EditableTableScreen({Key? key, required this.initialItems})
//       : super(key: key);

//   @override
//   State<EditableTableScreen> createState() => _EditableTableScreenState();
// }

// class _EditableTableScreenState extends State<EditableTableScreen> {
//   late List<Map<String, dynamic>> editableItems;
//   // Controllers to manage the text fields in the table
//   late List<List<TextEditingController>> _controllers;

//   @override
//   void initState() {
//     super.initState();
//     // Create a deep copy of the initial items to allow local edits
//     editableItems = widget.initialItems
//         .map((item) => Map<String, dynamic>.from(item))
//         .toList();

//     // Initialize controllers for each cell
//     _controllers = editableItems.map((item) {
//       return [
//         TextEditingController(text: item['item'].toString()),
//         TextEditingController(text: item['Qty'].toString()),
//         TextEditingController(text: item['weight'].toStringAsFixed(2)),
//         TextEditingController(text: item['rate'].toStringAsFixed(2)),
//       ];
//     }).toList();
//   }

//   @override
//   void dispose() {
//     // Dispose all controllers to free up resources
//     for (var controllerList in _controllers) {
//       for (var controller in controllerList) {
//         controller.dispose();
//       }
//     }
//     super.dispose();
//   }

//   // --- Calculation Functions for the Total Row ---
//   int _getTotalQty() {
//     return editableItems.fold(
//         0, (sum, item) => sum + (int.tryParse(item['Qty'].toString()) ?? 0));
//   }

//   double _getTotalWeight() {
//     return editableItems.fold(
//         0.0,
//         (sum, item) =>
//             sum +
//             ((double.tryParse(item['weight'].toString()) ?? 0.0) *
//                 (int.tryParse(item['Qty'].toString()) ?? 0)));
//   }

//   double _getTotalAmount() {
//     return editableItems.fold(
//         0.0,
//         (sum, item) =>
//             sum +
//             ((double.tryParse(item['rate'].toString()) ?? 0.0) *
//                 (int.tryParse(item['Qty'].toString()) ?? 0)));
//   }

//   // --- Function to update the underlying data when a text field changes ---
//   void _updateItemValue(int rowIndex, int colIndex, String value) {
//     final key = ['item', 'Qty', 'weight', 'rate'][colIndex];
//     // Use tryParse to handle potential formatting errors gracefully
//     dynamic parsedValue = value;
//     if (key == 'Qty') {
//       parsedValue = int.tryParse(value) ?? 0;
//     } else if (key == 'weight' || key == 'rate') {
//       parsedValue = double.tryParse(value) ?? 0.0;
//     }

//     setState(() {
//       editableItems[rowIndex][key] = parsedValue;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: ThemeColors.kPrimaryThemeColor,
//         foregroundColor: Colors.white,
//         title: CustomText(
//           text: "Edit Items",
//           color: ThemeColors.kWhiteTextColor,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: DataTable(
//                   border: TableBorder.all(
//                     color: Colors.grey.shade400,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   columnSpacing: 20,
//                   headingRowColor:
//                       WidgetStateProperty.all(Colors.grey.shade200),
//                   columns: const [
//                     DataColumn(label: Text('Item Name')),
//                     DataColumn(label: Text('Qty')),
//                     DataColumn(label: Text('Weight/Pcs')),
//                     DataColumn(label: Text('Rate')),
//                   ],
//                   rows: [
//                     // Generate a DataRow for each item
//                     ...List.generate(editableItems.length, (index) {
//                       return DataRow(cells: [
//                         // Item Name
//                         DataCell(SizedBox(
//                           width: 120,
//                           child: TextFormField(
//                             controller: _controllers[index][0],
//                             onChanged: (value) =>
//                                 _updateItemValue(index, 0, value),
//                             decoration:
//                                 const InputDecoration(border: InputBorder.none),
//                           ),
//                         )),
//                         // Quantity
//                         DataCell(SizedBox(
//                           width: 50,
//                           child: TextFormField(
//                             controller: _controllers[index][1],
//                             keyboardType: TextInputType.number,
//                             onChanged: (value) =>
//                                 _updateItemValue(index, 1, value),
//                             decoration:
//                                 const InputDecoration(border: InputBorder.none),
//                           ),
//                         )),
//                         // Weight
//                         DataCell(SizedBox(
//                           width: 80,
//                           child: TextFormField(
//                             controller: _controllers[index][2],
//                             keyboardType: const TextInputType.numberWithOptions(
//                                 decimal: true),
//                             onChanged: (value) =>
//                                 _updateItemValue(index, 2, value),
//                             decoration:
//                                 const InputDecoration(border: InputBorder.none),
//                           ),
//                         )),
//                         // Rate
//                         DataCell(SizedBox(
//                           width: 80,
//                           child: TextFormField(
//                             controller: _controllers[index][3],
//                             keyboardType: const TextInputType.numberWithOptions(
//                                 decimal: true),
//                             onChanged: (value) =>
//                                 _updateItemValue(index, 3, value),
//                             decoration:
//                                 const InputDecoration(border: InputBorder.none),
//                           ),
//                         )),
//                       ]);
//                     }),
//                     // The final "Total" row
//                     DataRow(
//                       color: WidgetStateProperty.all(Colors.blue.shade50),
//                       cells: [
//                         const DataCell(Text('Total',
//                             style: TextStyle(fontWeight: FontWeight.bold))),
//                         DataCell(Text('${_getTotalQty()}',
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold))),
//                         DataCell(Text(_getTotalWeight().toStringAsFixed(2),
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold))),
//                         DataCell(Text(_getTotalAmount().toStringAsFixed(2),
//                             style:
//                                 const TextStyle(fontWeight: FontWeight.bold))),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             PrimaryButton(
//               onTap: () {
//                 // When saving, pop the screen and return the edited list
//                 Navigator.pop(context, editableItems);
//               },
//               text: "Confirm & Save",
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }
