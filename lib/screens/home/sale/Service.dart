import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scaffolding_sale/backend/methods.dart';
import 'package:scaffolding_sale/screens/All%20Bills.dart';
import 'package:scaffolding_sale/screens/ReminderSetting.dart';

import 'package:scaffolding_sale/screens/home/new%20account.dart';

import 'package:scaffolding_sale/screens/home/rental/menu/bill/bills.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/edit_bill.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/rates.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/lostitems.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/oneday_discount.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/othercharges.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/transport.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/screens/home/rental/select_terms.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/allbill.dart';

import 'package:scaffolding_sale/screens/home/rental/slip/slip.dart';
import 'package:scaffolding_sale/screens/home/rental/tabs/all.dart';
import 'package:scaffolding_sale/screens/home/rental/tabs/due.dart';
import 'package:scaffolding_sale/screens/home/sale/detail.dart';
import 'package:scaffolding_sale/screens/home/sale/salebills.dart';
import 'package:scaffolding_sale/screens/home/sale/servicebills.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import '../../profile/MyProfile.dart';
import '../rental/slip/NewSlip.dart';
import '../rental/slip/ServiceSlip.dart';
import '../rental/slip/slip_notes.dart';
import '../rental/tab.dart';

import 'Bills.dart';
import 'Gatepass.dart';
import 'Serviceviewdetail.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _switchToCurrentTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchToCurrentTab() {
    _tabController.animateTo(2); // Index for the "Current" tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Service",
          color: ThemeColors.kWhiteTextColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewAccountScreen(
                            accountType: "Service",
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
                    text: "New Account",
                    size: 12,
                    color: ThemeColors.kWhiteTextColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(width: 16),
          // const Icon(Icons.wallet, size: 32),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                TabBar(
                  tabAlignment: TabAlignment.start,

                  isScrollable: true,
                  controller: _tabController,
                  // labelPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: ThemeColors.kSecondaryThemeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: "Enquiry"),
                    Tab(text: "Quotation"),
                    Tab(text: "Current"),
                    TabItem(text: "Due Payment"),
                    TabItem(text: "Closed"),
                    Tab(text: "All"),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      Enquiry(),
                      Quotations(onShiftToCurrent: _switchToCurrentTab),
                      Current(),
                      Payment(),
                      Closed(),
                      All(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class All extends StatefulWidget {
  const All({super.key});

  @override
  State<All> createState() => _AllState();
}

class _AllState extends State<All> {
  final List<bool> radioColors = [true, false, true, false];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                                            ticketName: "Elatio By Gards LLP",
                                          )));
                            },
                            child: CircleAvatar(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyProfile(
                                            ticketName: "Elatio By Gards LLP",
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
                          /*   InkWell(
                            onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>NewAccountScreen()));
                          },
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
                          activeColor:
                              radioColors[index] ? Colors.red : Colors.green,
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
                                      MediaQuery.of(context).size.height * 0.44,
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
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const ViewPayment();
                                            }));
                                          },
                                          minVerticalPadding: 0,
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/payment.png"),
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
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/other.png"),
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
                                                  horizontal: 6, vertical: 0),
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
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/invoice.png"),
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

                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class Enquiry extends StatelessWidget {
  const Enquiry({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                                            ticketName:
                                                "Elatio By Gards LLP | SCAFF00344",
                                          )));
                            },
                            child: CircleAvatar(),
                          ),
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
                                                "Elatio By Gards LLP | SCAFF00344",
                                          )));
                            },
                            child: const CustomText(
                              text: "Elatio By Gards LLP | SCAFF00344",
                              size: 16,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Date 5/11/2024",
                        style: TextStyle(fontSize: 20),
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(),
                  ),
                  const SizedBox(
                    height: 12,
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
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 188.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Serviceviewdetail();
                              }));
                            },
                            child: Container(
                              height: 42,
                              width: 10,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black)),
                              child: const Center(
                                child: CustomText(
                                  text: 'View Detail',
                                  align: TextAlign.center,
                                  color: Colors.black,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class BilledService extends StatefulWidget {
  const BilledService({super.key});

  @override
  State<BilledService> createState() => _BilledServiceState();
}

class _BilledServiceState extends State<BilledService> {
  final List<bool> radioColors = [true, false, true, false];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                                            ticketName: "Elatio By Gards LLP",
                                          )));
                            },
                            child: CircleAvatar(),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyProfile(
                                            ticketName: "Elatio By Gards LLP",
                                          )));
                            },
                            child: const CustomText(
                              text: "Elatio By Gards LLP",
                              size: 16,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),

                          /*InkWell(
                            onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>NewAccountScreen()));
                          },
                            child: Container(
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
                          activeColor:
                              radioColors[index] ? Colors.red : Colors.green,
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
                                      MediaQuery.of(context).size.height * 0.76,
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
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const ViewPayment();
                                            }));
                                          },
                                          minVerticalPadding: 0,
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/payment.png"),
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
                                              return const Othercharges(
                                                isSale: true,
                                              );
                                            }));
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/other.png"),
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
                                        /*ListTile(
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
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const Notes();
                                            }));
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/notes.png"),
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
                                        /*ListTile(
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
                                        ),*/
                                        /*ListTile(
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
                                        ),*/
                                        /*ListTile(
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
                                        ),*/
                                        const Divider(),
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
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/invoice.png"),
                                          title: const CustomText(
                                            text: "Ledger Bills",
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
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const TermsSelectionScreen(
                                                editable: true,
                                              );
                                            }));
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/invoice.png"),
                                          title: const CustomText(
                                            text: "Manage Policy",
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
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const Bills();
                                            }));
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Image.asset("images/today.png"),
                                          title: const CustomText(
                                            text: "Create/View/ledger Bill",
                                            color: Color(0xFF00A27B),
                                            weight: FontWeight.w400,
                                            size: 16,
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.black,
                                          ),
                                        ),
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
                                        //           horizontal: 6, vertical: 0),
                                        //   leading: Icon(Icons.print),
                                        //   title: const CustomText(
                                        //     text: "Print Bill",
                                        //     color: Colors.black,
                                        //     weight: FontWeight.w400,
                                        //     size: 16,
                                        //   ),
                                        //   trailing: const Icon(
                                        //     Icons.arrow_forward_ios,
                                        //     color: Colors.black,
                                        //   ),
                                        // ),
                                        ListTile(
                                          onTap: () {
                                            /*Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                                  return const Bills();
                                                }));*/
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading:
                                              Icon(Icons.notifications_active),
                                          title: const CustomText(
                                            text: "Reminder",
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
                                            /*Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                                  return const Bills();
                                                }));*/
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          title: const CustomText(
                                            text:
                                                "You Can Buy From Another Vender",
                                            color: Colors.black,
                                            weight: FontWeight.w400,
                                            size: 16,
                                          ),
                                          trailing: Radio(
                                            value: 1,
                                            groupValue: 1,
                                            onChanged: (v) {},
                                            activeColor: Colors.green,
                                          ),
                                        ),
                                        const Divider(),
                                        // ListTile(
                                        //   onTap: () {
                                        //     /*Navigator.push(context,
                                        //         MaterialPageRoute(builder: (context) {
                                        //           return const Bills();
                                        //         }));*/
                                        //   },
                                        //   minVerticalPadding: 0,
                                        //   contentPadding:
                                        //       const EdgeInsets.symmetric(
                                        //           horizontal: 6, vertical: 0),
                                        //   //   leading: Icon(Icons.notifications_active),
                                        //   title: const CustomText(
                                        //     text: "More Balance Amount on New",
                                        //     color: Colors.black,
                                        //     weight: FontWeight.w400,
                                        //     size: 16,
                                        //   ),
                                        //   trailing: const Icon(
                                        //     Icons.arrow_forward_ios,
                                        //     color: Colors.black,
                                        //   ),
                                        // ),
                                        ListTile(
                                          onTap: () {
                                            /* Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                                  return const Bills();
                                                }));*/
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading: Icon(Icons.lock),
                                          title: const CustomText(
                                            text: "Close Account",
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
                                            /* Navigator.push(context,
                                                MaterialPageRoute(builder: (context) {
                                                  return const Bills();
                                                }));*/
                                          },
                                          minVerticalPadding: 0,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 0),
                                          leading: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          title: const CustomText(
                                            text: "Delete",
                                            color: Colors.red,
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

                  const SizedBox(
                    height: 12,
                  ),
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
                                return NewslipScreen();
                              }));
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CustomText(
                                  text: 'New Slips',
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
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return Serviceslip();
                              }));
                            },
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return BillsPage();
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
                                  text: 'Bills',
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
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class Current extends StatefulWidget {
  const Current({super.key});

  @override
  State<Current> createState() => _CurrentState();
}

