// lib/models/expense_model.dart

import 'package:uuid/uuid.dart';
// lib/services/preference_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// lib/screens/add_expense_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';

// lib/screens/expense_list_screen.dart
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _expenseService = PreferenceService();
  late Future<List<Expense>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expensesFuture = _expenseService.getExpenses();
    });
  }

  // संपादन या जोड़ने के लिए सामान्य फ़ंक्शन
  void _navigateAndRefresh({Expense? expenseToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          // यदि संपादन के लिए कोई खर्च है, तो उसे पास करें
          builder: (context) => AddExpenseScreen(expense: expenseToEdit)),
    );
    // यदि AddExpenseScreen से 'true' लौटाया जाता है तो सूची को रीफ्रेश करें
    if (result == true) {
      _loadExpenses();
    }
  }

  void _deleteExpense(String id) {
    // ... (यह फ़ंक्शन वही रहता है) ...
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _expenseService.deleteExpense(id).then((_) {
                Navigator.of(context).pop();
                _loadExpenses(); // सूची को रीफ्रेश करें
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Expenses', style: TextStyle(color: Colors.white)),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred!'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No expenses recorded.\nTap the "+" button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final expenses = snapshot.data!;
          // नवीनतम खर्च पहले दिखाने के लिए सूची को सॉर्ट करें
          expenses.sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: ThemeColors.kSecondaryThemeColor,
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text(
                    expense.category,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                  onTap: () => _navigateAndRefresh(
                      expenseToEdit:
                          expense), // 1. ListTile को संपादन के लिए onTap दें
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rs ${expense.totalAmount.toStringAsFixed(2)}', // 'Rs' जोड़ा गया
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ThemeColors.kPrimaryThemeColor,
                        ),
                      ),
                      // 2. संपादन बटन को हटाने के लिए IconButton की जरूरत नहीं है
                      // संपादन अब ListTile के onTap पर है, केवल डिलीट बटन रखें।
                      IconButton(
                        icon:
                            Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteExpense(expense.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // 3. नेविगेशन को अपडेट किया गया
        onPressed: () => _navigateAndRefresh(),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: ThemeColors.kSecondaryThemeColor,
        tooltip: 'Add Expense',
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  // मौजूदा खर्च को संपादित करने के लिए वैकल्पिक पैरामीटर
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expenseService = PreferenceService();

  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<BilledItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // संपादन मोड: मौजूदा डेटा लोड करें
      _categoryController.text = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      // वस्तुओं की एक डीप कॉपी बनाएं
      _items = widget.expense!.items
          .map((item) => BilledItem(
                itemName: item.itemName,
                quantity: item.quantity,
                rate: item.rate,
              ))
          .toList();
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  // दिनांक चुनने के लिए
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // एक नया आइटम जोड़ने के लिए डायलॉग दिखाएं
  void _showAddItemDialog() {
    final itemNameController = TextEditingController();
    final qtyController = TextEditingController();
    final rateController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Billed Item'),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: qtyController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: rateController,
                decoration: InputDecoration(labelText: 'Rate (Rs)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState!.validate()) {
                // इनपुट को double में Parse करना आवश्यक है
                final parsedQuantity = double.tryParse(qtyController.text);
                final parsedRate = double.tryParse(rateController.text);

                if (parsedQuantity != null && parsedRate != null) {
                  setState(() {
                    _items.add(BilledItem(
                      itemName: itemNameController.text,
                      quantity: parsedQuantity,
                      rate: parsedRate,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // खर्च को सहेजें/अपडेट करें
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one billed item.')),
        );
        return;
      }

      final expenseToSave = Expense(
        // यदि संपादन हो रहा है, तो मौजूदा ID का उपयोग करें
        id: widget.expense?.id,
        date: _selectedDate,
        category: _categoryController.text,
        items: _items,
      );

      // addOrUpdateExpense विधि का उपयोग करें
      _expenseService.addOrUpdateExpense(expenseToSave).then((_) {
        // सूची को रीफ्रेश करने के लिए true लौटाएं
        Navigator.of(context).pop(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // कुल राशि की गणना
    double totalAmount =
        _items.fold(0.0, (sum, item) => sum + (item.quantity * item.rate));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? 'Edit Expense' : 'Add Expense',
            style: TextStyle(color: Colors.white)),
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            // Expense Category
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Expense Category',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a category' : null,
            ),
            SizedBox(height: 16),

            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  'Expense Date: ${DateFormat.yMd().format(_selectedDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            Divider(),

            // Billed Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Billed Items',
                    style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: _showAddItemDialog,
                  icon: Icon(Icons.add, color: Colors.white),
                  label:
                      Text('Add Item', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.kSecondaryThemeColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Items List
            _items.isEmpty
                ? Center(child: Text('No items added yet.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.itemName),
                          subtitle: Text(
                              'Qty: ${item.quantity.toStringAsFixed(0)}, Rate: ${item.rate.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (item.quantity * item.rate).toStringAsFixed(2),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _items.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            Divider(),

            // Total Amount
            SizedBox(height: 20),
            Text(
              'Total Amount: Rs/${totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),

            // Save Button
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.kPrimaryThemeColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                  widget.expense != null ? 'Save Changes' : 'Save Expense',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class PreferenceService {
  static const _key = 'expenses';

  // सभी खर्चों को सहेजें
  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> expensesJson =
        expenses.map((expense) => jsonEncode(expense.toJson())).toList();
    await prefs.setStringList(_key, expensesJson);
  }

  // सभी खर्चों को पुनः प्राप्त करें
  Future<List<Expense>> getExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList(_key);
    if (expensesJson == null) {
      return [];
    }
    return expensesJson
        .map((jsonString) => Expense.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  // एक नया खर्च जोड़ें या किसी मौजूदा को अपडेट करें (नया फ़ंक्शन)
  Future<void> addOrUpdateExpense(Expense newOrUpdatedExpense) async {
    List<Expense> expenses = await getExpenses();

    // जांचें कि क्या यह संपादन है (यदि ID मौजूद है)
    int existingIndex =
        expenses.indexWhere((expense) => expense.id == newOrUpdatedExpense.id);

    if (existingIndex != -1) {
      // यह संपादन है: मौजूदा खर्च को अपडेट करें
      expenses[existingIndex] = newOrUpdatedExpense;
    } else {
      // यह जोड़ है: सूची में नया खर्च जोड़ें
      expenses.add(newOrUpdatedExpense);
    }

    await saveExpenses(expenses);
  }

  // एक खर्च को हटाएं
  Future<void> deleteExpense(String id) async {
    List<Expense> expenses = await getExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    await saveExpenses(expenses);
  }
}

var uuid = Uuid();

// एक बिल में प्रत्येक आइटम के लिए क्लास
class BilledItem {
  String itemName;
  double quantity;
  double rate;

  BilledItem({
    required this.itemName,
    required this.quantity,
    required this.rate,
  });

  // JSON से BilledItem ऑब्जेक्ट बनाने के लिए फैक्ट्री कंस्ट्रक्टर
  factory BilledItem.fromJson(Map<String, dynamic> json) {
    return BilledItem(
      itemName: json['itemName'],
      quantity: json['quantity'],
      rate: json['rate'],
    );
  }

  // BilledItem ऑब्जेक्ट को JSON में बदलने के लिए मेथड
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'rate': rate,
    };
  }
}

// पूरे खर्च के लिए क्लास
class Expense {
  String id;
  DateTime date;
  String category;
  List<BilledItem> items;

  Expense({
    String? id,
    required this.date,
    required this.category,
    required this.items,
  }) : this.id = id ??
            uuid.v4(); // यदि कोई आईडी प्रदान नहीं की गई है तो एक यूनिक आईडी बनाएं

  // कुल राशि की गणना करें
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.quantity * item.rate));
  }

  // JSON से Expense ऑब्जेक्ट बनाने के लिए फैक्ट्री कंस्ट्रक्टर
  factory Expense.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<BilledItem> billedItems =
        itemsFromJson.map((item) => BilledItem.fromJson(item)).toList();

    return Expense(
      id: json['id'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      items: billedItems,
    );
  }

  // Expense ऑब्जेक्ट को JSON में बदलने के लिए मेथड
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
