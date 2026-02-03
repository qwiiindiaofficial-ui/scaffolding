import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/colors.dart';
import '../../widgets/button.dart';
import '../../widgets/logo.dart';
import '../../widgets/text.dart';

class OTPScreen extends StatelessWidget {
  final String phone;
  final String otp;

  const OTPScreen({super.key, required this.otp, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kPrimaryThemeColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 90,
                ),
                const AppLogo(),
                const SizedBox(
                  height: 60,
                ),
                CustomText(
                  text: "OTP code sent on: XXX XXX XXXX",
                  size: 18,
                  align: TextAlign.center,
                  weight: FontWeight.w500,
                  color: ThemeColors.kWhiteTextColor,
                ),
                const SizedBox(
                  height: 25,
                ),
                CustomText(
                  text: "OTP will be entered automatically once received.",
                  size: 16,
                  weight: FontWeight.w400,
                  align: TextAlign.center,
                  color: ThemeColors.kWhiteTextColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomText(
                  align: TextAlign.center,
                  text: "If it does not work please enter manually",
                  size: 16,
                  weight: FontWeight.w400,
                  color: ThemeColors.kWhiteTextColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                      decoration: const BoxDecoration(border: Border()),
                    ),
                    preFilledWidget: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 56,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    length: 6,
                    separatorBuilder: (index) => const SizedBox(width: 8),
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) async {
                      if (pin == otp) {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();

                        preferences.setString("phone", phone);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return RegisterForm(phone: phone);
                            },
                          ),
                        );
                      } else {
                        Fluttertoast.showToast(msg: "Invalid OTP");
                      }
                    },
                    onChanged: (value) {
                      debugPrint('onChanged: $value');
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                PrimaryButton(
                    onTap: () {
                      Fluttertoast.showToast(msg: "Please Enter Valid OTP");
                    },
                    text: "Continue"),
                // Add extra padding when keyboard is visible
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
