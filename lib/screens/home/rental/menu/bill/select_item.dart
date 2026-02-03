import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Map<String, String>> addedItems = [];
  int totalQuantity = 0;

  // Controllers for dialog inputs
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.print))],
        title: Row(
          children: [
            InkWell(
              onTap: () {
                _showAddItemDialog(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColors.kSecondaryThemeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: CustomText(
                    text: "Add Item",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 24),
            CustomText(
              text: "Items List",
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: addedItems.length,
                itemBuilder: (context, index) {
                  final item = addedItems[index];
                  return Dismissible(
                    onDismissed: (direction) {
                      setState(() {
                        addedItems.removeAt(index);
                      });
                    },
                    key: Key(index.toString()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical:
                              4.0), // Reduced vertical padding for a tighter layout
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: ThemeColors.kPrimaryThemeColor,
                                child: Text(
                                  item["name"]![0],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item["name"]!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  item["size"]!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  item["quantity"]!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.grey[
                                300], // Light color for the divider to keep it subtle
                            thickness: 1,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "Total Quantity:",
                    color: Colors.blue,
                    size: 16,
                    weight: FontWeight.bold,
                  ),
                  CustomText(
                    text: "$totalQuantity",
                    color: Colors.blue,
                    size: 16,
                    weight: FontWeight.bold,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            PrimaryButton(
                onTap: () {
                  Navigator.pop(context, totalQuantity);
                },
                text: "Save All"),
          ],
        ),
      ),
    );
  }

  // Function to show the dialog to add item
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Add Item",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: sizeController,
                decoration: InputDecoration(
                  labelText: "Size",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Validate inputs
                String name = nameController.text;
                String qty = quantityController.text;
                String size = sizeController.text;

                if (name.isNotEmpty && qty.isNotEmpty && size.isNotEmpty) {
                  setState(() {
                    addedItems.add({
                      "name": name,
                      "quantity": qty,
                      "size": size,
                    });
                    totalQuantity += int.parse(qty);
                  });

                  nameController.clear();
                  quantityController.clear();
                  sizeController.clear();

                  Fluttertoast.showToast(
                    msg: "Item added successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );

                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                    msg: "Please fill all fields!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              child: Text(
                "Add Item",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
