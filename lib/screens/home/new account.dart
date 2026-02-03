import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/select_item.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewAccountScreen extends StatefulWidget {
  // Accepts the newly created party's data
  String accountType;

  NewAccountScreen({
    super.key,
    required this.accountType,
  });

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  // --- STATE VARIABLES ---
  bool check = false; // "Want to use my Number?" checkbox
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController =
      TextEditingController(text: "7303408500");
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  String _accountType = 'Rent'; // Default value is 'Sale'
  String? _selectedState;

  bool _useSameAddress = true; // Controls the "same address" checkbox
  String _billingAddress = ''; // Stores the main billing address

  // --- NEW: State for Autocomplete and Data Loading ---
  bool _isLoading = true;
  List<Map<String, dynamic>> _allParties = [];

  final List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry'
  ];

  @override
  void initState() {
    super.initState();
    _loadParties(); // Load parties when the screen starts
  }

  setAccountType() {
    setState(() {
      _accountType = widget.accountType;
    });
  }

  // --- NEW: Loads parties from SharedPreferences ---
  Future<void> _loadParties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? partiesJsonList = prefs.getStringList('parties_list');

      if (partiesJsonList != null && partiesJsonList.isNotEmpty) {
        List<Map<String, dynamic>> loadedParties = [];

        for (String partyJson in partiesJsonList) {
          try {
            final Map<String, dynamic> partyData = jsonDecode(partyJson);
            loadedParties.add(partyData);
          } catch (e) {
            print('Error parsing party data: $e');
          }
        }
        setState(() {
          _allParties = loadedParties;
        });
      }
    } catch (e) {
      print('Error loading parties: $e');
      Fluttertoast.showToast(msg: "Error loading customers");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- NEW: Helper functions to get data from party map ---
  String _getPartyName(Map<String, dynamic> party) {
    if (party['gst_legal_name'] != null && party['gst_legal_name'].isNotEmpty) {
      return party['gst_legal_name'];
    }
    if (party['aadhaar_name'] != null && party['aadhaar_name'].isNotEmpty) {
      return party['aadhaar_name'];
    }
    return party['name'] ?? '';
  }

  String _getPartyAddress(Map<String, dynamic> party) {
    if (party['gst_address'] != null && party['gst_address'].isNotEmpty) {
      return party['gst_address'];
    }
    return party['aadhaar_address'] ?? '';
  }

  String _getPartyPhone(Map<String, dynamic> party) {
    if (party['owner_contact_number'] != null &&
        party['owner_contact_number'].isNotEmpty) {
      return party['owner_contact_number'];
    }
    return party['mobile_number'] ?? '';
  }

  void showFieldSelectionDialog(BuildContext context) {
    DateTime? fromDate;
    DateTime? toDate;
    int? numberOfDays;

    final chargesController = TextEditingController();
    final penaltyChargesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Fields'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('From Date'),
                      subtitle: Text(fromDate != null
                          ? fromDate.toString().substring(0, 10)
                          : 'Select a date'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            fromDate = selectedDate;
                            if (fromDate != null && toDate != null) {
                              numberOfDays =
                                  toDate!.difference(fromDate!).inDays + 1;
                            }
                          });
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('To Date'),
                      subtitle: Text(toDate != null
                          ? toDate.toString().substring(0, 10)
                          : 'Select a date'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            toDate = selectedDate;
                            if (fromDate != null && toDate != null) {
                              numberOfDays =
                                  toDate!.difference(fromDate!).inDays + 1;
                            }
                          });
                        }
                      },
                    ),
                    const Divider(),
                    if (numberOfDays != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Number of Days: $numberOfDays',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    TextFormField(
                      controller: chargesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Fix Charges',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: penaltyChargesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Penalty Charges Per Day',
                          border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Submit')),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('New Account', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- NEW: Autocomplete TextField ---
              Autocomplete<Map<String, dynamic>>(
                // Function that builds the suggestion list
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  if (_isLoading) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return _allParties.where((party) {
                    final name = _getPartyName(party).toLowerCase();
                    final query = textEditingValue.text.toLowerCase();
                    return name.contains(query);
                  });
                },
                // How each option is displayed in the list
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(_getPartyName(option)),
                              subtitle: Text(
                                _getPartyAddress(option),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                // What to display in the text field itself after selection
                displayStringForOption: (option) => _getPartyName(option),
                // The text field UI
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search By Party Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  );
                },
                // Action to perform when an option is selected
                onSelected: (selection) {
                  setState(() {
                    // Populate fields based on selection
                    _receiverNameController.text = _getPartyName(selection);
                    phoneController.text = _getPartyPhone(selection);

                    final selectedAddress = _getPartyAddress(selection);
                    _billingAddress = selectedAddress;

                    if (_useSameAddress) {
                      addressController.text = selectedAddress;
                    }
                    // You might need to parse State, Place, and Pincode from the address string
                    // This part can be complex and depends on your address format
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Account For',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Sale'),
                      value: 'Sale',
                      groupValue: _accountType,
                      onChanged: (value) =>
                          setState(() => _accountType = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Rent'),
                      value: 'Rent',
                      groupValue: _accountType,
                      onChanged: (value) =>
                          setState(() => _accountType = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Service'),
                      value: 'Service',
                      groupValue: _accountType,
                      onChanged: (value) =>
                          setState(() => _accountType = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Row(
                children: [
                  Text('Receiver Name',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('Bill Type',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _receiverNameController,
                      decoration: InputDecoration(
                          hintText: 'Receiver Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please enter a name.'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          hintText: 'Bill Type',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0))),
                      items: _accountType == "Sale"
                          ? [
                              DropdownMenuItem(value: '1', child: Text('Kgs')),
                              DropdownMenuItem(value: '2', child: Text('Pcs')),
                              DropdownMenuItem(
                                  value: '3', child: Text('Both Kgs & Pcs')),
                            ]
                          : _accountType == "Service"
                              ? [
                                  DropdownMenuItem(
                                      value: '1', child: Text('Square Feet')),
                                  DropdownMenuItem(
                                      value: '2', child: Text('Cubit Mtr')),
                                ]
                              : const [
                                  DropdownMenuItem(
                                      value: '1', child: Text('Running Mtr')),
                                  DropdownMenuItem(
                                      value: '2', child: Text('Per Square Ft')),
                                  DropdownMenuItem(
                                      value: '3',
                                      child: Text('Fix Rate (Every Month)')),
                                  DropdownMenuItem(
                                      value: '4', child: Text('Cubic Mtr')),
                                  DropdownMenuItem(
                                      value: '5', child: Text('Cubic Ft')),
                                ],
                      onChanged: (value) {
                        if (value == '3' && _accountType == "Rent") {
                          showFieldSelectionDialog(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                value: check,
                onChanged: (value) => setState(() => check = !check),
                title: const CustomText(text: "Want to use my Number?"),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16.0),
              const Text('Phone No (Res)',
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),

              RegisterField(
                hint: "Phone",
                controller: phoneController,
              ),
              const SizedBox(height: 16.0),
              CheckboxListTile.adaptive(
                value: _useSameAddress,
                onChanged: (value) {
                  setState(() {
                    _useSameAddress = value!;
                    if (!_useSameAddress) {
                      addressController.clear();
                      _selectedState = null;
                      placeController.clear();
                      pincodeController.clear();
                    } else {
                      addressController.text = _billingAddress;
                    }
                  });
                },
                title:
                    const Text("Shifting address is same as billing address"),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8.0),

              const Text('Enter Shifting Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                maxLines: 6,
                controller: addressController,
                readOnly: _useSameAddress,
                decoration: InputDecoration(
                    hintText: 'Address',
                    filled: true,
                    fillColor:
                        _useSameAddress ? Colors.grey.shade200 : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0))),
              ),
              const SizedBox(height: 16.0),

              DropdownButtonFormField<String>(
                value: _selectedState,
                isExpanded: true,
                hint: const Text('Select State'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor:
                      _useSameAddress ? Colors.grey.shade200 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: indianStates.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: _useSameAddress
                    ? null
                    : (newValue) {
                        setState(() {
                          _selectedState = newValue;
                        });
                      },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: placeController,
                      readOnly: _useSameAddress,
                      decoration: InputDecoration(
                        hintText: 'Place',
                        filled: true,
                        fillColor: _useSameAddress
                            ? Colors.grey.shade200
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: pincodeController,
                      readOnly: _useSameAddress,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Pin Code',
                        filled: true,
                        fillColor: _useSameAddress
                            ? Colors.grey.shade200
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Opening Balance',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Amount',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_accountType == 'Rent')
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            final totalQuantity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const StockScreen()));
                            if (totalQuantity != null) {
                              setState(() => itemController.text =
                                  totalQuantity.toString());
                            }
                          },
                          child: IgnorePointer(
                            child: RegisterField(
                                enabled: true,
                                controller: itemController,
                                hint: "Items",
                                suffixIcon: const Icon(Icons.add)),
                          ),
                        )),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),

              const Text('Enable GST invoicing?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: RadioListTile(
                          title: const Text('SGST+CGST'),
                          value: 'sgst_cgst',
                          groupValue: 'sgst_cgst',
                          onChanged: (value) {})),
                  Expanded(
                      child: RadioListTile(
                          title: const Text('IGST'),
                          value: 'igst',
                          groupValue: 'sgst_cgst',
                          onChanged: (value) {})),
                ],
              ),
              const SizedBox(height: 16.0),
              PrimaryButton(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: "Account already added for Elatio By Gards LLP");
                  },
                  text: "Save All"),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
