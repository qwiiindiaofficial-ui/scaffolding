import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/othercharges.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../profile/MyProfile.dart';
import 'package:path_provider/path_provider.dart';
import '../menu/bill/bills.dart';

class All extends StatefulWidget {
  const All({super.key});

  @override
  State<All> createState() => _AllState();
}

class _AllState extends State<All> {
  final List<bool> radioColors = [true, false, true, false];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterField(hint: "Search By Name"),
        SizedBox(
          height: 16,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (context, index) {
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
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyProfile(
                                                  ticketName: "Tarun",
                                                )));
                                  },
                                  child: CircleAvatar()),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyProfile(
                                                ticketName:
                                                    "Elatio By Gards LLP",
                                              )));
                                },
                                child: const CustomText(
                                  text: "Elatio By Gards LLP",
                                  size: 16,
                                  color: Colors.white,
                                  weight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              /*InkWell(
                                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>NewAccountScreen()));},
                                child: Container(
                                  height: 28,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Center(
                                      child: CustomText(
                                        text: "   New Site   ",
                                        size: 13,
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                              const SizedBox(
                                width: 8,
                              ),
                            ],
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
                              activeColor: radioColors[index]
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.44,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25.0),
                                          topRight: Radius.circular(25.0),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 24,
                                            ),
                                            const Row(
                                              children: [
                                                CustomText(
                                                  text:
                                                      "AC No: 94 (8744990555)",
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
                                            // ListTile(
                                            //   onTap: () {
                                            //     Navigator.push(context,
                                            //         MaterialPageRoute(
                                            //             builder: (context) {
                                            //       return const ViewPayment();
                                            //     }));
                                            //   },
                                            //   minVerticalPadding: 0,
                                            //   dense: true,
                                            //   contentPadding:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 6,
                                            //           vertical: 0),
                                            //   leading: Image.asset(
                                            //       "images/payment.png"),
                                            //   title: const CustomText(
                                            //     text: "View Payment",
                                            //     color: Colors.green,
                                            //     weight: FontWeight.w400,
                                            //     size: 16,
                                            //   ),
                                            //   trailing: const Icon(
                                            //     Icons.arrow_forward_ios,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            /* ListTile(
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
                                            ),*/
                                            // ListTile(
                                            //   onTap: () {
                                            //     Navigator.push(context,
                                            //         MaterialPageRoute(
                                            //             builder: (context) {
                                            //       return const Notes();
                                            //     }));
                                            //   },
                                            //   minVerticalPadding: 0,
                                            //   contentPadding:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 6,
                                            //           vertical: 0),
                                            //   leading: Image.asset(
                                            //       "images/other.png"),
                                            //   title: CustomText(
                                            //     text: "Notes",
                                            //     color: Colors.blue.shade800,
                                            //     weight: FontWeight.w400,
                                            //     size: 16,
                                            //   ),
                                            //   trailing: const Icon(
                                            //     Icons.arrow_forward_ios,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
                                            /*  */ /*ListTile(
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
                                            ),*/

                                            ListTile(
                                              onTap: () {
                                                /*Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                          return const Notes();
                                                        }));*/
                                              },
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0),
                                              leading: Icon(
                                                  Icons.account_circle_rounded),
                                              title: const CustomText(
                                                text: "Account Reopen",
                                                color: Colors.black,
                                                weight: FontWeight.w400,
                                                size: 16,
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.black,
                                              ),
                                            ),
                                            /*
                                            const Divider(),
                                            ListTile(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                          return const EditBill();
                                                        }));
                                              },
                                              minVerticalPadding: 0,
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                              leading:
                                              Image.asset("images/edit.png"),
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
                                            */ /*ListTile(
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
                                            ),*/ /*
                                            */ /*ListTile(
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
                                            ),*/ /*
                                            */ /*ListTile(
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
                                            ),*/ /*
                                            const Divider(),*/
                                            // ListTile(
                                            //   onTap: () {
                                            //     Navigator.push(context,
                                            //         MaterialPageRoute(
                                            //             builder: (context) {
                                            //       return const Bills();
                                            //     }));
                                            //   },
                                            //   minVerticalPadding: 0,
                                            //   contentPadding:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 6,
                                            //           vertical: 0),
                                            //   leading: Image.asset(
                                            //       "images/invoice.png"),
                                            //   title: const CustomText(
                                            //     text: "Bills",
                                            //     color: Colors.black,
                                            //     weight: FontWeight.w400,
                                            //     size: 16,
                                            //   ),
                                            //   trailing: const Icon(
                                            //     Icons.arrow_forward_ios,
                                            //     color: Colors.black,
                                            //   ),
                                            // ),
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
                      ), /*
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
                       const SizedBox(
                        height: 12,
                      ),
                       Padding(
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
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFF4242),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CustomText(
                                      text: 'Outward',
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
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff077D07),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CustomText(
                                      text: 'Inward',
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
                                  height: 36,
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8),
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
                     const SizedBox(
                        height: 10,
                      ),*/
                    ],
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class Closed extends StatefulWidget {
  const Closed({super.key});

  @override
  State<Closed> createState() => _ClosedState();
}

