import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/screens/auth/phonenumber.dart';

import '../../utils/colors.dart';
import '../../widgets/button.dart';
import '../../widgets/logo.dart';
import '../../widgets/text.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // 👇 यहां 'English' को डिफ़ॉल्ट मान के रूप में सेट करें
  String? selectedLanguage = 'English';
  final List<String> languages = ['Hindi', 'English', 'Punjabi', 'Hinglish'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kPrimaryThemeColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 90),
                  const AppLogo(),
                  const SizedBox(height: 60),
                  CustomText(
                    text: "Select Language",
                    size: 18,
                    weight: FontWeight.w500,
                    color: ThemeColors.kWhiteTextColor,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedLanguage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: const TextStyle(
                          color: Color(0xFF959595),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        hintText: "Select Language",
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      onChanged: (String? value) {
                        setState(() {
                          selectedLanguage = value;
                        });
                      },
                      items: languages
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    onTap: () {
                      if (selectedLanguage == null) {
                        Fluttertoast.showToast(msg: "Please select a language");
                      } else {
                        // Navigate to next screen or save language preference
                        // Fluttertoast.showToast(
                        //     msg: "Selected language: $selectedLanguage");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return PhoneNumberScreen();
                        }));
                      }
                    },
                    text: "Next",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
