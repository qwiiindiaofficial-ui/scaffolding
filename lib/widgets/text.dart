import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffolding_sale/utils/colors.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final double? size;
  final String? fontFamily;
  final double? height;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? align;

  const CustomText(
      {super.key,
      this.text,
      this.size,
      this.color,
      this.weight,
      this.align,
      this.height,
      this.fontFamily});

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: align ?? TextAlign.start,
      style: TextStyle(
          fontFamily: fontFamily ?? GoogleFonts.inter().fontFamily,
          fontSize: (size) ?? 12,
          color: color ?? ThemeColors.kBlackTextColor,
          fontWeight: weight ?? FontWeight.w600,
          height: height ?? 1),
    );
  }
}
