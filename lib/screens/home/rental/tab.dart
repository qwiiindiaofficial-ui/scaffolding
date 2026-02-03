import 'package:flutter/material.dart';

class TabItem extends StatelessWidget {
  final String text;

  const TabItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8.0), // Padding between each tab
      child: Tab(
        text: text,
      ),
    );
  }
}
