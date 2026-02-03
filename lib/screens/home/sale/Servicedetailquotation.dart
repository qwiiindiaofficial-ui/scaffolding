import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/home/rental/select_terms.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

import '../../../widgets/button.dart';

class Servicedetailquotation extends StatefulWidget {
  @override
  _ServicedetailquotationState createState() => _ServicedetailquotationState();
}

class _ServicedetailquotationState extends State<Servicedetailquotation> {
  List<String> selectedQuantUnits = List.generate(4, (index) => 'Quant/unit');
  List<String> selectedQtyKgs = List.generate(4, (index) => 'Qty/kg');
  List<String> selectedRates = List.generate(4, (index) => '');
  late List<TextEditingController> rateControllers;
  late List<TextEditingController>
      priceControllers; // Add a controller for price

  final List<String> quantUnits = ['Unit 1', 'Unit 2', 'Unit 3', 'Unit 4'];
  final List<String> qtyKgs = ['Kg 1', 'Kg 2', 'Kg 3', 'Kg 4'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the default values
    rateControllers = List.generate(
      4,
      (index) => TextEditingController(text: selectedRates[index]),
    );
    priceControllers = List.generate(
      4,
      (index) =>
          TextEditingController(), // Initialize with empty values for price
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    for (var controller in rateControllers) {
      controller.dispose();
    }
    for (var controller in priceControllers) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              Text(
                'Billing Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Building: Plot no. SC 01 Sector AdJoining Tech Zone,\nGreater Noida West, Gautam Budh Nagar',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Shipping Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Building: Plot no. SC 01 Sector AdJoining Tech Zone,\nGreater Noida West, Gautam Budh Nagar',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: .0, top: 20),
                child: Table(
                  // defaultColumnWidth: const FixedColumnWidth(100),
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    _buildTableRow('Scaffolding & Shuttering Area',
                        'Length = 70m\nHeight = 167m\nWidth = 109m'),
                    _buildTableRow(
                        'Scaffolding Requirement', 'this is my requirement...'),
                    // _buildTableRowWithTextField(
                    //   'Price', // New row for price
                    // ),
                  ],
                ),
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
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                      child: PrimaryButton(onTap: () {}, text: "Print & View")),
                  // Spacer(),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: PrimaryButton(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                            msg: "Quotation Sent Successfully");
                      },
                      text: "Send Quotations",
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String item, String quant,
      {bool isHeader = false, bool isBold = false}) {
    return TableRow(
      children: [
        _buildTableCell(item, isHeader: isHeader, isBold: isBold),
        _buildTableCell(quant, isHeader: isHeader, isBold: isBold),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            // controller: priceControllers[0], // Bind the controller here
            decoration: InputDecoration(
              hintText: 'Enter Price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ), // Empty cell for price column
      ],
    );
  }

  // New method to build a table row with a TextField for the price
  TableRow _buildTableRowWithTextField(String item) {
    return TableRow(
      children: [
        _buildTableCell(item), // Item column
        _buildTableCell(''), // Empty cell for quantity
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: priceControllers[0], // Bind the controller here
            decoration: InputDecoration(
              hintText: 'Enter Price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
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
}
