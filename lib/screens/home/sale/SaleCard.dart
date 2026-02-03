import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scaffolding_sale/screens/home/rental/delivery.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/bills.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/edit_bill.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/rates.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/lostitems.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/oneday_discount.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/othercharges.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/transport.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/screens/home/rental/return.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

import '../../profile/MyProfile.dart';

class SaleCard extends StatelessWidget {
  final bool short;
  const SaleCard({super.key, required this.short});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 44,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ThemeColors.kPrimaryThemeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyProfile()));
                  },
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Image.asset("images/person.png"),
                      const SizedBox(
                        width: 10,
                      ),
                      const CustomText(
                        text: "ALPHABET HEIGHT",
                        size: 16,
                        color: Colors.white,
                        weight: FontWeight.w500,
                      ),
                      const Spacer(),
                      Image.asset("images/location.png"),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset("images/whatsapp.png"),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        height: 34,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Center(
                            child: CustomText(
                              text: "New Site",
                              size: 13,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 260,
                    child: CustomText(
                      text:
                          'Building: Plot no. SC 01 Sector AdJoining Tech Zone....',
                      color: Colors.black,
                      size: 13,
                      weight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  const Spacer(),
                  Radio(
                    value: 1,
                    groupValue: 1,
                    onChanged: (v) {},
                    activeColor: Colors.green,
                  ),
                  InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: MediaQuery.of(context).size.height * 0.9,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  const Row(
                                    children: [
                                      CustomText(
                                        text: "AC No: 94 (8744990555)",
                                        size: 18,
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  const SizedBox(
                                    width: 298,
                                    child: CustomText(
                                      text:
                                          'GC-12 Apartment Owners Association, Same \n8744990555,8383052169',
                                      color: Colors.black,
                                      size: 14,
                                      fontFamily: 'Inter',
                                      weight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const ViewPayment();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/payment.png"),
                                    title: const CustomText(
                                      text: "View Payment",
                                      color: Colors.green,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const LostItems();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/lost.png"),
                                    title: CustomText(
                                      text: "Lost or Damaged charges",
                                      color: Colors.red.shade800,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Othercharges(
                                          isSale: true,
                                        );
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/other.png"),
                                    title: CustomText(
                                      text: "Other charges",
                                      color: Colors.blue.shade800,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Transport();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading:
                                        Image.asset("images/transport.png"),
                                    title: const CustomText(
                                      text: "Transport",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Notes();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/notes.png"),
                                    title: const CustomText(
                                      text: "Account notes",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const EditBill();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/edit.png"),
                                    title: const CustomText(
                                      text: "Edit Bill",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Rates();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/rate.png"),
                                    title: const CustomText(
                                      text: "View/Edit Rate",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const OnedayDiscount();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/percent.png"),
                                    title: const CustomText(
                                      text: "One Day Discount Setting",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Bills();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/today.png"),
                                    title: const CustomText(
                                      text: "View Bill Till Today",
                                      color: Color(0xFF00A27B),
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Bills();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/invoice.png"),
                                    title: const CustomText(
                                      text: "View Bill Till a date",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const Bills();
                                      }));
                                    },
                                    minVerticalPadding: 0,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 0),
                                    leading: Image.asset("images/invoice.png"),
                                    title: const CustomText(
                                      text: "Performa Invoice",
                                      color: Colors.black,
                                      weight: FontWeight.w400,
                                      size: 16,
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.more_vert))
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 286,
                height: 16,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: CustomText(
                        text: 'AC No: 57',
                        color: Colors.black,
                        size: 13,
                        weight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                    Positioned(
                      left: 72,
                      top: 0,
                      child: CustomText(
                        text: 'Due: ₹39,275',
                        color: Color(0xFFCA1313),
                        size: 13,
                        weight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                    Positioned(
                      left: 164,
                      top: 0,
                      child: CustomText(
                        text: '1928 pcs',
                        color: Color(0xFF12CA30),
                        size: 13,
                        weight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                    Positioned(
                      left: 230,
                      top: 0,
                      child: CustomText(
                        text: '2 Dec 23',
                        color: Colors.black,
                        size: 13,
                        weight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            short
                ? Container()
                : Container(
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
            short
                ? Container()
                : const SizedBox(
                    height: 12,
                  ),
            short
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Delivery();
                              }));
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xffFF4242),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CustomText(
                                  text: 'Delivery',
                                  align: TextAlign.center,
                                  color: Colors.white,
                                  size: 13,
                                  weight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Return();
                              }));
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xff077D07),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CustomText(
                                  text: 'Return',
                                  align: TextAlign.center,
                                  color: Colors.white,
                                  size: 13,
                                  weight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return const Slip();
                                }),
                              );
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CustomText(
                                  text: 'Slips',
                                  align: TextAlign.center,
                                  color: Colors.black,
                                  size: 13,
                                  weight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            short
                ? Container()
                : const SizedBox(
                    height: 10,
                  ),
          ],
        ),
      ),
    );
  }
}
