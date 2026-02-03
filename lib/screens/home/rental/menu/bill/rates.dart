import 'package:flutter/material.dart';
import 'package:scaffolding_sale/main.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class Rates extends StatelessWidget {
  const Rates({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for the rates
    final rateControllers = [
      TextEditingController(text: "₹ 0.75"),
      TextEditingController(text: "₹ 0.75"),
      TextEditingController(text: "₹ 0.75"),
      TextEditingController(text: "₹ 0.75"),
      TextEditingController(text: "₹ 0.75"),
      TextEditingController(text: "₹ 0.75"),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "View/ Edit Rate",
          color: ThemeColors.kWhiteTextColor,
        ),
        actions: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const CustomText(
                            text: "Add",
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 18,
                          ),
                          const CustomText(
                            text: "Rate",
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const TextField(
                            decoration: InputDecoration(
                              hintText: "0.75",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const Spacer(),
                          PrimaryButton(onTap: () {}, text: "Save"),
                          const SizedBox(
                            height: 24,
                          )
                        ],
                      )));
            },
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: ThemeColors.kSecondaryThemeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Center(
                  child: CustomText(
                    text: "Add",
                    size: 12,
                    color: ThemeColors.kWhiteTextColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const CustomText(
              text: "Standard",
              size: 18,
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < rateControllers.length; i++)
              Column(
                children: [
                  Row(
                    children: [
                      const CustomText(
                        text: "Standard 1.5 mt",
                        size: 15,
                        weight: FontWeight.w400,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: rateControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // IconButton(
                      //   icon: const Icon(Icons.save, color: Colors.black),
                      //   onPressed: () {
                      //     // Handle the save logic for this rate
                      //     print("Updated rate: ${rateControllers[i].text}");
                      //   },
                      // ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            SizedBox(
              height: 20,
            ),
            PrimaryButton(
                onTap: () {
                  launchPDF();
                  Navigator.pop(context);
                },
                text: "Save All")
          ],
        ),
      ),
    );
  }
}
