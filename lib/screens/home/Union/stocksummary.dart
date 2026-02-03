// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/utils/colors.dart';

class Store {
  final String id;
  final String name;

  Store({required this.id, required this.name});
}

class TotalStockSummaryScreen extends StatefulWidget {
  const TotalStockSummaryScreen({super.key});

  @override
  _TotalStockSummaryScreenState createState() =>
      _TotalStockSummaryScreenState();
}

class _TotalStockSummaryScreenState extends State<TotalStockSummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Store selection variables
  Store selectedStore = Store(id: 'a', name: 'Store A');

  // Stock data for different stores
  final Map<String, List<Map<String, dynamic>>> storeStockData = {
    'a': [
      {'date': '2024-12-01', 'received': 150, 'consumed': 80, 'remaining': 70},
      {'date': '2024-12-02', 'received': 200, 'consumed': 60, 'remaining': 210},
      {'date': '2024-12-03', 'received': 100, 'consumed': 90, 'remaining': 220},
      {
        'date': '2024-12-04',
        'received': 250,
        'consumed': 110,
        'remaining': 360
      },
    ],
    'b': [
      {'date': '2024-12-01', 'received': 100, 'consumed': 40, 'remaining': 60},
      {'date': '2024-12-02', 'received': 150, 'consumed': 30, 'remaining': 180},
      {'date': '2024-12-03', 'received': 80, 'consumed': 50, 'remaining': 210},
      {'date': '2024-12-04', 'received': 120, 'consumed': 70, 'remaining': 260},
    ],
  };

  final List<Map<String, dynamic>> ledgerSummary = [
    {
      'type': 'bill',
      'date': '2024-12-01',
      'billNo': 'BILL-001',
      'description': 'Scaffolding Material Purchase',
      'amount': 5000,
      'status': 'Pending'
    },
    {
      'type': 'payment',
      'date': '2024-12-02',
      'paymentNo': 'PAY-001',
      'description': 'Cash Payment',
      'amount': 2000,
      'mode': 'Cash'
    },
    {
      'type': 'bill',
      'date': '2024-12-03',
      'billNo': 'BILL-002',
      'description': 'Equipment Purchase',
      'amount': 3000,
      'status': 'Paid'
    },
    {
      'type': 'payment',
      'date': '2024-12-04',
      'paymentNo': 'PAY-002',
      'description': 'Online Transfer',
      'amount': 1500,
      'mode': 'UPI'
    },
  ];

  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredStockSummary {
    final stockSummary = storeStockData[selectedStore.id] ?? [];
    if (fromDate == null || toDate == null) {
      return stockSummary;
    }
    return stockSummary.where((data) {
      final date = DateTime.parse(data['date']);
      return date.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
          date.isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();
  }

  List<Map<String, dynamic>> get filteredLedgerSummary {
    if (fromDate == null || toDate == null) {
      return ledgerSummary;
    }
    return ledgerSummary.where((data) {
      final date = DateTime.parse(data['date']);
      return date.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
          date.isBefore(toDate!.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: Row(
          children: [
            const Text(
              'Summary',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: DropdownButtonHideUnderline(
            //     child: DropdownButton<Store>(
            //       value: selectedStore,
            //       dropdownColor: ThemeColors.kPrimaryThemeColor,
            //       icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            //       style: const TextStyle(color: Colors.white),
            //       items: stores.map((Store store) {
            //         return DropdownMenuItem<Store>(
            //           value: store,
            //           child: Text(
            //             store.name,
            //             style: const TextStyle(color: Colors.white),
            //           ),
            //         );
            //       }).toList(),
            //       onChanged: (Store? newValue) {
            //         if (newValue != null) {
            //           setState(() {
            //             selectedStore = newValue;
            //           });
            //         }
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf)),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Stock Summary'),
            Tab(text: 'Ledger Summary'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockSummaryTab(),
          _buildLedgerSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildStockSummaryTab() {
    num availableItems = filteredStockSummary.isNotEmpty
        ? filteredStockSummary.last['remaining']
        : 0;
    num dispatchItems =
        filteredStockSummary.fold(0, (sum, item) => sum + item['consumed']);
    num totalItems =
        filteredStockSummary.fold(0, (sum, item) => sum + item['received']);
    num shortItems = totalItems - availableItems - dispatchItems;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildDatePickerRow(),
          const SizedBox(height: 16),
          _buildStockSummaryHeader(
            availableItems: availableItems.toInt(),
            dispatchItems: dispatchItems.toInt(),
            shortItems: shortItems.toInt(),
            totalItems: totalItems.toInt(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStockSummary.length,
              itemBuilder: (context, index) {
                final data = filteredStockSummary[index];
                return _buildStockDetailCard(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerSummaryTab() {
    num totalBills = filteredLedgerSummary
        .where((item) => item['type'] == 'bill')
        .fold(0, (sum, item) => sum + item['amount']);

    num totalPayments = filteredLedgerSummary
        .where((item) => item['type'] == 'payment')
        .fold(0, (sum, item) => sum + item['amount']);

    num balance = totalBills - totalPayments;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildDatePickerRow(),
          const SizedBox(height: 16),
          _buildLedgerSummaryHeader(
            totalBills: totalBills.toInt(),
            totalPayments: totalPayments.toInt(),
            balance: balance.toInt(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      labelColor: ThemeColors.kPrimaryThemeColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: ThemeColors.kPrimaryThemeColor,
                      tabs: const [
                        Tab(text: 'Bills'),
                        Tab(text: 'Payments'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBillsList(),
                        _buildPaymentsList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDatePicker(
          label: "From Date",
          selectedDate: fromDate,
          onDateSelected: (date) => setState(() => fromDate = date),
        ),
        _buildDatePicker(
          label: "To Date",
          selectedDate: toDate,
          onDateSelected: (date) => setState(() => toDate = date),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null) onDateSelected(pickedDate);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate)
                  : label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockSummaryHeader({
    required int availableItems,
    required int dispatchItems,
    required int shortItems,
    required int totalItems,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.kPrimaryThemeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
              "Available", availableItems.toString(), Colors.green),
          _buildSummaryCard(
              "Dispatch", dispatchItems.toString(), Colors.orange),
          _buildSummaryCard("Short", shortItems.toString(), Colors.red),
          _buildSummaryCard("Total", totalItems.toString(), Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLedgerSummaryHeader({
    required int totalBills,
    required int totalPayments,
    required int balance,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.kPrimaryThemeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard("Total Bills", "₹$totalBills", Colors.red),
          _buildSummaryCard("Total Payments", "₹$totalPayments", Colors.green),
          _buildSummaryCard(
            "Balance",
            "₹$balance",
            balance > 0 ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStockDetailCard(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              data['remaining'].toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          title: Text(
            "Date: ${data['date']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Received: ${data['received']}"),
              Text("Consumed: ${data['consumed']}"),
            ],
          ),
          trailing: Text(
            "Remaining: ${data['remaining']}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillsList() {
    final bills =
        filteredLedgerSummary.where((item) => item['type'] == 'bill').toList();

    return ListView.builder(
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        return _buildBillCard(bill);
      },
    );
  }

  Widget _buildPaymentsList() {
    final payments = filteredLedgerSummary
        .where((item) => item['type'] == 'payment')
        .toList();

    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill No: ${bill['billNo']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        bill['status'] == 'Paid' ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bill['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bill['description'],
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${bill['date']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  '₹${bill['amount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: ThemeColors.kPrimaryThemeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment No: ${payment['paymentNo']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment['mode'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              payment['description'],
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${payment['date']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  '₹${payment['amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
