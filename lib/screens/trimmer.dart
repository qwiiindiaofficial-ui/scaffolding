// import 'package:flutter/material.dart';
// import 'package:video_trimmer/video_trimmer.dart';

// class TrimmerView extends StatefulWidget {
//   final Trimmer trimmer;
//   TrimmerView({required this.trimmer});

//   @override
//   _TrimmerViewState createState() => _TrimmerViewState();
// }

// class _TrimmerViewState extends State<TrimmerView> {
//   double _startValue = 0.0;
//   double _endValue = 30.0; // Max 30 seconds

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Trim Video")),
//       body: Column(
//         children: [
//           Expanded(
//             child: VideoViewer(trimmer: widget.trimmer),
//           ),
//           TrimViewer(
//             trimmer: widget.trimmer,
//             maxVideoLength: Duration(seconds: 30),
//             onChangeStart: (value) => setState(() => _startValue = value),
//             onChangeEnd: (value) => setState(() => _endValue = value),
//             onChangePlaybackState: (value) {},
//           ),
//           ElevatedButton(
//             child: Text("Save"),
//             onPressed: () {
//               Navigator.of(context).pop(_endValue);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
