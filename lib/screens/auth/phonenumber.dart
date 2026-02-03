import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/utils/app_helpers.dart';
import '../../utils/colors.dart';
import '../../widgets/button.dart';
import '../../widgets/logo.dart';
import '../../widgets/text.dart';
import 'otp.dart';

class PhoneNumberScreen extends StatelessWidget {
  PhoneNumberScreen({super.key});

  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
            // Set minimum height to ensure content fills screen
            height: MediaQuery.of(context).size.height,
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
                    text: "Enter Mobile Number",
                    size: 18,
                    weight: FontWeight.w500,
                    color: ThemeColors.kWhiteTextColor,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CustomText(
                              text: "+91",
                              size: 13,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            onChanged: (value) {
                              if (value.length == 10) {
                                // Hide keyboard when 10 digits are entered
                                FocusScope.of(context).unfocus();
                              }
                            },
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
                              hintText: "Enter Mobile Number",
                              counterText: "",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(), // This will push the button to the bottom
                  PrimaryButton(
                    onTap: () async {
                      final value = _phoneController.text;
                      if (value.isEmpty) {
                        showError("Please Enter Your Mobile Number");
                      } else if (value.length != 10) {
                        showError("Mobile number must be 10 digits");
                      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        showError("Enter a valid Indian mobile number");
                      } else {
                        try {
                          showLoadingDialog('Sending OTP...');
                          final phoneNumber = '+91$value';
                          await AppController.to.loginWithPhone(phoneNumber);
                          closeLoadingDialog();
                          showSuccess('OTP sent to $phoneNumber');
                          if (mounted) {
                            Get.to(() => OTPScreen(
                              phone: value,
                            ));
                          }
                        } catch (e) {
                          closeLoadingDialog();
                          handleError(e);
                        }
                      }
                    },
                    text: "Next",
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
