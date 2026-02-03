import 'package:flutter/material.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const PrimaryButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: ThemeColors.kSecondaryThemeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomText(
            text: text,
            size: 15,
            color: Colors.white,
            weight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
