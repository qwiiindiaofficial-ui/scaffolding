import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/screens/auth/phonenumber.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/logo.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppController appController;

  @override
  void initState() {
    super.initState();
    try {
      appController = AppController.to;
    } catch (e) {
      print('Error getting AppController: $e');
    }
    getContactPermission();
    _navigateToNextPage();
  }

  getContactPermission() {
    Permission.contacts.request();
  }

  _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is authenticated
    if (appController.isAuthenticated.value &&
        appController.currentUser.value != null &&
        appController.currentCompany.value != null) {
      // User is already logged in, go to home
      Get.off(() => HomeScreen(phone: appController.currentUser.value!.phoneNumber));
    } else {
      // User not logged in, go to login
      Get.off(() => const PhoneNumberScreen());
    }
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
              const SizedBox(height: 40),
              CustomText(
                fontFamily: GoogleFonts.manrope().fontFamily,
                text: "Scaffolding & Shuttering",
                color: ThemeColors.kPrimaryThemeColor,
                size: 38,
                align: TextAlign.center,
                height: 0,
                weight: FontWeight.w400,
              ),
              const SizedBox(height: 8),
              CustomText(
                fontFamily: GoogleFonts.manrope().fontFamily,
                text: "Professional Edition",
                color: Colors.grey,
                size: 16,
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
