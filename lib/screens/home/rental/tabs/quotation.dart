import 'package:flutter/material.dart';
import 'cards/quotationcard.dart';

class Quotation extends StatelessWidget {
  final VoidCallback? onShiftToCurrent; // Add this parameter

  const Quotation({
    super.key,
    this.onShiftToCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2, // Replace with your dynamic count
      itemBuilder: (context, index) {
        return Quotationcard(
          onShiftToCurrent: onShiftToCurrent,
          isSecond: index == 1,
        );
      },
    );
  }
}
