import 'package:flutter/material.dart';

import '../../../widgets/button.dart';
import '../../../widgets/text.dart';
import '../../view detail.dart';
import 'Servicedetailquotation.dart';

class Serviceviewdetail extends StatelessWidget {
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
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
              SizedBox(height: 32),
              Text(
                'Billing Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Building: Plot no. SC 01 Sector AdJoining Tech Zone,\nGreater Noida West, Gautam Budh Nagar',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
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

              /*Padding(
                padding: const EdgeInsets.only(left: 98.0,top: 20),
                child: Table(
                  defaultColumnWidth: FixedColumnWidth(100),

                  border: TableBorder.all(color: Colors.black),
                  children: [
                    _buildTableRow('Item Name', 'Quant/unit', isHeader: true),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Total', '20'),
                  ],
                ),
              ),*/

              SizedBox(height: 260),
              PrimaryButton(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Servicedetailquotation();
                    }));
                  },
                  text: "Send Quotations"),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomText(
                      text: "Pass",
                      size: 20,
                      color: Colors.red,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
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
