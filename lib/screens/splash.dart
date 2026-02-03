import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scaffolding_sale/screens/auth/phonenumber.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:scaffolding_sale/screens/language.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/logo.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getContactPermission();
    _navigateToNextPage();
  }

  getContactPermission() {
    Permission.contacts.request();
  }

  _navigateToNextPage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final phone = preferences.getString('phone');

    await Future.delayed(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => phone == null
              ? PhoneNumberScreen()
              : HomeScreen(
                  phone: phone,
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kWhiteTextColor,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(),
              const SizedBox(
                height: 40,
              ),
              CustomText(
                fontFamily: GoogleFonts.manrope().fontFamily,
                text: "Scaffolding App India",
                color: ThemeColors.kPrimaryThemeColor,
                size: 38,
                align: TextAlign.center,
                height: 0,
                weight: FontWeight.w400,
              )
            ],
          ),
        ),
      ),
    );
  }
}
