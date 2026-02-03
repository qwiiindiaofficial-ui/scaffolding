// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:scaffolding_sale/main.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/rental/delivery.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/edit_bill.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/return.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/outward.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip_notes.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';

class AllBillsScreen extends StatefulWidget {
  const AllBillsScreen({super.key});

  @override
  _AllBillsScreenState createState() => _AllBillsScreenState();
}

class _AllBillsScreenState extends State<AllBillsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'All Bills',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar and buttons in a row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // IconButton(
                //   icon: const Icon(Icons.picture_as_pdf),
                //   onPressed: () {},
                // ),
                // IconButton(
                //   icon: const Icon(Icons.print),
                //   onPressed: () {},
                // ),
                // PopupMenuButton(
                //   icon: const Icon(Icons.more_vert),
                //   itemBuilder: (context) => const [
                //     PopupMenuItem(
                //       child: Text("Delivery Items"),
                //     ),
                //     PopupMenuItem(
                //       child: Text("Receive Items"),
                //     ),
                //     PopupMenuItem(
                //       child: Text("Submit Balance Item"),
                //     ),
                //     PopupMenuItem(
                //       child: Text("View all notes"),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          // TabBar(
          //   isScrollable: true,
          //   controller: _tabController,
          //   tabs: const [
          //     Tab(text: 'All'),
          //     Tab(text: 'Outward'),
          //     Tab(text: 'Inward'),
          //     Tab(text: 'Balance Item'),
          //     Tab(text: 'Payment'),
          //   ],
          //   labelColor: Colors.teal,
          //   indicatorColor: Colors.teal,
          // ),

          // Divider
          const Divider(),

          // Address and Other Information
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MH Shuttering & Scaffolding.\nKHATA NO-199\nGRAM SARFABAD, SECTOR 73\nNoida GAUTAM BUDH NAGAR,\nUTTAR PRADESH- 201307',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Text(
                //     'Rate: ₹ 0.01 Per Sqft, Balance Area: FT²',
                //     style: TextStyle(color: Colors.grey),
                //     textAlign: TextAlign.left,
                //   ),
                // ),
              ],
            ),
          ),

          const Divider(),

          // List of Items
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              // physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return SlipCard();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SlipCard extends StatelessWidget {
  SlipCard({super.key});

  void _onPopupMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Delete':
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const delete();
            },
          ),
        );*/
        break;
      case 'Cancel':
        /* Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const cancel();
            },
          ),
        );*/
        break;
      case 'Outward challan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Delivery();
            },
          ),
        );
        break;
      case 'Inward challan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Return();
            },
          ),
        );
        break;
      case 'E-way/ vehicle/ Edit date No':
        showBottomSheet(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.white,
            context: context,
            builder: (context) {
              return _buildBottomSheet(context);
            });
        break;
      case 'Add Note':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const Notes();
            },
          ),
        );
        break;
      case 'View slip notes':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const SlipNotes();
            },
          ),
        );
        break;
      case 'Site Pic':
        Navigator.pushNamed(context, '/site-pic');
        break;
      case 'Site current location':
        Navigator.pushNamed(context, '/site-current-location');
        break;
      case 'Other Charges':
        showAddChargesDialog(context);
        break;
    }
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bill No.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.0),

          // Text Fields for Bill No., Date, and E-Way Bill No.
          CustomText(
            text: "Bill No.",
          ),
          SizedBox(
            height: 8,
          ),
          RegisterField(
            hint: "Bill No.",
            controller: TextEditingController(text: "11"),
          ),
          SizedBox(
            height: 12,
          ),
          CustomText(
            text: "Date",
          ),
          SizedBox(
            height: 8,
          ),
          RegisterField(
            hint: "Date",
            controller: TextEditingController(text: "27, Oct 2025"),
          ),
          SizedBox(
            height: 12,
          ),

          CustomText(
            text: "Vehicle No.",
          ),
          SizedBox(
            height: 8,
          ),
          RegisterField(
            hint: "Vehicle No.",
            controller: TextEditingController(text: "DL12345"),
          ),
          SizedBox(
            height: 12,
          ),

          CustomText(
            text: "Driver Name / Phone",
          ),
          SizedBox(
            height: 8,
          ),
          RegisterField(
            hint: "Driver Name / Phone",
            controller: TextEditingController(text: "Mayank"),
          ),

          SizedBox(
            height: 12,
          ),
          CustomText(
            text: "E-way Bill No",
          ),
          SizedBox(
            height: 8,
          ),
          RegisterField(hint: "E-way Bill No"),
          SizedBox(
            height: 12,
          ),

          SizedBox(height: 12.0),

          // // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child:
                      PrimaryButton(onTap: () {}, text: "Create E-Way Bill")),
              SizedBox(width: 20.0),
              Expanded(
                  child: PrimaryButton(onTap: () {}, text: "Cancel E-Way Bill"))
            ],
          ),
          SizedBox(height: 10.0),

          PrimaryButton(onTap: () {}, text: "Submit"),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }

  void showAddChargesDialog(BuildContext context) {
    final TextEditingController chargesTypeController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Other Charges"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: chargesTypeController,
                decoration: InputDecoration(
                  labelText: 'Charges Type',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Qty',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without action
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Retrieve input values if needed
                String chargesType = chargesTypeController.text;
                String amount = amountController.text;

                // Add your logic here to handle the entered data

                Navigator.of(context)
                    .pop(); // Close the dialog after handling data
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> savedItems = [
    {
      "item": 'Standar 1.0mtr"',
      "Qty": 0,
      "weight": 0,
    },
    {
      "item": 'Standar 1.0mtr"',
      "Qty": 5,
      "weight": 1.2,
    },
    {
      "item": 'Standar 1.5mtr"',
      "Qty": 5,
      "weight": 1.5,
    },
  ];

  // final List<Map<String, String>> savedItems = [];
  final List<String> items = [
    'Add new items',
    'base/jack 14"',
    'base/jack 18"',
    'base/jack 22"',
    'chalie 2 mtr'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 290,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 58,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        '27 Oct 2025 \nBill No: 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.white),
                      onPressed: () {
                        launchPDF();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.red),
                      onSelected: (value) =>
                          _onPopupMenuSelected(context, value),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'Delete',
                            child: Text("Delete",
                                style: TextStyle(color: Colors.red))),
                        PopupMenuItem(value: 'Cancel', child: Text("Cancel")),
                        // PopupMenuItem(
                        //     value: 'Outward challan',
                        //     child: Text("Outward challan")),
                        // PopupMenuItem(
                        //     value: 'Inward challan',
                        //     child: Text("Inward challan")),
                        PopupMenuItem(
                          value: 'E-way/ vehicle/ Edit date No',
                          child: Text("E-way/ vehicle/ Edit date No"),
                        ),
                        // PopupMenuItem(
                        //   value: 'Add Note',
                        //   child: Text("Add Note"),
                        // ),
                        // PopupMenuItem(
                        //   value: 'View slip notes',
                        //   child: Text("View slip notes"),
                        // ),
                        // PopupMenuItem(
                        //   value: 'Add Item',
                        //   child: Text("Add Item"),
                        // ),
                        PopupMenuItem(
                          value: 'Other Charges',
                          child: Text("Other Charges"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    savedItems.length + 1, // Add 1 for the total row at the end
                itemBuilder: (context, index) {
                  // If it's the last item, show the total
                  if (index == savedItems.length) {
                    double totalQty = 0;
                    double totalWeight = 0;
                    double totalRate = 0;

                    // Calculate the totals for Qty, Weight, and Rate
                    for (var item in savedItems) {
                      totalQty += num.parse(item['Qty'].toString());
                      totalWeight += num.parse(item['weight'].toString());
                      totalRate += num.parse(item['Qty'].toString()) *
                          120; // Assuming "120" is the rate, you can modify this as needed
                    }

                    return Column(
                      children: [
                        // ignore: prefer_const_constructors
                        // ListTile(
                        //   dense: true,
                        //   title: const Row(
                        //     children: [
                        //       Tooltip(
                        //         message: "hey this is message",
                        //         child: Icon(Icons.info),
                        //       ),
                        //       SizedBox(
                        //         width: 8,
                        //       ),
                        //       Text(
                        //         "Round Of Weight Diff.:",
                        //         style: TextStyle(fontWeight: FontWeight.bold),
                        //       ),
                        //       Spacer(),
                        //       Text(
                        //         "4",
                        //         style: TextStyle(fontWeight: FontWeight.bold),
                        //       ),
                        //       SizedBox(
                        //         width: 30,
                        //       ),
                        //       Spacer(),
                        //       Text(
                        //         "120",
                        //         style: TextStyle(fontWeight: FontWeight.bold),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        ListTile(
                          dense: true,
                          title: Row(
                            children: [
                              const Text(
                                "Total                  ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                "$totalQty",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ), // Total Quantity
                              const Spacer(),
                              Text(
                                "200",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ), // Total Weight
                              const Spacer(),
                              Text(
                                "$totalRate",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ), // Total Rate
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final item = savedItems[index];
                  if (index == 0) {
                    return const ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Text("Item Name"),
                          Spacer(),
                          Text("Qty"),
                          Spacer(),
                          Text("Weight"),
                          Spacer(),
                          Text("Rate"),
                        ],
                      ),
                    );
                  }

                  return Dismissible(
                    background: Container(
                      color: Colors.red,
                      child: const Center(
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      savedItems.removeAt(index);
                      // setState(() {});
                    },
                    child: ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Text(item['item']!),
                          const Spacer(),
                          Text("${item['Qty']}"),
                          const SizedBox(
                            width: 30,
                          ),

                          const Spacer(),
                          Text("${item['weight']}"),
                          const Spacer(),
                          const SizedBox(
                            width: 30,
                          ),
                          const Text("120"),
                          // You can change this to item['rate'] if the rate varies
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlipDetailRow extends StatelessWidget {
  final String title;
  final String value;
  final String issueCount;
  final Color iconColor;

  const SlipDetailRow({
    required this.title,
    required this.value,
    required this.issueCount,
    required this.iconColor,
    super.key,
  });

  void _onPopupMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Edit':
        Navigator.pushNamed(context, '/edit');
        break;
      case 'Move to other challan':
        Navigator.pushNamed(context, '/move-challan');
        break;
      case 'Delete':
        Navigator.pushNamed(context, '/delete');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: iconColor, size: 12),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(title),
          ),
          const SizedBox(width: 12),
          Text(value),
          const SizedBox(width: 78.0),
          Text(issueCount),
          // PopupMenuButton<String>(
          //   icon: const Icon(Icons.more_vert, color: Colors.green),
          //   onSelected: (value) => _onPopupMenuSelected(context, value),
          //   itemBuilder: (context) => const [
          //     PopupMenuItem(value: 'Edit', child: Text("Edit")),
          //     // PopupMenuItem(
          //     //     value: 'Move to other challan',
          //     //     child: Text("Move to other challan")),
          //     PopupMenuItem(
          //         value: 'Delete',
          //         child: Text("Delete", style: TextStyle(color: Colors.red))),
          //   ],
          // ),
        ],
      ),
    );
  }
}

class SlipDetailRow2 extends StatelessWidget {
  final String title;
  final String value;
  final String issueCount;
  final String weight;
  final Color iconColor;

  const SlipDetailRow2({
    required this.title,
    required this.value,
    required this.issueCount,
    required this.iconColor,
    super.key,
    required this.weight,
  });

  void _onPopupMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'Edit':
        Navigator.pushNamed(context, '/edit');
        break;
      case 'Move to other challan':
        Navigator.pushNamed(context, '/move-challan');
        break;
      case 'Delete':
        Navigator.pushNamed(context, '/delete');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: iconColor, size: 12),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(title),
          ),
          // Spacer(),
          // Text(weight),
          const Spacer(),
          Text(value),
          const Spacer(),
          Text(issueCount),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.transparent),
            onSelected: (value) => _onPopupMenuSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Edit', child: Text("Edit")),
              // PopupMenuItem(
              //     value: 'Move to other challan',
              //     child: Text("Move to other challan")),
              PopupMenuItem(
                  value: 'Delete',
                  child: Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}
