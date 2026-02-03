import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:scaffolding_sale/screens/purchase/service.dart';

class AddPurchaseScreen extends StatefulWidget {
  final Party party;
  const AddPurchaseScreen({super.key, required this.party});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _purchaseNoController = TextEditingController();
  final _invoiceNoController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  final _dateController = TextEditingController();

  // Dropdown values
  String? _selectedTaxType;
  DateTime? _selectedDate;

  // Item list
  final List<Item> _items = [];

  final PurchaseService _purchaseService = PurchaseService();

  // Dummy Data
  final List<String> _taxTypes = ['No Tax', 'CGST/SGST', 'IGST'];
  final Map<String, List<String>> _itemSizes = {
    'Scaffolding Pipe': ['1.5m', '2.0m', '2.5m', '3.0m'],
    'Coupler': ['Fixed Coupler', 'Swivel Coupler'],
    'Base Jack': ['350mm', '450mm', '600mm'],
    'U-Head Jack': ['350mm', '450mm'],
    'Walkway Plank': ['8 feet', '10 feet'],
    'Shuttering Plate': ['2x3 feet', '3x4 feet'],
  };

  @override
  void dispose() {
    _purchaseNoController.dispose();
    _invoiceNoController.dispose();
    _hsnCodeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _addItem() {
    String? selectedItemName;
    String? selectedSize;
    final quantityController = TextEditingController();
    final rateController = TextEditingController();
    final itemFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: itemFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Item',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedItemName,
                      hint: const Text('Select Item'),
                      items: _itemSizes.keys.map((String value) {
                        return DropdownMenuItem<String>(
                            value: value, child: Text(value));
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedItemName = value;
                          selectedSize = null; // Reset size
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select an item' : null,
                      decoration: const InputDecoration(labelText: 'Item'),
                    ),
                    if (selectedItemName != null &&
                        _itemSizes[selectedItemName]!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedSize,
                        hint: const Text('Select Size'),
                        items:
                            _itemSizes[selectedItemName]!.map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() {
                            selectedSize = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a size' : null,
                        decoration: const InputDecoration(labelText: 'Size'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            decoration:
                                const InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter Qty'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: rateController,
                            decoration:
                                const InputDecoration(labelText: 'Rate'),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter Rate'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (itemFormKey.currentState!.validate()) {
                            setState(() {
                              _items.add(Item(
                                name: selectedItemName!,
                                size: selectedSize,
                                quantity: int.parse(quantityController.text),
                                rate: double.parse(rateController.text),
                              ));
                            });
                            Navigator.of(ctx).pop();
                          }
                        },
                        child: const Text('Add Item to Purchase'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _savePurchase() {
    if (_formKey.currentState!.validate()) {
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please add at least one item.'),
              backgroundColor: Colors.red),
        );
        return;
      }

      final newPurchase = Purchase(
        purchaseNo: _purchaseNoController.text,
        invoiceNo: _invoiceNoController.text,
        partyName: widget.party.name, // Use party from widget
        taxType: _selectedTaxType!,
        date: _selectedDate!,
        hsnCode: _hsnCodeController.text,
        items: _items,
      );

      _purchaseService.addPurchase(newPurchase);
      // Pop back two screens to the main list
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Purchase'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _savePurchase();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: [
            _buildStep1(),
            _buildStep2(),
            _buildStep3(),
          ],
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white),
                    child: Text(_currentStep == 2 ? 'SAVE PURCHASE' : 'NEXT'),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Purchase Details'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.business, color: Colors.teal),
              title: Text(widget.party.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(widget.party.address),
            ),
          ),
          TextFormField(
            controller: _purchaseNoController,
            decoration: const InputDecoration(labelText: 'Purchase No.'),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter Purchase No.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _invoiceNoController,
            decoration: const InputDecoration(labelText: 'Invoice No.'),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter Invoice No.'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTaxType,
            hint: const Text('Select Tax Type'),
            items: _taxTypes.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) => setState(() => _selectedTaxType = value),
            validator: (value) =>
                value == null ? 'Please select a tax type' : null,
            decoration: const InputDecoration(labelText: 'Tax Type'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
                labelText: 'Purchase Date', hintText: 'Select a date'),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(3000),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  _dateController.text = DateFormat.yMMMd().format(pickedDate);
                });
              }
            },
            validator: (value) =>
                value == null || value.isEmpty ? 'Please select a date' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _hsnCodeController,
            decoration: const InputDecoration(labelText: 'HSN / SAC Code'),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter HSN/SAC Code'
                : null,
          ),
        ],
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Add Items'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No items added yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                        'Size: ${item.size ?? "N/A"} | Qty: ${item.quantity} | Rate: ₹${item.rate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${item.amount.toStringAsFixed(2)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
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
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            onPressed: _addItem,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal),
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  Step _buildStep3() {
    double totalAmount = _items.fold(0, (sum, item) => sum + item.amount);
    return Step(
      title: const Text('Review & Save'),
      isActive: _currentStep >= 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review your purchase details before saving.',
              style: TextStyle(fontSize: 16)),
          const Divider(height: 30),
          Text('Party: ${widget.party.name}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Purchase No: ${_purchaseNoController.text}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Date: ${_dateController.text}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text('Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._items.map((item) => ListTile(
                dense: true,
                title: Text(item.name),
                trailing: Text(
                    '${item.quantity} x ₹${item.rate} = ₹${item.amount.toStringAsFixed(2)}'),
              )),
          const Divider(),
          ListTile(
            title: const Text('Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            trailing: Text('₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal)),
          ),
        ],
      ),
    );
  }
}
