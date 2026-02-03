// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:scaffolding_sale/screens/home/rental/delivery.dart';
// import 'package:scaffolding_sale/screens/home/rental/slip/outward.dart';

// import '../utils/colors.dart';

// class DailyEntries extends StatefulWidget {
//   const DailyEntries({super.key});

//   @override
//   _DailyEntriesState createState() => _DailyEntriesState();
// }

// class _DailyEntriesState extends State<DailyEntries>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         title: const Text(
//           'Daily Entries',
//           style: TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 // Handle opening stock
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 backgroundColor: ThemeColors.kSecondaryThemeColor,
//                 padding: EdgeInsets.symmetric(horizontal: 20),
//               ),
//               child: Text('25 Dec 2024', style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search bar and buttons in a row
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Search...",
//                       prefixIcon: Icon(Icons.search),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 IconButton(
//                   icon: const Icon(Icons.picture_as_pdf),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.print),
//                   onPressed: () {
//                     Fluttertoast.showToast(msg: "No Printer Found");
//                   },
//                 ),
//                 PopupMenuButton(
//                   icon: const Icon(Icons.more_vert),
//                   itemBuilder: (context) => const [
//                     PopupMenuItem(
//                       child: Text("Delivery Items"),
//                     ),
//                     PopupMenuItem(
//                       child: Text("Receive Items"),
//                     ),
//                     PopupMenuItem(
//                       child: Text("Submit Balance Item"),
//                     ),
//                     PopupMenuItem(
//                       child: Text("View all notes"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           const Divider(),

//           // Address and Other Information
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'MH Shuttering & Scaffolding.\nKHATA NO-199\nGRAM SARFABAD, SECTOR 73\nNoida GAUTAM BUDH NAGAR,\nUTTAR PRADESH- 201307',
//                     style: const TextStyle(
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.left,
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Rate: ₹ 0.01 Per Sqft, Balance Area: FT²',
//                     style: TextStyle(color: Colors.grey),
//                     textAlign: TextAlign.left,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const Divider(),

//           // List of Items
//           Expanded(
//             child: ListView.builder(
//               itemCount: 3,
//               itemBuilder: (context, index) {
//                 return SlipCard();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SlipCard extends StatelessWidget {
//   const SlipCard({super.key});

//   void _onPopupMenuSelected(BuildContext context, String value) {
//     switch (value) {
//       case 'Delete':
//         /*Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return const delete();
//             },
//           ),
//         );*/
//         break;
//       case 'Cancel':
//         /* Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return const cancel();
//             },
//           ),
//         );*/
//         break;
//       case 'Outward challan':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return Delivery();
//             },
//           ),
//         );
//         break;
//       case 'Inward challan':
//         Navigator.pushNamed(context, '/inward-challan');
//         break;
//       case 'E-way/ vehicle/ Edit date No':
//         Navigator.pushNamed(context, '/eway-vehicle');
//         break;
//       case 'Add Note':
//         Navigator.pushNamed(context, '/add-note');
//         break;
//       case 'View slip notes':
//         Navigator.pushNamed(context, '/view-slip-notes');
//         break;
//       case 'Site Pic':
//         Navigator.pushNamed(context, '/site-pic');
//         break;
//       case 'Site current location':
//         Navigator.pushNamed(context, '/site-current-location');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 290,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.black),
//           borderRadius: BorderRadius.circular(13),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 58,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.teal,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(10.0),
//                       child: Text(
//                         '22 Dec 2023 1:09\nCHL No: 246 ₹70',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon:
//                           const Icon(Icons.picture_as_pdf, color: Colors.white),
//                       onPressed: () {},
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.print, color: Colors.white),
//                       onPressed: () {},
//                     ),
//                     PopupMenuButton<String>(
//                       icon: const Icon(Icons.more_vert, color: Colors.red),
//                       onSelected: (value) =>
//                           _onPopupMenuSelected(context, value),
//                       itemBuilder: (context) => const [
//                         PopupMenuItem(
//                             value: 'Delete',
//                             child: Text("Delete",
//                                 style: TextStyle(color: Colors.red))),
//                         PopupMenuItem(value: 'Cancel', child: Text("Cancel")),
//                         PopupMenuItem(
//                             value: 'Outward challan',
//                             child: Text("Outward challan")),
//                         PopupMenuItem(
//                             value: 'Inward challan',
//                             child: Text("Inward challan")),
//                         PopupMenuItem(
//                             value: 'E-way/ vehicle/ Edit date No',
//                             child: Text("E-way/ vehicle/ Edit date No")),
//                         PopupMenuItem(
//                             value: 'Add Note', child: Text("Add Note")),
//                         PopupMenuItem(
//                             value: 'View slip notes',
//                             child: Text("View slip notes")),
//                         PopupMenuItem(
//                             value: 'Site Pic', child: Text("Upload Site Pic")),
//                         PopupMenuItem(
//                             value: 'Site current location',
//                             child: Text("Site current location")),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(),
//               SlipDetailRow(
//                 title: 'Prop Jack 2×2Mt',
//                 value: '₹ 0',
//                 issueCount: '70 Issu.',
//                 iconColor: Colors.red,
//               ),
//               const Divider(),
//               SlipDetailRow(
//                 title: 'Total Prop Jack',
//                 value: '₹ 0',
//                 issueCount: '70 Issu.',
//                 iconColor: Colors.red,
//               ),
//               const Divider(),
//               SlipDetailRow(
//                 title: 'Total PCS',
//                 value: '₹ 0',
//                 issueCount: '70 Issu.',
//                 iconColor: Colors.red,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SlipDetailRow extends StatelessWidget {
//   final String title;
//   final String value;
//   final String issueCount;
//   final Color iconColor;

//   const SlipDetailRow({
//     required this.title,
//     required this.value,
//     required this.issueCount,
//     required this.iconColor,
//     super.key,
//   });

//   void _onPopupMenuSelected(BuildContext context, String value) {
//     switch (value) {
//       case 'Edit':
//         Navigator.pushNamed(context, '/edit');
//         break;
//       case 'Move to other challan':
//         Navigator.pushNamed(context, '/move-challan');
//         break;
//       case 'Delete':
//         Navigator.pushNamed(context, '/delete');
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(Icons.circle, color: iconColor, size: 12),
//           const SizedBox(width: 8.0),
//           Expanded(
//             child: Text(title),
//           ),
//           const SizedBox(width: 12),
//           Text(value),
//           const SizedBox(width: 78.0),
//           Text(issueCount),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.green),
//             onSelected: (value) => _onPopupMenuSelected(context, value),
//             itemBuilder: (context) => const [
//               PopupMenuItem(value: 'Edit', child: Text("Edit")),
//               PopupMenuItem(
//                   value: 'Move to other challan',
//                   child: Text("Move to other challan")),
//               PopupMenuItem(
//                   value: 'Delete',
//                   child: Text("Delete", style: TextStyle(color: Colors.red))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
