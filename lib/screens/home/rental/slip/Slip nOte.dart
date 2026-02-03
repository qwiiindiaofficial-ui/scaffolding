import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/rental/tab.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class SlipNOtes extends StatelessWidget {
  const SlipNOtes({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Slip Notes",
          color: ThemeColors.kWhiteTextColor,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Show bottom sheet
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: ThemeColors.kSecondaryThemeColor,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 240,
          ),
          const Center(
              child: SizedBox(
            width: 208,
            child: CustomText(
              text: 'This list is empty, please use Add button to add',
              align: TextAlign.center,
              color: Color(0xFF959595),
              size: 15,
              weight: FontWeight.w400,
              height: 0,
            ),
          ))
        ],
      ),
    );
  }
}
