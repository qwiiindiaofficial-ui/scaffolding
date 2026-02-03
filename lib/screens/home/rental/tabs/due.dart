import 'package:flutter/material.dart';
import 'package:scaffolding_sale/widgets/rental_card.dart';

class Due extends StatelessWidget {
  const Due({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 4,
        itemBuilder: (context, index) {
          return const RentalCard(
            short: true,
          );
        });
  }
}
