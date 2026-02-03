import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';

class Delivery extends StatelessWidget {
  const Delivery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "OutWard",
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
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'In Which Challan?',
                        color: Colors.black,
                        size: 18,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RegisterField(hint: "Select Challan"),
                    ],
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Challan No:',
                        color: Colors.black,
                        size: 18,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RegisterField(hint: "Challan No."),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const CustomText(
              text: 'Select Date',
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
                  child: RegisterField(hint: "Please Select a Date"),
                ),
                const SizedBox(
                  width: 18,
                ),
                const SizedBox(
                  width: 102,
                  child: RegisterField(hint: "Area"),
                ),
                const SizedBox(
                  width: 8,
                ),
                Image.asset("images/check.png"),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                const Expanded(
                  child: RegisterField(hint: "Select Item"),
                ),
                const SizedBox(
                  width: 18,
                ),
                const SizedBox(
                  width: 102,
                  child: RegisterField(hint: "Qty"),
                ),
                const SizedBox(
                  width: 8,
                ),
                Image.asset("images/check.png"),
              ],
            ),
            const Spacer(),
            const Row(
              children: [
                Expanded(
                  child: RegisterField(hint: "Morning"),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: RegisterField(hint: "Deposit Amount"),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            PrimaryButton(onTap: () {}, text: "Save All"),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