class _CurrentState extends State<Current> {
  final List<bool> radioColors = [true, false, true, false];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search by name, Phone Number, GST Number, address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        SizedBox(
          height: 12,
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
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Container(
                      //     height: 44,
                      //     width: double.infinity,
                      //     decoration: BoxDecoration(
                      //       color: ThemeColors.kPrimaryThemeColor,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         const SizedBox(
                      //           width: 10,
                      //         ),
                      //         InkWell(
                      //           onTap: () {
                      //             Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) => MyProfile(
                      //                           ticketName: "Elatio By Gards LLP",
                      //                         )));
                      //           },
                      //           child: CircleAvatar(),
                      //         ),
                      //         const SizedBox(
                      //           width: 10,
                      //         ),
                      //         InkWell(
                      //           onTap: () {
                      //             Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) => MyProfile(
                      //                           ticketName: "Elatio By Gards LLP",
                      //                         )));
                      //           },
                      //           child: const CustomText(
                      //             text: "Elatio By Gards LLP",
                      //             size: 16,
                      //             color: Colors.white,
                      //             weight: FontWeight.w500,
                      //           ),
                      //         ),
                      //         const Spacer(),
                      //         InkWell(
                      //           onTap: () {
                      //             Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                     builder: (context) => NewAccountScreen(
                      //                           accountType: "Sale",
                      //                         )));
                      //           },
                      //           child: Container(
                      //             height: 34,
                      //             decoration: ShapeDecoration(
                      //               color: Colors.white,
                      //               shape: RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.circular(5)),
                      //             ),
                      //             child: const Padding(
                      //               padding: EdgeInsets.symmetric(horizontal: 6),
                      //               child: Center(child: Icon(Icons.add)),
                      //             ),
                      //           ),
                      //         ),
                      //         const SizedBox(
                      //           width: 8,
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // // const SizedBox(
                      // //   height: 10,
                      // // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10),
                      //   child: Row(
                      //     children: [
                      //       const SizedBox(
                      //         width: 260,
                      //         child: CustomText(
                      //           text:
                      //               'Building: Plot no. SC 01 Sector AdJoining Tech Zone....',
                      //           color: Colors.black,
                      //           size: 13,
                      //           weight: FontWeight.w400,
                      //           height: 0,
                      //         ),
                      //       ),
                      //       const Spacer(),
                      //       Radio(
                      //         value: 1,
                      //         groupValue: 1,
                      //         onChanged: (v) {},
                      //         activeColor:
                      //             radioColors[index] ? Colors.red : Colors.green,
                      //       ),
                      //
                      //     ],
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyProfile(
                                              ticketName: index == 2
                                                  ? "Sudhir Kumar | B-UP-004380"
                                                  : "Akhilesh Kumar | B-UP-004379",
                                            )));
                              },
                              child: Container(
                                height: 80,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade300,
                                ),
                                child: Icon(Icons.person,
                                    size: 40, color: Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(
                                        text: "Elatio By Gards LLP",
                                        size: 15,
                                        color: Colors.black,
                                        weight: FontWeight.w500,
                                      ),
                                      Spacer(),
                                      Radio(
                                        value: 1,
                                        groupValue: 1,
                                        onChanged: (v) {},
                                        activeColor: radioColors[index]
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  CustomText(
                                    text:
                                        'Building: Plot no. SC 01 Sector AdJoining Tech Zone,  Noida Extension, Greater Noida, Uttar Pradesh',
                                    color: Colors.black,
                                    size: 12,
                                    weight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                            if (index != 1)
                              Column(
                                children: [
                                  IconButton(
                                    icon: Image.asset('images/whatsapp.png',
                                        color: Color(0xff25D366)),
                                    onPressed: () {},
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.call,
                                        color: ThemeColors.kPrimaryThemeColor,
                                        size: 20),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewAccountScreen(
                                            accountType: "Sale")));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: ThemeColors.kPrimaryThemeColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            const Expanded(
                              child: CustomText(
                                text:
                                    'Ship To: Plot no. SC 01 Sector AdJoining Tech Zone  Noida Extension, Greater Noida, Uttar Pradesh',
                                color: Colors.black,
                                size: 12,
                                weight: FontWeight.w400,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // _showBottomSheet(context);
                              },
                              child: const Icon(Icons.more_vert, size: 20),
                            )
                          ],
                        ),
                      ),
                      const Divider(height: 8, thickness: 0.5),
                      if (index != 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: const [
                              CustomText(text: "B-UP-00467", size: 13),
                              Spacer(),
                              CustomText(
                                text: "Due amount - 971200",
                                size: 13,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return NewslipScreen();
                                  }));
                                },
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: CustomText(
                                      text: 'New Slips',
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
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return Serviceslip();
                                  }));
                                },
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return const ServiceBillsScreen();
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
                                      text: 'Bills',
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
                      ),
                    ],
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class Quotations extends StatelessWidget {
  final VoidCallback? onShiftToCurrent;

  const Quotations({super.key, this.onShiftToCurrent});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                                            ticketName:
                                                "Elatio By Gards LLP | SCAFF00344",
                                          )));
                            },
                            child: CircleAvatar(),
                          ),
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
                                                "Elatio By Gards LLP | SCAFF00344",
                                          )));
                            },
                            child: const CustomText(
                              text: "Elatio By Gards LLP | SCAFF00344",
                              size: 16,
                              color: Colors.white,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: const [
                          Text(
                            "Date 5/11/2024",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            width: 80,
                          ),
                          Text(
                            "Status: ",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(),
                  ),
                  const SizedBox(
                    height: 12,
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
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: InkWell(
                            onTap: () async {
                              final phone = await AppService().getPhoneNumber();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ViewDetail1(
                                  phone: phone ?? "",
                                );
                              }));
                            },
                            child: Container(
                              height: 42,
                              width: 10,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black)),
                              child: const Center(
                                child: CustomText(
                                  text: 'View Detail',
                                  align: TextAlign.center,
                                  color: Colors.black,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: onShiftToCurrent,
                          child: Container(
                            height: 42,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black)),
                            child: const Center(
                              child: CustomText(
                                text: 'Shift to Current',
                                align: TextAlign.center,
                                color: Colors.black,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
