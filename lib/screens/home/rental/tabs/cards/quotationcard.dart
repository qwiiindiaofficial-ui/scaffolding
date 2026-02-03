import 'package:flutter/material.dart';
import 'package:scaffolding_sale/backend/methods.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import '../../../../profile/MyProfile.dart';
import '../../../sale/detail.dart';

class Quotationcard extends StatelessWidget {
  final bool isSecond;
  final VoidCallback? onShiftToCurrent;

  const Quotationcard({
    super.key,
    this.isSecond = false,
    this.onShiftToCurrent,
  });

  @override
  Widget build(BuildContext context) {
    String name = isSecond ? "Mayank Bajaj" : "Tarun| SCAFF00328";
    String date = isSecond ? "17-03-2025" : "5/11/2024";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ThemeColors.kPrimaryThemeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProfile(ticketName: name),
                          ),
                        );
                      },
                      child: CircleAvatar(),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProfile(ticketName: name),
                          ),
                        );
                      },
                      child: CustomText(
                        text: name,
                        size: 16,
                        color: Colors.white,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  CustomText(
                    text: 'Date: $date',
                    color: Colors.black,
                    size: 13,
                    weight: FontWeight.w400,
                    height: 0,
                  ),
                  const Spacer(),
                  const CustomText(
                    text: 'Status: In Review',
                    color: Colors.black,
                    size: 13,
                    weight: FontWeight.w400,
                    height: 0,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),
            Row(
              children: [
                Container(
                  width: 71,
                  height: 28,
                  decoration: ShapeDecoration(
                    color: ThemeColors.kPrimaryThemeColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                  ),
                  child: const Center(
                    child: CustomText(
                      text: 'Per item',
                      color: Colors.white,
                      size: 13,
                      weight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () async {
                    final phone = await AppService().getPhoneNumber();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewDetail1(phone: phone ?? ""),
                      ),
                    );
                  },
                  child: Container(
                    height: 32,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: CustomText(
                        text: 'View Details',
                        align: TextAlign.center,
                        color: Colors.black,
                        size: 13,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    if (onShiftToCurrent != null) {
                      onShiftToCurrent!();
                    }
                  },
                  child: Container(
                    height: 32,
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: CustomText(
                        text: 'Shift to Current',
                        align: TextAlign.center,
                        color: Colors.black,
                        size: 12,
                        weight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