class _ClosedState extends State<Closed> {
  final List<bool> radioColors = [true, false, true, false];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterField(hint: "Search By Name"),
        SizedBox(
          height: 24,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: 0,
            itemBuilder: (context, index) {
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
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyProfile(
                                                  ticketName: "Tarun",
                                                )));
                                  },
                                  child: CircleAvatar()),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyProfile(
                                                ticketName: "Tarun",
                                              )));
                                },
                                child: const CustomText(
                                  text: "Tarun",
                                  size: 16,
                                  color: Colors.white,
                                  weight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              CustomText(
                                size: 16,
                                color: Colors.white,
                                weight: FontWeight.w500,
                                text: "SCAFF00124u",
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              /*InkWell(
                                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>NewAccountScreen()));},
                                child: Container(
                                  height: 28,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Center(
                                      child: CustomText(
                                        text: "   New Site   ",
                                        size: 13,
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                              const SizedBox(
                                width: 8,
                              ),
                            ],
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
                              activeColor: radioColors[index]
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.44,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25.0),
                                          topRight: Radius.circular(25.0),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 24,
                                            ),
                                            const Row(
                                              children: [
                                                CustomText(
                                                  text:
                                                      "AC No: 94 (8744990555)",
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
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return const ViewPayment();
                                                }));
                                              },
                                              minVerticalPadding: 0,
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0),
                                              leading: Image.asset(
                                                  "images/payment.png"),
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
                                            /* ListTile(
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
                                            ),*/
                                            ListTile(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return const Notes();
                                                }));
                                              },
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0),
                                              leading: Image.asset(
                                                  "images/other.png"),
                                              title: CustomText(
                                                text: "Notes",
                                                color: Colors.blue.shade800,
                                                weight: FontWeight.w400,
                                                size: 16,
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.black,
                                              ),
                                            ),
                                            /*  */ /*ListTile(
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
                                            ),*/

                                            ListTile(
                                              onTap: () {
                                                /*Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                          return const Notes();
                                                        }));*/
                                              },
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0),
                                              leading: Icon(
                                                  Icons.account_circle_rounded),
                                              title: const CustomText(
                                                text: "Account Reopen",
                                                color: Colors.black,
                                                weight: FontWeight.w400,
                                                size: 16,
                                              ),
                                              trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.black,
                                              ),
                                            ),
                                            /*
                                            const Divider(),
                                            ListTile(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                          return const EditBill();
                                                        }));
                                              },
                                              minVerticalPadding: 0,
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                              leading:
                                              Image.asset("images/edit.png"),
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
                                            */ /*ListTile(
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
                                            ),*/ /*
                                            */ /*ListTile(
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
                                            ),*/ /*
                                            */ /*ListTile(
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
                                            ),*/ /*
                                            const Divider(),*/
                                            ListTile(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return const Bills();
                                                }));
                                              },
                                              minVerticalPadding: 0,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 0),
                                              leading: Image.asset(
                                                  "images/invoice.png"),
                                              title: const CustomText(
                                                text: "Bills",
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
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 10),
                      //   child: SizedBox(
                      //     width: 286,
                      //     height: 16,
                      //     child: Stack(
                      //       children: [
                      //         Positioned(
                      //           left: 0,
                      //           top: 0,
                      //           child: CustomText(
                      //             text: 'AC No: 57',
                      //             color: Colors.black,
                      //             size: 13,
                      //             weight: FontWeight.w400,
                      //             height: 0,
                      //           ),
                      //         ),
                      //         Positioned(
                      //           left: 72,
                      //           top: 0,
                      //           child: CustomText(
                      //             text: 'Due: ₹39,275',
                      //             color: Color(0xFFCA1313),
                      //             size: 13,
                      //             weight: FontWeight.w400,
                      //             height: 0,
                      //           ),
                      //         ),
                      //         Positioned(
                      //           left: 164,
                      //           top: 0,
                      //           child: CustomText(
                      //             text: '1928 pcs',
                      //             color: Color(0xFF12CA30),
                      //             size: 13,
                      //             weight: FontWeight.w400,
                      //             height: 0,
                      //           ),
                      //         ),
                      //         Positioned(
                      //           left: 230,
                      //           top: 0,
                      //           child: CustomText(
                      //             text: '2 Dec 23',
                      //             color: Colors.black,
                      //             size: 13,
                      //             weight: FontWeight.w400,
                      //             height: 0,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        height: 12,
                      ),
                      /*
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
                       const SizedBox(
                        height: 12,
                      ),
                       Padding(
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
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFF4242),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CustomText(
                                      text: 'Outward',
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
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xff077D07),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CustomText(
                                      text: 'Inward',
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
                                  height: 36,
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8),
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
                     const SizedBox(
                        height: 10,
                      ),*/
                    ],
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  // Track which payments have been called (using index)
  final Set<int> calledPayments = {};

  // Sample due payment data with multiple phone numbers
  final List<Map<String, dynamic>> duePayments = [
    {
      'companyName': 'Elatio By Gards LLP',
      'personName': 'Rajesh Kumar',
      'phones': ['8744990555', '8383052169', '9876543210'],
      'amount': '78,275',
      'paymentType': 'Credit',
      'date': '2 Dec 23',
      'address': 'Building: Plot no. SC 01 Sector AdJoining Tech Zone....',
      'acNo': 'AC No: 94'
    },
    {
      'companyName': 'Tech Solutions Pvt Ltd',
      'personName': 'Priya Sharma',
      'phones': ['9876543210', '9876543211'],
      'amount': '45,000',
      'paymentType': 'Debit',
      'date': '15 Nov 23',
      'address': 'Office 302, Tower B, Cyber City, Greater Noida',
      'acNo': 'AC No: 156'
    },
    {
      'companyName': 'ABC Enterprises',
      'personName': 'Amit Patel',
      'phones': ['8383052169'],
      'amount': '1,25,500',
      'paymentType': 'Credit',
      'date': '20 Oct 23',
      'address': 'Shop No. 45, Main Market, Sector 18, Noida',
      'acNo': 'AC No: 203'
    },
    {
      'companyName': 'XYZ Construction',
      'personName': 'Neha Gupta',
      'phones': ['7654321098', '7654321099', '7654321100', '7654321101'],
      'amount': '92,000',
      'paymentType': 'Credit',
      'date': '5 Dec 23',
      'address': 'Site Office, NH-24, Near Delhi Border',
      'acNo': 'AC No: 87'
    },
  ];

  String getCurrentFinancialYear() {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if (month >= 4) {
      return 'FY ${year}-${(year + 1) % 100}';
    } else {
      return 'FY ${year - 1}-${year % 100}';
    }
  }

  Future<void> generateAndViewPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Pal Scaffolding',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Due Payments Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          getCurrentFinancialYear(),
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.8),
                4: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                  ),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Sr No',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Company Name',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Name',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Phone',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Amount Due',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                ...duePayments.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  var payment = entry.value;
                  List<String> phones = List<String>.from(payment['phones']);

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          index.toString(),
                          style: pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          payment['companyName'],
                          style: pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          payment['personName'],
                          style: pw.TextStyle(fontSize: 11),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          phones.join(' '),
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.blue,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${payment['amount']}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Parties: ${duePayments.length}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Total Amount Due: ${_calculateTotal()}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red700,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path =
        "${directory.path}/due_payments_${getCurrentFinancialYear()}.pdf";

    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(path);
  }

  String _calculateTotal() {
    int total = 0;
    for (var payment in duePayments) {
      String amountStr = payment['amount'].replaceAll(',', '');
      total += int.parse(amountStr);
    }
    return total.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  void _makeCall(int index) async {
    final payment = duePayments[index];
    final List<String> phones = List<String>.from(payment['phones']);

    if (phones.length == 1) {
      // If only one number, call directly
      final Uri launchUri = Uri(scheme: 'tel', path: phones[0]);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        _showCallCompletionDialog(index);
      }
    } else {
      // If multiple numbers, show selection dialog
      _showPhoneSelectionDialog(index, phones);
    }
  }

  void _showPhoneSelectionDialog(int index, List<String> phones) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Number to Call',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: phones.map((phone) {
              return ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // final Uri launchUri = Uri(scheme: 'tel', path: phone);
                  _showCallCompletionDialog(index);
                  // if (await canLaunchUrl(launchUri)) {
                  //   await launchUrl(launchUri);
                  // }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tileColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCallCompletionDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Call Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('How would you like to mark this call?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Keep in pending - do nothing
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text(
                'Keep Pending',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  calledPayments.add(index);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text(
                'Mark as Completed',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard(int index, Map<String, dynamic> payment) {
    final bool isCalled = calledPayments.contains(index);
    final List<String> phones = List<String>.from(payment['phones']);
    final int phoneCount = phones.length;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: isCalled ? Colors.green : Colors.black,
            width: isCalled ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isCalled ? Colors.green.shade50 : Colors.white,
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
                  color: isCalled
                      ? Colors.green.shade700
                      : ThemeColors.kPrimaryThemeColor,
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
                                builder: (context) => MyProfile(
                                      ticketName: payment['personName'],
                                    )));
                      },
                      child: const CircleAvatar(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyProfile(
                                        ticketName: payment['personName'],
                                      )));
                        },
                        child: CustomText(
                          text: payment['companyName'],
                          size: 16,
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isCalled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Called',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: payment['address'],
                      color: Colors.black,
                      size: 13,
                      weight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: MediaQuery.of(context).size.height * 0.66,
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
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    CustomText(
                                      text:
                                          "${payment['acNo']} (${phones.join(', ')})",
                                      size: 18,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.close,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                CustomText(
                                  text:
                                      '${payment['companyName']}\n${phones.join(', ')}',
                                  color: Colors.black,
                                  size: 14,
                                  fontFamily: 'Inter',
                                  weight: FontWeight.w400,
                                  height: 0,
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const Othercharges(isSale: false);
                                    }));
                                  },
                                  minVerticalPadding: 0,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  leading: Image.asset("images/payment.png"),
                                  title: CustomText(
                                    text: "Edit Payment",
                                    color: Colors.blue.shade800,
                                    weight: FontWeight.w400,
                                    size: 16,
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.black),
                                ),
                                const Divider(),
                                ListTile(
                                  onTap: () {},
                                  minVerticalPadding: 0,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  leading: const Icon(Icons.share),
                                  title: const CustomText(
                                    text: "Share",
                                    color: Colors.black,
                                    weight: FontWeight.w400,
                                    size: 16,
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.black),
                                ),
                                const Divider(),
                                ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _makeCall(index);
                                  },
                                  minVerticalPadding: 0,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  leading: const Icon(Icons.call,
                                      color: Colors.green),
                                  title: const CustomText(
                                    text: "Call",
                                    color: Colors.green,
                                    weight: FontWeight.w400,
                                    size: 16,
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomText(
                    text: 'Amount:',
                    color: Colors.black,
                    size: 13,
                    weight: FontWeight.w400,
                    height: 0,
                  ),
                  CustomText(
                    text: '₹${payment['amount']}',
                    size: 13,
                    weight: FontWeight.w600,
                    height: 0,
                  ),
                  CustomText(
                    text: payment['paymentType'],
                    size: 13,
                    weight: FontWeight.w400,
                    height: 0,
                  ),
                  CustomText(
                    text: payment['date'],
                    color: Colors.black,
                    size: 13,
                    weight: FontWeight.w400,
                    height: 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Call Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCalled ? Colors.green : Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    isCalled ? Icons.check_circle : Icons.phone,
                    color: Colors.white,
                  ),
                  label: Text(
                    isCalled
                        ? 'Called - ${payment['personName']}'
                        : 'Call ${payment['personName']} ($phoneCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingPayments = <int>[];
    final calledPaymentsList = <int>[];

    for (int i = 0; i < duePayments.length; i++) {
      if (calledPayments.contains(i)) {
        calledPaymentsList.add(i);
      } else {
        pendingPayments.add(i);
      }
    }

    return Scaffold(
      body: ListView(
        children: [
          // Pending Calls Section
          if (pendingPayments.isNotEmpty) ...[
            Container(
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(Icons.pending_actions, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Calls (${pendingPayments.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  Spacer(),
                  FloatingActionButton.extended(
                    onPressed: generateAndViewPDF,
                    backgroundColor: ThemeColors.kPrimaryThemeColor,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      'Generate PDF',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            ...pendingPayments
                .map((index) => _buildPaymentCard(index, duePayments[index])),
          ],

          // Called Section
          if (calledPaymentsList.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Completed Calls (${calledPaymentsList.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            ...calledPaymentsList
                .map((index) => _buildPaymentCard(index, duePayments[index])),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
