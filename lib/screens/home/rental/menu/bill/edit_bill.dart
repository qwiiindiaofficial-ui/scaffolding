import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/select_item.dart';
import '../../../../../utils/colors.dart';
import '../../../../../widgets/button.dart';
import '../../../../../widgets/text.dart';

class EditBill extends StatefulWidget {
  const EditBill({super.key});

  @override
  State<EditBill> createState() => _EditBillState();
}

class _EditBillState extends State<EditBill> {
  TextEditingController controller = TextEditingController();

  // List of Indian States for the Dropdown
  final List<String> indianStates = const [
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
  ];

  String? _selectedState; // Variable to hold the selected state
  int? _selectedValue = 1;

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
                    // From Date
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

                            // Recalculate days if both dates are selected
                            if (fromDate != null && toDate != null) {
                              numberOfDays =
                                  toDate!.difference(fromDate!).inDays + 1;
                            }
                          });
                        }
                      },
                    ),
                    const Divider(),
                    // To Date
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

                            // Recalculate days if both dates are selected
                            if (fromDate != null && toDate != null) {
                              numberOfDays =
                                  toDate!.difference(fromDate!).inDays + 1;
                            }
                          });
                        }
                      },
                    ),
                    const Divider(),
                    // Number of Days
                    if (numberOfDays != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Number of Days: $numberOfDays',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // Charges
                    TextFormField(
                      controller: chargesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fix Charges',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Penalty Charges
                    TextFormField(
                      controller: penaltyChargesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Penalty Charges Per Day',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Process the selected values
                  final charges = chargesController.text;
                  final penaltyCharges = penaltyChargesController.text;

                  print('From Date: $fromDate');
                  print('To Date: $toDate');
                  print('Number of Days: $numberOfDays');
                  print('Charges: $charges');
                  print('Penalty Charges: $penaltyCharges');

                  Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
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
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Edit Bill",
          color: ThemeColors.kWhiteTextColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 24,
              ),
              const CustomText(
                text: 'Bill Type',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Bill Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '1',
                    child: Text('Item/Running Mtr'),
                  ),
                  DropdownMenuItem(
                    value: '4',
                    child: Text('Item & Square Ft'),
                  ),
                  DropdownMenuItem(
                    value: '2',
                    child: Text('Per Square Ft'),
                  ),
                  DropdownMenuItem(
                    value: '3',
                    child: Text('Fix Rate (Every Month)'),
                  ),
                  DropdownMenuItem(
                    value: '4',
                    child: Text('Cubic Mtr'),
                  ),

                  // Add more items as needed
                ],
                onChanged: (value) {
                  if (value == '3') {
                    showFieldSelectionDialog(context);
                  }
                  // Handle bill type selection
                },
              ),
              const SizedBox(
                height: 24,
              ),

              // --- New State Dropdown Added Here ---
              const CustomText(
                text: 'Select State',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: InputDecoration(
                  hintText: 'State',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: indianStates
                    .map((state) => DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedState = newValue;
                  });
                },
              ),
              const SizedBox(
                height: 24,
              ),
              // ------------------------------------

              const CustomText(
                text: 'Enter District',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              const RegisterField(
                hint: "District",
                maxLines: 1,
              ),
              const SizedBox(
                height: 24,
              ),
              const CustomText(
                text: 'Enter Pincode',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              const RegisterField(
                hint: "Pincode",
                maxLines: 1,
              ),
              const SizedBox(
                height: 24,
              ),
              const CustomText(
                text: 'Enter Building Address',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              const RegisterField(
                hint: "Address",
                maxLines: 4,
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                children: const [
                  CustomText(
                    text: 'Opening Balance',
                    color: Colors.black,
                    size: 18,
                    weight: FontWeight.w500,
                    height: 0,
                  ),
                  Spacer(),
                  // CustomText(
                  //   text: 'Opening Items',
                  //   color: Colors.black,
                  //   size: 18,
                  //   weight: FontWeight.w500,
                  //   height: 0,
                  // ),
                  // SizedBox(
                  //   width: 50,
                  // ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(child: RegisterField(hint: "Opening Amount")),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: InkWell(
                    onTap: () async {
                      // Note: I assumed StockScreen is a widget you have defined elsewhere
                      // and it returns an integer quantity.
                      final totalQuantity = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StockScreen()),
                      );
                      setState(() {
                        controller.text = totalQuantity == null
                            ? "0"
                            : totalQuantity.toString();
                      });
                    },
                    child: IgnorePointer(
                      child: RegisterField(
                        enabled: true,
                        controller: controller,
                        hint: "Opening Items",
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final totalQuantity = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StockScreen()),
                            );
                            setState(() {
                              controller.text = totalQuantity == null
                                  ? "0"
                                  : totalQuantity.toString();
                            });
                          },
                          icon: Icon(
                            Icons.add,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              const CustomText(
                text: 'Receiver Name And Mobile Number',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              const RegisterField(
                hint: "Receiver Name And Mobile Number",
              ),
              const SizedBox(
                height: 24,
              ),
              const CustomText(
                text: 'Enable GST Invoicing?',
                color: Colors.black,
                size: 18,
                weight: FontWeight.w500,
                height: 0,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Radio<int>(
                    activeColor: (Colors.green),
                    value: 1,
                    groupValue: _selectedValue,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedValue = value;
                      });
                    },
                  ),
                  const CustomText(
                    text: "SGST+CGST",
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(
                      width: 20), // Add some spacing between the options
                  Radio<int>(
                    activeColor: (Colors.green),
                    value: 2,
                    groupValue: _selectedValue,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedValue = value;
                      });
                    },
                  ),
                  const CustomText(
                    text: "IGST",
                    weight: FontWeight.w500,
                  ),
                  const SizedBox(
                      width: 20), // Add some spacing between the options
                  Radio<int>(
                    activeColor: (Colors.green),
                    value: 3,
                    groupValue: _selectedValue,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedValue = value;
                      });
                    },
                  ),
                  const CustomText(
                    text: "No GST",
                    weight: FontWeight.w500,
                  ),
                ],
              ),

              // const Spacer(),
              PrimaryButton(onTap: () {}, text: "Save All"),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
