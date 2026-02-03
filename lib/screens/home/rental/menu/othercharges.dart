import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';

class Othercharges extends StatelessWidget {
  final bool isSale;
  const Othercharges({super.key, required this.isSale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Other Charges",
          color: ThemeColors.kWhiteTextColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'In Which ${isSale ? "Gate Pass" : "Challan"}?',
                        color: Colors.black,
                        size: 18,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RegisterField(
                          hint: "Select ${isSale ? "Gate Pass" : "Challan"}")
                    ],
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                const SizedBox(
                  width: 120,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'HSN Code',
                        color: Colors.black,
                        size: 18,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RegisterField(hint: "HSN Code")
                    ],
                  ),
                ),
                // Spacer(),
                // SizedBox(
                //   width: 150,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       CustomText(
                //         text: '${isSale ? "Gate Pass" : "Challan"} No:',
                //         color: Colors.black,
                //         size: 18,
                //         weight: FontWeight.w500,
                //         height: 0,
                //       ),
                //       SizedBox(
                //         height: 20,
                //       ),
                //       RegisterField(
                //           hint: "${isSale ? "Gate Pass" : "Challan"} No.")
                //     ],
                //   ),
                // ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            const CustomText(
              text: 'Type',
              color: Colors.black,
              size: 18,
              weight: FontWeight.w500,
              height: 0,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Expanded(
                  child: RegisterField(hint: "Charges Type"),
                ),
                const SizedBox(
                  width: 18,
                ),
                const SizedBox(
                  width: 102,
                  child: RegisterField(hint: "Amount"),
                ),
                const SizedBox(
                  width: 8,
                ),
                IconButton.filled(onPressed: () {}, icon: const Icon(Icons.add))
              ],
            ),
            const Spacer(),
            const SizedBox(
              height: 30,
            ),
            PrimaryButton(
                onTap: () {
                  Navigator.pop(context);
                  Fluttertoast.showToast(msg: "2");
                },
                text: "Save All"),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
