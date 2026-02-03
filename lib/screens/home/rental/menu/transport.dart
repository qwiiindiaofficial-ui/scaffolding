import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';

class Transport extends StatefulWidget {
  const Transport({super.key});

  @override
  State<Transport> createState() => _TransportState();
}

class _TransportState extends State<Transport> {
  String? selectedChallan;
  String? selectedTransportType;

  final List<String> ChallansNO = [
    '2139213',
    '123021',
    '243122',
    '1243121',
  ];

  final List<String> items = [
    'Return',
    'Delivery',
  ];

  final List<String> items2 = [
    'Show In Bill',
    'Show In Transport',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Transport",
          color: ThemeColors.kWhiteTextColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: 'In Which Challan?',
                        color: Colors.black,
                        size: 18,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 0.5),
                          color: Colors.white,
                        ),
                        child: DropdownButtonFormField<String>(
                          hint: const Text("Challan No."),
                          value: selectedChallan,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedChallan = newValue;
                            });
                          },
                          items: ChallansNO.map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const CustomText(
              text: 'Type',
              color: Colors.black,
              size: 18,
              weight: FontWeight.w500,
              height: 0,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 0.5),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                hint: const Text("Transport Type"),
                value: selectedTransportType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTransportType = newValue;
                  });
                },
                items: items2.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 0.5),
                      color: Colors.white,
                    ),
                    child: DropdownButtonFormField<String>(
                      hint: const Text("Select Type"),
                      value:
                          selectedTransportType, // Update with a new variable if needed
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTransportType = newValue;
                        });
                      },
                      items:
                          items.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                const SizedBox(
                  width: 102,
                  child: RegisterField(hint: "Amount"),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: () {}, icon: Icon(Icons.add))
              ],
            ),
            const Spacer(),
            const SizedBox(height: 30),
            PrimaryButton(onTap: () {}, text: "Save All"),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
