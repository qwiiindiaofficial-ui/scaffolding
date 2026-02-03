import 'package:flutter/material.dart';

import '../../../widgets/button.dart';
import '../../../widgets/text.dart';
import '../../view detail.dart';

class ViewDetail1 extends StatelessWidget {
  final String phone;
  ViewDetail1({super.key, required this.phone});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'View Detail',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
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
              const Text(
                'Name | User ID',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                phone.contains("93184")
                    ? 'Mitali'
                    : phone.contains("959973")
                        ? "Aryan Bansal"
                        : "Mayank Bajaj",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                'Billing Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Text(
                'Shipping Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Building: Plot no. SC 01 Sector AdJoining Tech Zone,\nGreater Noida West, Gautam Budh Nagar',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: .0, top: 20),
                child: Table(
                  // defaultColumnWidth: const FixedColumnWidth(100),
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    _buildTableRow('Item Name', 'Quant/unit', isHeader: true),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Base/Jack', '20'),
                    _buildTableRow('Scaffolding & Shuttering Area',
                        'Length = 70m\nHeight = 167m\nWidth = 109m'),
                    _buildTableRow(
                        'Scaffolding Requirement', 'this is my requirement...'),
                    _buildTableRow('Total', '20'),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              PrimaryButton(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ViewDetail();
                    }));
                  },
                  text: "Send Quotations"),
              const SizedBox(
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
                  child: const Center(
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
