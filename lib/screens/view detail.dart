import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/home/rental/select_terms.dart';
import 'package:scaffolding_sale/utils/colors.dart';

import '../widgets/button.dart';

class ViewDetail extends StatefulWidget {
  @override
  _ViewDetailState createState() => _ViewDetailState();
}

class _ViewDetailState extends State<ViewDetail> {
  List<String> selectedQuantUnits = List.generate(4, (index) => 'Quant/unit');
  List<String> selectedQtyKgs = List.generate(4, (index) => 'Qty/kg');
  List<String> selectedRates = List.generate(4, (index) => '');
  late List<TextEditingController> rateControllers;

  final List<String> quantUnits = ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4'];
  final List<String> qtyKgs = ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the default values
    rateControllers = List.generate(
      4,
      (index) => TextEditingController(text: selectedRates[index]),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    for (var controller in rateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'View Detail',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              // Handle call button press
            },
          ),
          IconButton(
            icon: Image.asset('images/whatsapp.png'),
            onPressed: () {
              // Handle WhatsApp button press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name | User ID',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Mayank | 123456789',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Table(
                defaultColumnWidth: FixedColumnWidth(100),
                border: TableBorder.all(color: Colors.black),
                children: [
                  _buildTableRow(
                    'Item',
                    'Quant/unit',
                    'Qty',
                    'Rate',
                    isHeader: true,
                  ),
                  for (int i = 0; i < 4; i++)
                    _buildTableRow(
                      'Base/Jack',
                      selectedQuantUnits[i],
                      selectedQtyKgs[i],
                      selectedRates[i],
                      rowIndex: i,
                    ),
                  TableRow(children: [
                    _buildTableCell(
                      'Scaffolding & Shuttering Area',
                    ),
                    _buildTableCell(
                      'Length = 70m\nHeight = 167m\nWidth = 4m',
                    ),
                    Center(
                      child: _buildTableCell('46760',
                          isBold: true, isHeader: true),
                    ),
                    Container(),
                  ]),

                  TableRow(children: [
                    _buildTableCell(
                      'Scaffolding Requirement',
                    ),
                    _buildTableCell(
                      'this is my requirement...',
                    ),
                    Container(),
                    Container()
                  ]),
                  // _buildTableRow('Scaffolding Requirement',
                  //     'this is my requirement...', "", ""),
                  _buildTableRow('Total', '20', '-', '-', isBold: true),
                ],
              ),
              SizedBox(height: 26),
              TextField(
                decoration: InputDecoration(
                  suffix: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TermsSelectionScreen(
                          editable: true,
                        );
                      }));
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: ThemeColors.kSecondaryThemeColor,
                            shape: BoxShape.circle),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        )),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText:
                      'By accepting this contract, the contractor agrees to comply with all safety regulations, ensure proper installation and maintenance of scaffolding, and take full responsibility for the safety of workers and equipment on site. Failure to adhere may result in termination of the contract.',
                ),
                maxLines: 6,
              ),
              // Spacer(),
              SizedBox(
                height: 24,
              ),
              PrimaryButton(
                onTap: () {
                  Fluttertoast.showToast(msg: "Quotation Sent Successfully");
                  Navigator.pop(context);
                  Navigator.pop(context);
                  // Handle button tap
                },
                text: "Send Quotations",
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String item,
    String quant,
    String qty,
    String rate, {
    bool isHeader = false,
    bool isBold = false,
    int? rowIndex,
  }) {
    return TableRow(
      children: [
        _buildTableCell(item, isHeader: isHeader, isBold: isBold),
        if (isHeader)
          _buildTableCell(quant, isHeader: isHeader, isBold: isBold)
        else
          _buildDropdownTableCell(
            selectedQuantUnits[rowIndex ?? 0],
            quantUnits,
            (newValue) {
              setState(() {
                selectedQuantUnits[rowIndex!] = newValue ?? quantUnits.first;
              });
            },
            isBold: isBold,
          ),
        if (isHeader)
          _buildTableCell(qty, isHeader: isHeader, isBold: isBold)
        else
          _buildDropdownTableCell(
            selectedQtyKgs[rowIndex ?? 0],
            qtyKgs,
            (newValue) {
              setState(() {
                selectedQtyKgs[rowIndex!] = newValue ?? qtyKgs.first;
              });
            },
            isBold: isBold,
          ),
        if (isHeader)
          _buildTableCell(rate, isHeader: isHeader, isBold: isBold)
        else
          _buildEditableTableCell(rate, rowIndex: rowIndex),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold
              ? FontWeight.bold
              : (isHeader ? FontWeight.bold : FontWeight.normal),
          color: isHeader ? Colors.black : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDropdownTableCell(String selectedValue, List<String> options,
      ValueChanged<String?> onChanged,
      {bool isBold = false}) {
    // Ensure the selected value is in the options list
    if (!options.contains(selectedValue)) {
      selectedValue = options.first;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selectedValue,
        onChanged: onChanged,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
        isExpanded: true,
        underline: Container(),
      ),
    );
  }

  Widget _buildEditableTableCell(String rate, {int? rowIndex}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: rateControllers[rowIndex ?? 0],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            selectedRates[rowIndex ?? 0] = value;
          });
        },
      ),
    );
  }
}
