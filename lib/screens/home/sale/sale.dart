import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scaffolding_sale/backend/methods.dart';
import 'package:scaffolding_sale/screens/All%20Bills.dart';
import 'package:scaffolding_sale/screens/ReminderSetting.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/home/Manage%20Policy.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/bill/bills.dart'
    hide Bill;
import 'package:scaffolding_sale/screens/home/rental/menu/bill/edit_bill.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/notes.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/othercharges.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/screens/home/rental/select_terms.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/allbill.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip.dart';
import 'package:scaffolding_sale/screens/home/sale/detail.dart';
import 'package:scaffolding_sale/screens/home/sale/salebills.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import '../../profile/MyProfile.dart';
import '../new account.dart';
import '../rental/tab.dart';
import '../rental/tabs/all.dart';
import 'Bills.dart';
import 'Gatepass.dart';

class Sale extends StatefulWidget {
  const Sale({super.key});

  @override
  _SaleState createState() => _SaleState();
}

class _SaleState extends State<Sale> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
          text: "Sale",
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
                            accountType: '',
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
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 7,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                TabBar(
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.all(0),
                  isScrollable: true,
                  controller: _tabController,
                  labelPadding: EdgeInsets.zero,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: ThemeColors.kSecondaryThemeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    TabItem(text: "Enquiry"),
                    TabItem(text: "Quotation"),
                    TabItem(text: "Current"),
                    TabItem(text: "Bills"),
                    TabItem(text: "Payment Due"),
                    TabItem(text: "Closed"),
                    TabItem(text: "All"),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      const Enquiry(),
                      Quotations(onShiftToCurrent: _switchToCurrentTab),
                      const Current(),
                      const Billed(),
                      const Payment(),
                      const Closed(),
                      const All(),
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
                                            ticketName: "Tarun | SCAFF00328",
                                          )));
                            },
                            child: const CircleAvatar(),
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
                                            ticketName: "Tarun | SCAFF00328",
                                          )));
                            },
                            child: const CustomText(
                              text: "Tarun | SCAFF00328",
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
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
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
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 188.0),
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
          padding: EdgeInsets.zero,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index != 1)
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
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        NewAccountScreen(accountType: "Sale")));
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
                        // InkWell(
                        //   onTap: () {
                        //     _showBottomSheet(context);
                        //   },
                        //   child: const Icon(Icons.more_vert, size: 20),
                        // )
                      ],
                    ),
                  ),
                  const Divider(height: 8, thickness: 0.5),
                  if (index != 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          const CustomText(text: "B-UP-00467", size: 13),
                          const Spacer(),
                        ],
                      ),
                    ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        _smallButton(
                          label: 'Gate Pass',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GatePass())),
                        ),
                        const SizedBox(width: 8),
                        _smallButton(
                          label: 'Preview Gate Pass',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const PreviewGatePass())),
                        ),
                        const SizedBox(width: 8),
                        _smallButton(
                          label: 'All Bills',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      InvoiceManagementScreen())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _smallButton({required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomText(
              text: label,
              align: TextAlign.center,
              color: Colors.black,
              size: 12,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text("Bottom Sheet Content..."), // keep your original content
        ),
      ),
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
                                      builder: (context) => MyProfile(
                                            ticketName: "Tarun| SCAFF00328",
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
                                          ticketName: "Tarun| SCAFF00328",
                                        )));
                          },
                          child: const CustomText(
                            text: "ALPHABET HEIGHT| User ID",
                            size: 16,
                            color: Colors.white,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(
                        "Date 7/6/2024",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 80),
                      Text(
                        "Status: ",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(),
                ),
                const SizedBox(height: 12),
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
                              border: Border.all(color: Colors.black),
                            ),
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
                            border: Border.all(color: Colors.black),
                          ),
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Billed extends StatefulWidget {
  final VoidCallback? onShiftToCurrent;

  const Billed({super.key, this.onShiftToCurrent});

  @override
  State<Billed> createState() => _BilledState();
}

class _BilledState extends State<Billed> {
  @override
  Widget build(BuildContext context) {
    String _selectedFilter = 'All Bills';
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'All Bills',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
                const Text("All Bills"),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'Registered',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
                const Text("Registered"),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  activeColor: Colors.green,
                  focusColor: Colors.green,
                  value: 'Unregistered',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
                const Text("Unregistered"),
              ],
            ),
          ],
        ),
        // SizedBox(
        //   height: 120,
        // ),
        // CustomText(
        //   text: "No Data Yet",
        // ),
        Expanded(
          child: ListView.builder(
            itemCount: 4, // Replace with actual bill data
            itemBuilder: (context, index) {
              return BillItem(
                bill: Bill(
                  billNumber: "143",
                  billType: 'Sale',
                  billValue: 7080,
                  igst: 880,
                  billDate: "3 Dec 23 to 21 Dec 23",
                  billProvider: "SATYAM \nPOWER ELECTRICAL",
                  cgst: 880,
                  sgst: 800,
                  taxableAmount: 7080,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
