import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/view%20detail.dart';

import '../../../utils/colors.dart';
import '../../../widgets/text.dart';
import '../../../widgets/textfield.dart';
import '../../profile/MyProfile.dart';
import 'ViewCoutomerdetail.dart';

class CoustomerDetail extends StatefulWidget {
  const CoustomerDetail({super.key});

  @override
  State<CoustomerDetail> createState() => _CoustomerDetailState();
}

class _CoustomerDetailState extends State<CoustomerDetail> {
  final List<bool> radioColors = [true, false, true, false, true, false, true];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Customer History',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              RegisterField(
                hint: "Search Bills, Name",
                controller: TextEditingController(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
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
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                                            ),
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
                                            builder: (context) => MyProfile(
                                              ticketName: "Tarun| SCAFF00328",
                                            ),
                                          ),
                                        );
                                      },
                                      child: const CustomText(
                                        text: "Tarun| SCAFF00328",
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Date 5/11/2024",
                                    style: TextStyle(fontSize: 20),
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
                                    padding:
                                        const EdgeInsets.only(right: 188.0),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Viewdetail(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 42,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border:
                                              Border.all(color: Colors.black),
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
                              ],
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
