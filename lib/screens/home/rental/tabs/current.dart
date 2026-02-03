import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaffolding_sale/screens/ReminderSetting.dart';
import 'package:scaffolding_sale/screens/home/Rate.dart';
import 'package:scaffolding_sale/screens/home/Union/stocksummary.dart';
import 'package:scaffolding_sale/screens/home/new%20account.dart';
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
import 'package:scaffolding_sale/screens/home/rental/select_terms.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/Inward.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/NewSlip.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/outward.dart';
import 'package:scaffolding_sale/screens/home/rental/slip/slip.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';

import '../../../profile/MyProfile.dart';

class Current extends StatefulWidget {
  const Current({super.key});

  @override
  State<Current> createState() => _CurrentState();
}

class _CurrentState extends State<Current> {
  final List<bool> radioColors = [true, false, true, false];
  void showFieldSelectionDialog(BuildContext context) {
    DateTime? fromDate;
    DateTime? toDate;
    int? numberOfDays;

    // 💥 NEW: State variable for GST inclusion
    bool _includeGst = true; // Default: Include GST

    final chargesController = TextEditingController();
    final penaltyChargesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Fields'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 💥 NEW: GST Checkbox Row (Placed just below the title area)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Include GST?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Text for 'Without GST'

                              Checkbox(
                                value: _includeGst, // Checked when INCLUDE GST
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _includeGst = newValue ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // From Date (Unchanged)
                    ListTile(
                      title: const Text('From Date'),
                      subtitle: Text(fromDate != null
                          ? fromDate.toString().substring(0, 10)
                          : 'Select a date'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            fromDate = selectedDate;

                            // Recalculate days if both dates are selected
                            if (fromDate != null && toDate != null) {
                              numberOfDays =
                                  toDate!.difference(fromDate!).inDays + 1;
                            }
                          });
                        }
                      },
                    ),
                    const Divider(),
                    // To Date (Unchanged)
                    ListTile(
                      title: const Text('To Date'),
                      subtitle: Text(toDate != null
                          ? toDate.toString().substring(0, 10)
                          : 'Select a date'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            toDate = selectedDate;

                            // Recalculate days if both dates are selected
                            if (fromDate != null && toDate != null) {
                              numberOfDays =
                                  toDate!.difference(fromDate!).inDays + 1;
                            }
                          });
                        }
                      },
                    ),
                    const Divider(),
                    // Number of Days (Unchanged)
                    if (numberOfDays != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Number of Days: $numberOfDays',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // Charges (Unchanged)
                    TextFormField(
                      controller: chargesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fix Charges',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Penalty Charges (Unchanged)
                    TextFormField(
                      controller: penaltyChargesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Penalty Charges Per Day',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 💥 NOTE: Access the selected GST state here:
                  // bool finalIncludeGst = _includeGst;
                  // String finalCharges = chargesController.text;
                  // ... and pass them to your main function

                  Navigator.of(context).pop();
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }

  List<bool> openTile = [false, false];
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
            itemCount: 2, //todo rampal
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
                      index == 0
                          ? const SizedBox(
                              height: 10,
                            )
                          : Container(),
                      index == 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: months.map((month) {
                                  return Container(
                                    // margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: getBackgroundColor(month),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      month,
                                      style: TextStyle(
                                        color: getBackgroundColor(month) ==
                                                Colors.yellow
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Container(),

                      index == 0
                          ? const SizedBox(
                              height: 10,
                            )
                          : Container(),
                      index == 1
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                // height: 140,
                                // padding: const EdgeInsets.symmetric(vertical: 16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  // color: ThemeCo,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 0),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => MyProfile(
                                                            ticketName: index ==
                                                                    2
                                                                ? "Sudhir Kumar | B-UP-004380"
                                                                : "Akhilesh Kumar | B-UP-004379")));
                                              },
                                              child: Container(
                                                height: 120,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: Colors.grey.shade300,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.person,
                                                      size: 52,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Image.network(
                                            'https://img.icons8.com/color/48/whatsapp--v1.png',
                                            // height: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // The text will take up the available space on the left
                                              Container(
                                                color: Colors.white,
                                                width: 220,
                                                child: const CustomText(
                                                  text: "Elatio By Gards LLP",
                                                  size: 16,
                                                  color: Colors.black,
                                                  weight: FontWeight.w500,
                                                ),
                                              ),

                                              // This Row will group your icons together on the right
                                              Row(
                                                children: [
                                                  // SizedBox(
                                                  //   width: 70,
                                                  // ),
                                                  // Spacer(),
                                                  // Phone Icon

                                                  // Your original Edit/Note Icon
                                                  const Icon(
                                                    Icons.note_alt,
                                                    color: Colors.black54,
                                                    size: 24,
                                                  ),
                                                  Image.network(
                                                    "https://img.icons8.com/arcade/64/phone-disconnected.png",
                                                    height: 40,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 280,
                                            child: CustomText(
                                              text:
                                                  "B 240 GRD FLOOR B NOIDA SECTOR 50 NOIDA, Uttar Pradesh, India - 201301",
                                              color: Colors.black,
                                              size: 14,
                                              fontFamily: 'Inter',
                                              weight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              CustomText(
                                                color: Colors.black,
                                                size: 13,
                                                fontFamily:
                                                    GoogleFonts.poppins()
                                                        .fontFamily,
                                                weight: FontWeight.bold,
                                                text: "B-UP-004380",
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return const TotalStockSummaryScreen();
                                                    }));
                                                  },
                                                  icon: Icon(
                                                    Icons.info,
                                                    color: ThemeColors
                                                        .kPrimaryThemeColor,
                                                  )),
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
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              NewAccountScreen(
                                                                accountType:
                                                                    "Rent",
                                                              )));
                                                },
                                                child: Container(
                                                  // height: 48,
                                                  // width: 80,
                                                  decoration: ShapeDecoration(
                                                    color: ThemeColors
                                                        .kPrimaryThemeColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 8),
                                                    child: Center(
                                                        child: Row(
                                                      children: [
                                                        CustomText(
                                                          text: "New Site",
                                                          color: Colors.white,
                                                        ),
                                                        Icon(
                                                          Icons.add,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ],
                                                    )),
                                                  ),
                                                ),
                                              ),
                                              // const SizedBox(
                                              //   width: 8,
                                              // ),
                                            ],
                                          )
                                        ],
                                      ),
                                      // Spacer(),
                                      // Radio(
                                      //   value: 1,
                                      //   groupValue: 1,
                                      //   onChanged: (v) {},
                                      //   activeColor: radioColors[index]
                                      //       ? Colors.red
                                      //       : Colors.green,
                                      // ),
                                      // InkWell(
                                      //   onTap: () {
                                      //     Navigator.push(
                                      //         context,
                                      //         MaterialPageRoute(
                                      //             builder: (context) =>
                                      //                 NewAccountScreen()));
                                      //   },
                                      //   child: Container(
                                      //     height: 28,
                                      //     decoration: ShapeDecoration(
                                      //       color: Colors.white,
                                      //       shape: RoundedRectangleBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(5)),
                                      //     ),
                                      //     child: const Padding(
                                      //       padding:
                                      //           EdgeInsets.symmetric(horizontal: 6),
                                      //       child: Center(child: Icon(Icons.add)),
                                      //     ),
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   width: 8,
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  openTile[index] = !openTile[index];
                                  setState(() {});
                                },
                                child: SizedBox(
                                  width: 350,
                                  child: CustomText(
                                    text: index == 0
                                        ? "B 240 GRD FLOOR B NOIDA SECTOR 50 NOIDA, Uttar Pradesh, India - 201301"
                                        : "KH NO. 59, BAGU GALI NO. 5, KRISHNA NAGAR, RAGHUNATH PURI, Ghaziabad, Uttar Pradesh, 201001",
                                    color: Colors.black,
                                    size: 14,
                                    fontFamily: 'Inter',
                                    weight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ),
                              const Spacer(),
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
                                                0.9,
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
                                              // Row(
                                              //   children: [
                                              //     const CustomText(
                                              //       text: "AC No: 12 (43786283932)",
                                              //       size: 18,
                                              //     ),
                                              //     const Spacer(),
                                              //     InkWell(
                                              //       onTap: () {
                                              //         Navigator.pop(context);
                                              //       },
                                              //       child: const Icon(
                                              //         Icons.close,
                                              //         color: Colors.black,
                                              //       ),
                                              //     )
                                              //   ],
                                              // ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              const SizedBox(
                                                width: 298,
                                                child: CustomText(
                                                  text:
                                                      "KH NO. 59, BAGU GALI NO. 5, KRISHNA NAGAR, RAGHUNATH PURI, Ghaziabad, Uttar Pradesh, 201001",
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
                                              ListTile(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const LostItems();
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.asset(
                                                    "images/lost.png"),
                                                title: CustomText(
                                                  text:
                                                      "Short or Repairing charges",
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
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const Othercharges(
                                                      isSale: false,
                                                    );
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
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const Transport();
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.asset(
                                                    "images/transport.png"),
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
                                                    "images/notes.png"),
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
                                              ListTile(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const TermsSelectionScreen(
                                                      editable: false,
                                                    );
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.asset(
                                                    "images/notes.png"),
                                                title: const CustomText(
                                                  text: "Terms & Conditions",
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
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.asset(
                                                    "images/edit.png"),
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
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const Rate();
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.asset(
                                                    "images/rate.png"),
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
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const OnedayDiscount();
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.asset(
                                                    "images/percent.png"),
                                                title: const CustomText(
                                                  text:
                                                      "One Day Discount Setting",
                                                  color: Colors.black,
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
                                              //   leading:
                                              //       Image.asset("images/today.png"),
                                              //   title: const CustomText(
                                              //     text: "View Bill Till Today",
                                              //     color: Color(0xFF00A27B),
                                              //     weight: FontWeight.w400,
                                              //     size: 16,
                                              //   ),
                                              //   trailing: const Icon(
                                              //     Icons.arrow_forward_ios,
                                              //     color: Colors.black,
                                              //   ),
                                              // ),
                                              const Divider(),
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
                                              //   leading: Image.asset(
                                              //       "images/invoice.png"),
                                              //   title: const CustomText(
                                              //     text: "View Bill Till a date",
                                              //     color: Colors.black,
                                              //     weight: FontWeight.w400,
                                              //     size: 16,
                                              //   ),
                                              //   trailing: const Icon(
                                              //     Icons.arrow_forward_ios,
                                              //     color: Colors.black,
                                              //   ),
                                              // ),
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
                                              //   leading: Image.asset(
                                              //       "images/invoice.png"),
                                              //   title: const CustomText(
                                              //     text: "Performa Invoice",
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
                                                    "images/today.png"),
                                                title: const CustomText(
                                                  text:
                                                      "Create/View/ledger Bill",
                                                  color: Color(0xFF00A27B),
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
                                                  showFieldSelectionDialog(
                                                      context);
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: const Icon(
                                                    Icons.price_check),
                                                title: const CustomText(
                                                  text: "Fix Rate",
                                                  color: Colors.black,
                                                  weight: FontWeight.w400,
                                                  size: 16,
                                                ),
                                              ),
                                              ListTile(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const ReminderSetting();
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: const Icon(
                                                    Icons.notifications_active),
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
                                                leading:
                                                    const Icon(Icons.group),
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
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
                                              ListTile(
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return const NewslipScreen();
                                                  }));
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: Image.network(
                                                  "https://www.shutterstock.com/image-vector/two-workers-build-single-layer-260nw-2407853049.jpg",
                                                ),
                                                title: const CustomText(
                                                  text: "Service Slip",
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
                                                  /* Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) {
                                                      return const Bills();
                                                    }));*/
                                                },
                                                minVerticalPadding: 0,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: const Icon(Icons.lock),
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
                                                        horizontal: 6,
                                                        vertical: 0),
                                                leading: const Icon(
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
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: Colors.black,
                                  )),
                              const SizedBox(
                                width: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 10),
                      //   child: Divider(),
                      // ),
                      // Wrap your existing code in this Container
                      openTile[index]
                          ? Container(
                              // Margin outside the highlighted box
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                              // Padding inside the highlighted box, between the content and the border
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey.shade200, // A subtle background color
                                borderRadius: BorderRadius.circular(
                                    8.0), // Rounded corners
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomText(
                                    text: "Due Amount - +1400",
                                    color: Colors.green,
                                  ),
                                  // Spacer(),
                                  // CustomText(
                                  //   text: "Pcs - 550",
                                  //   color: Colors.red,
                                  // ),
                                ],
                              ),
                              //  const Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     CustomText(
                              //       text: 'Due: 0',
                              //       color: Color(0xFFCA1313),
                              //       size: 13,
                              //       weight: FontWeight.bold,
                              //       height: 0,
                              //     ),
                              //     CustomText(
                              //       text: '0 pcs',
                              //       color: Color(0xff077D07),
                              //       size: 13,
                              //       weight: FontWeight.bold,
                              //       height: 0,
                              //     ),
                              //     CustomText(
                              //       text: '0 Kg',
                              //       color: Colors.black,
                              //       size: 13,
                              //       weight: FontWeight.bold,
                              //       height: 0,
                              //     ),
                              //   ],
                              // ),
                            )
                          : Container(),
                      openTile[index]
                          ? Row(
                              children: [
                                Container(
                                  width: 120,
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
                                      text: 'Item & Square Ft',
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
                                CustomText(
                                  text: 'AC No: 03',
                                  color: Colors.black,
                                  size: 13,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  weight: FontWeight.bold,
                                  height: 0,
                                ),
                                const Spacer(),
                                // IconButton.outlined(
                                //   onPressed: () {},
                                //   color: ThemeColors.kPrimaryThemeColor,
                                //   icon: Icon(Icons.location_on_outlined),
                                //   style: OutlinedButton.styleFrom(
                                //     // Optional: customize the look
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 6, vertical: 6),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(12),
                                //     ),
                                //   ),
                                // ),
                                const Icon(Icons.note_alt_rounded),
                                IconButton.outlined(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const ImageGalleryDialog(
                                          imagePaths: [
                                            "images/name.png",
                                            "images/stamp.jpeg",
                                            "images/file.png"
                                          ],
                                          initialIndex: 0,
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.image,
                                    color: ThemeColors.kPrimaryThemeColor,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    // Optional: customize the look
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 12,
                      ),
                      openTile[index]
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const OutwardScreen();
                                        }));
                                      },
                                      child: Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFF4242),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: CustomText(
                                            text: 'Outward',
                                            align: TextAlign.center,
                                            color: Colors.white,
                                            size: 18,
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
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return const OutwardScreen(
                                              // isInward: true,
                                              );
                                        }));
                                      },
                                      child: Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xff077D07),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: CustomText(
                                            text: 'Inward',
                                            align: TextAlign.center,
                                            color: Colors.white,
                                            size: 18,
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
                                          color: Colors.yellow,
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: CustomText(
                                            text: 'Voucher',
                                            align: TextAlign.center,
                                            color: Colors.black,
                                            size: 18,
                                            weight: FontWeight.w500,
                                            height: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            }),
      ],
    );
  }

  final List<String> months = [
    "J",
    "F",
    "M",
    "A",
    "M",
    "J",
    "J",
    "A",
    "S",
    "O",
    "N",
    "D"
  ];
  Color getBackgroundColor(String initial) {
    if (["J", "A", "O", "D"].contains(initial)) {
      return Colors.red;
    } else if (["S", "N"].contains(initial)) {
      return Colors.green;
    } else {
      return Colors.yellow;
    }
  }
}

class ImageGalleryDialog extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageGalleryDialog({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<ImageGalleryDialog> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The PageView for swiping between images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.asset(
                  widget.imagePaths[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          // Left navigation arrow
          Positioned(
            left: 10,
            child: IconButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icon(Icons.arrow_back_ios,
                  color: ThemeColors.kPrimaryThemeColor),
              iconSize: 30,
            ),
          ),
          // Right navigation arrow
          Positioned(
            right: 10,
            child: IconButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icon(Icons.arrow_forward_ios,
                  color: ThemeColors.kPrimaryThemeColor),
              iconSize: 30,
            ),
          ),
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
          // Page indicators (dots)
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imagePaths.length, (index) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? ThemeColors.kPrimaryThemeColor
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
