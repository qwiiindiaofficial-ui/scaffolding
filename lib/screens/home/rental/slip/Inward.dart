import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/sale/Gatepass.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import '../../../../widgets/button.dart';

void showInputDialog(context) async {
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Rounded corners for the dialog
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wraps content
            children: [
              const Text(
                'Enter your data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Type something...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                          null); // Dismiss the dialog without returning data
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Return the text input
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class InwardScreen extends StatefulWidget {
  final bool isInward;
  const InwardScreen({super.key, required this.isInward});

  @override
  State<InwardScreen> createState() => _InwardScreenState();
}

class _InwardScreenState extends State<InwardScreen> {
  String? _firstDropdownValue; // Value of the first dropdown
  String? _selectedSize; // Value for the size
  List<DropdownMenuItem<String>> dropdownItems = [];
  final List<Map<String, String>> savedItems = [
    // {'item': 'base/jack 14"', 'Qty': '5', 'weight': '123'},
    // {'item': 'base/jack 18"', 'Qty': '3', 'weight': '178'},
    // {'item': 'chalie 2 mtr', 'Qty': '2', 'weight': '95'},
    // {'item': 'base/jack 22"', 'Qty': '1', 'weight': '150'},
    // {'item': 'base/jack 14"', 'Qty': '6', 'weight': '110'},
  ];
  @override
  void initState() {
    super.initState();
    // Initialize with static items
    dropdownItems = [
      const DropdownMenuItem(
          value: '+Add items',
          child:
              Text('+Add Items', style: TextStyle(color: Colors.blueAccent))),
      const DropdownMenuItem(
          value: 'Standar',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/UB/DP/MY-20486518/scaffolding-standard.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Standar'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Shuttering material',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://4.imimg.com/data4/XJ/KO/MY-13493688/scaffolding-horizontal-pipe.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Ledger'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Scaffolding Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/JN/EW/MY-15279472/scaffolding-steel-chali-500x500.png"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Challie'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/BM/YS/NM/SELLER-28422253/adjustable-base-jack-scaffolding.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Base Jack'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9XNTIPEpUmgRbBZxTnviRHaItJbJvik1uTQ&s"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('U-Jack'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://image.made-in-china.com/2f0j00qkHbzLASnucp/JIS-48-6mm-Scaffolding-Swivel-Coupler-Fixed-Clamp.webp"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Clapms'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/ANDROID/Default/2022/2/SQ/NR/RM/75031737/product-jpeg-500x500.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Farma'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/SELLER/Default/2023/9/348855128/IF/MI/YS/33744462/adjustable-scaffolding-prop-jack.jpeg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Prop-Jack'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/SELLER/Default/2022/5/AG/IQ/EA/152984662/construction-scaffolding-products-500x500.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Plates'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/SELLER/Default/2022/8/UL/KS/SZ/6419093/shuttering-plywood.png"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Ply'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/SELLER/Default/2020/11/AO/BG/LI/41774422/scaffolding-items.jpeg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Balli'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://m.media-amazon.com/images/I/51CjGVNfooL._AC_UF1000,1000_QL80_.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Sikanja'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://img.4imz.com/media/ALAM6EPO/upload/spanner-on-rent-in-ratlam-1600164980.jpg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Spanner'),
            ],
          )),
      const DropdownMenuItem(
          value: 'Wheel Set',
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://5.imimg.com/data5/SELLER/Default/2024/6/424973270/ZR/GA/LD/103368720/blue-scaffolding-joint-pin-shape-500x500.jpeg"),
              ),
              SizedBox(
                width: 12,
              ),
              Text('Joint Pin'),
            ],
          )),
    ];
  }

  // Function to show the second dropdown when "Standar" is selected
  void _showSecondDropdown(BuildContext context) async {
    final selectedSize = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Size'),
          content: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Select Size',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 13),
            ),
            items: const [
              DropdownMenuItem(value: "0.5 Mtr", child: Text("0.5 Mtr")),
              DropdownMenuItem(value: "1.0 Mtr", child: Text("1.0 Mtr")),
              DropdownMenuItem(value: "1.5 Mtr", child: Text("1.5 Mtr")),
              DropdownMenuItem(value: "2.0 Mtr", child: Text("2.0 Mtr")),
              DropdownMenuItem(value: "2.5 Mtr", child: Text("2.5 Mtr")),
              DropdownMenuItem(value: "3.0 Mtr", child: Text("3.0 Mtr")),
            ],
            onChanged: (value) {
              Navigator.pop(context, value); // Return the selected value
            },
            isExpanded: true,
          ),
        );
      },
    );

    if (selectedSize != null) {
      setState(() {
        _selectedSize = selectedSize;
        _firstDropdownValue = "Standar $_selectedSize";

        // Update the dropdown items to include the combined value
        if (!dropdownItems.any((item) => item.value == _firstDropdownValue)) {
          // Check if item already exists
          dropdownItems.add(DropdownMenuItem(
            value: _firstDropdownValue,
            child: Text(_firstDropdownValue!),
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.teal,
        title: const Text('Inward', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          widget.isInward
              ? Container(
                  color: ThemeColors.kSecondaryThemeColor,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: CustomText(
                      text: "Receive All",
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.isInward ? 'In Which Challan?' : 'In Which Slip?',
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: screenWidth * 0.2), // Responsive spacing
                Text(
                  'Challan No:',
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01), // Responsive spacing
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: widget.isInward
                          ? 'Select Challan No.'
                          : 'Select Slip No.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('Challan 1')),
                      DropdownMenuItem(value: '2', child: Text('Challan 2')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                SizedBox(
                  width: screenWidth * 0.3, // Responsive width
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: widget.isInward ? "Challan No." : 'Slip No.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Row(
              children: [
                // Text(
                //   'Select Date',
                //   style: TextStyle(
                //       fontSize: screenWidth * 0.045,
                //       fontWeight: FontWeight.bold),
                // ),
                // SizedBox(width: screenWidth * 0.02),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Please select a date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        // Handle the picked date
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            Row(
              children: [
                Expanded(
                  // width: screenWidth * 0.2, // Responsive width
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                      hintText: 'Length',
                      hintStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  // width: screenWidth * 0.2, // Responsive width
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                      hintText: 'Height',
                      hintStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  // width: screenWidth * 0.2, // Responsive width
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Width',
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                CircleAvatar(
                  child: Icon(Icons.add),
                )
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            widget.isInward
                ? Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.5, // Fixed width for the dropdown
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Select Items',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 13),
                          ),
                          value: _firstDropdownValue, // Selected value
                          items: dropdownItems, // Use dynamic items
                          onChanged: (value) {
                            if (value == "Standar") {
                              _showSecondDropdown(
                                  context); // Show second dropdown for size selection
                            } else {
                              setState(() {
                                _firstDropdownValue =
                                    value; // Set other selected values directly
                              });
                            }
                          },
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      SizedBox(
                        width: screenWidth * 0.2, // Responsive width
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Qty',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      // SizedBox(width: screenWidth * 0.01),
                      Spacer(),
                      CircleAvatar(
                        child: Icon(Icons.add),
                      )
                    ],
                  )
                : Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.5, // Responsive width
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Select Staff',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                                horizontal: 13), // Adjusted padding
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: '+Add Staff',
                                child: Text('+Add Staff',
                                    style:
                                        TextStyle(color: Colors.blueAccent))),
                            DropdownMenuItem(
                                value: 'Scaffolding material',
                                child: Text('Helper')),
                            DropdownMenuItem(
                                value: 'Scaffolding material',
                                child: Text('Helper')),
                            DropdownMenuItem(
                                value: 'Scaffolding material',
                                child: Text('Helper')),
                            DropdownMenuItem(
                                value: 'Scaffolding material',
                                child: Text('Helper')),
                          ],
                          onChanged: (value) {},
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      SizedBox(
                        width: screenWidth * 0.28, // Responsive width
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Qty',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Image.asset("images/check.png"),
                    ],
                  ),

            Expanded(
              child: ListView.builder(
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
                                "$totalWeight",
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
                      setState(() {});
                    },
                    child: ListTile(
                      dense: true,
                      title: Row(
                        children: [
                          Text(item['item']!),
                          const Spacer(),
                          Text("${item['Qty']}"),
                          SizedBox(
                            width: 30,
                          ),

                          const Spacer(),
                          Text("${item['weight']}"),
                          const Spacer(),
                          SizedBox(
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
            ),

            // Spacer(),
            // SizedBox(height: screenHeight * 0.04),
            PrimaryButton(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return EditableTableScreen();
                // }));
                // Handle save action
              },
              text: "Save All",
            ),
            // SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }
}
