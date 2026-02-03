import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/rental/tabs/cards/enquirycard.dart';

class Enquiry extends StatelessWidget {
  const Enquiry({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Enquirycard(
            isSecond: index == 1,
          );
        });
  }
}
