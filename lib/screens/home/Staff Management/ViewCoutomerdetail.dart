import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:scaffolding_sale/widgets/textfield.dart';

class Viewdetail extends StatelessWidget {
  const Viewdetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "View Detail",
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
            const CustomText(
              text: 'Mobile No.',
              color: Colors.black,
              size: 18,
              weight: FontWeight.w500,
              height: 0,
            ),
            const SizedBox(
              height: 12,
            ),
            RegisterField(
              hint: "Mobile No.",
              controller: TextEditingController(),
            ),
            const SizedBox(
              height: 24,
            ),
            const CustomText(
              text: 'OTP',
              color: Colors.black,
              size: 18,
              weight: FontWeight.w500,
              height: 0,
            ),
            const SizedBox(
              height: 12,
            ),
            RegisterField(
              hint: "OTP",
              controller: TextEditingController(),
            ),
            const SizedBox(
              height: 24,
            ),
            const Spacer(),
            PrimaryButton(onTap: () {}, text: "Submit"),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
