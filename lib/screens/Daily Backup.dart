import 'package:flutter/material.dart';
import 'package:scaffolding_sale/widgets/text.dart';

class DailyBackups extends StatefulWidget {
  DailyBackups({
    Key? key,
  }) : super(key: key);

  @override
  _DailyBackupsState createState() => _DailyBackupsState();
}

class _DailyBackupsState extends State<DailyBackups> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            "Daily Backups",
            style: TextStyle(color: Colors.white),
          ),
          leading:
              IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: CustomText(
              text: "Please enter your email to start receiving daily backups.",
              size: 21,
              weight: FontWeight.w300,
              align: TextAlign.center,
            ),
          ),
        )
        // ListView.separated(
        //   itemCount: 0,
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       title: Row(
        //         children: [
        //           Text(
        //             '27-03-2024',
        //             style: TextStyle(
        //                 color: Colors.black,
        //                 fontWeight: FontWeight.w400,
        //                 fontSize: 18),
        //           ),
        //           SizedBox(
        //             width: 8,
        //           ),
        //           Text(
        //             '12:36 am',
        //             style: TextStyle(
        //                 color: Colors.black,
        //                 fontWeight: FontWeight.w400,
        //                 fontSize: 18),
        //           ),
        //         ],
        //       ),
        //       subtitle: Text(
        //         'Size: 3084 kb  Accounts: 46',
        //         style: TextStyle(
        //           color: Colors.grey,
        //         ),
        //       ),
        //       trailing: ElevatedButton(
        //         onPressed: () {
        //           // Handle opening stock
        //         },
        //         style: ElevatedButton.styleFrom(
        //           shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(10)),
        //           backgroundColor: Colors.teal,
        //           padding: EdgeInsets.symmetric(horizontal: 20),
        //         ),
        //         child: Text('Pass', style: TextStyle(color: Colors.white)),
        //       ),
        //     );
        //   },
        //   separatorBuilder: (context, index) {
        //     return Divider(
        //       thickness: 1, // Adjust thickness as needed
        //       color: Colors.grey, // Adjust color as needed
        //     );
        //   },
        // ),
        );
  }
}
