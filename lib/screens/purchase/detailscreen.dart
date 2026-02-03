import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:scaffolding_sale/screens/purchase/pdf.dart';

class PurchaseDetailScreen extends StatelessWidget {
  final Purchase purchase;

  const PurchaseDetailScreen({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PurchasePDFView(purchase: purchase),
                ),
              );
            },
            tooltip: 'View as PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Card(
              margin: EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice: ${purchase.invoiceNo}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            purchase.taxType,
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Purchase No: ${purchase.purchaseNo}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Divider(height: 24),
                    _buildInfoRow('Party Name', purchase.partyName),
                    SizedBox(height: 8),
                    _buildInfoRow(
                        'Date', DateFormat.yMMMd().format(purchase.date)),
                    SizedBox(height: 8),
                    _buildInfoRow('HSN Code', purchase.hsnCode),
                  ],
                ),
              ),
            ),

            // Items List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...purchase.items.map((item) => _buildItemCard(item)),
                ],
              ),
            ),

            // Amount Summary
            Card(
              margin: EdgeInsets.all(16),
              elevation: 4,
              color: Colors.teal.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAmountRow('Subtotal', purchase.totalAmount),
                    if (purchase.cgst > 0) ...[
                      SizedBox(height: 8),
                      _buildAmountRow('CGST', purchase.cgst, isSmall: true),
                    ],
                    if (purchase.sgst > 0) ...[
                      SizedBox(height: 8),
                      _buildAmountRow('SGST', purchase.sgst, isSmall: true),
                    ],
                    if (purchase.igst > 0) ...[
                      SizedBox(height: 8),
                      _buildAmountRow('IGST', purchase.igst, isSmall: true),
                    ],
                    Divider(height: 24),
                    _buildAmountRow('Grand Total', purchase.grandTotal,
                        isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Item item) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.size != null) ...[
              SizedBox(height: 4),
              Text(
                'Size: ${item.size}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qty: ${item.quantity}'),
                Text('Rate: ₹${item.rate.toStringAsFixed(2)}'),
                Text(
                  'Amount: ₹${item.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount,
      {bool isBold = false, bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmall ? 14 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : (isSmall ? 14 : 16),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.teal : Colors.black87,
          ),
        ),
      ],
    );
  }
}
