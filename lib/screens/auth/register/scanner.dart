// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class AadhaarQrScannerScreen extends StatefulWidget {
//   const AadhaarQrScannerScreen({super.key});

//   @override
//   State<AadhaarQrScannerScreen> createState() => _AadhaarQrScannerScreenState();
// }

// class _AadhaarQrScannerScreenState extends State<AadhaarQrScannerScreen> {
//   final MobileScannerController _scannerController = MobileScannerController(
//     detectionSpeed: DetectionSpeed.normal,
//     facing: CameraFacing.back,
//   );
//   bool _isFlashOn = false;
//   bool _isProcessing = false;

//   void _onDetect(BarcodeCapture capture) {
//     if (_isProcessing) return;
//     _isProcessing = true;
//     // For now, any successful scan is considered valid.
//     // We pop the screen with a `true` value to indicate success.
//     Navigator.of(context).pop(true);
//   }

//   @override
//   void dispose() {
//     _scannerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scanWindow = Rect.fromCenter(
//       center: MediaQuery.of(context).size.center(Offset.zero),
//       width: 250,
//       height: 250,
//     );

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Camera View
//           MobileScanner(
//             controller: _scannerController,
//             onDetect: _onDetect,
//             scanWindow: scanWindow,
//             errorBuilder: (context, error, child) {
//               return Center(
//                 child: Text(
//                   'Error: ${error.errorDetails?.message}',
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               );
//             },
//           ),

//           // Semi-transparent overlay with a cutout for the scanner
//           ColorFiltered(
//             colorFilter: ColorFilter.mode(
//               Colors.black.withOpacity(0.7),
//               BlendMode.srcOut,
//             ),
//             child: Stack(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.transparent,
//                     backgroundBlendMode: BlendMode.dstOut,
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.center,
//                   child: Container(
//                     height: 250,
//                     width: 250,
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Scanner Border
//           Align(
//             alignment: Alignment.center,
//             child: CustomPaint(
//               foregroundPainter: BorderPainter(),
//               child: const SizedBox(
//                 width: 251,
//                 height: 251,
//               ),
//             ),
//           ),

//           // Top Bar with Title and Flashlight
//           Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 60.0, right: 20, left: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.of(context).pop(),
//                     child: const CircleAvatar(
//                       backgroundColor: Colors.black54,
//                       child: Icon(Icons.close, color: Colors.white),
//                     ),
//                   ),
//                   const Text(
//                     'Scan Aadhaar QR Code',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   CircleAvatar(
//                     backgroundColor: Colors.black54,
//                     child: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _isFlashOn = !_isFlashOn;
//                         });
//                         _scannerController.toggleTorch();
//                       },
//                       icon: Icon(
//                         _isFlashOn ? Icons.flash_on : Icons.flash_off,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Bottom Bar with Gallery Picker
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 50.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     'Position QR code within the frame',
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                   const SizedBox(height: 30),
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.black,
//                       backgroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                       ),
//                     ),
//                     onPressed: () async {
//                       final ImagePicker picker = ImagePicker();
//                       final XFile? image = await picker.pickImage(
//                         source: ImageSource.gallery,
//                       );
//                       if (image != null) {
//                         if (await _scannerController.analyzeImage(image.path) !=
//                             null) {
//                           // This will trigger the onDetect method if a QR is found
//                         } else {
//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('No QR code found in the image!'),
//                               ),
//                             );
//                           }
//                         }
//                       }
//                     },
//                     icon: const Icon(Icons.photo_library_outlined),
//                     label: const Text('Pick from Gallery'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom painter for the animated border
// class BorderPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     const width = 4.0;
//     const radius = 20.0;
//     const tRadius = 3 * radius;
//     final rect = Rect.fromLTWH(
//       width / 2,
//       width / 2,
//       size.width - width,
//       size.height - width,
//     );
//     final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
//     const clippingRect0 = Rect.fromLTWH(0, 0, tRadius, tRadius);
//     final clippingRect1 =
//         Rect.fromLTWH(size.width - tRadius, 0, tRadius, tRadius);
//     final clippingRect2 =
//         Rect.fromLTWH(0, size.height - tRadius, tRadius, tRadius);
//     final clippingRect3 = Rect.fromLTWH(
//         size.width - tRadius, size.height - tRadius, tRadius, tRadius);

//     final path = Path()
//       ..addRRect(rrect)
//       ..addRect(clippingRect0)
//       ..addRect(clippingRect1)
//       ..addRect(clippingRect2)
//       ..addRect(clippingRect3);

//     canvas.clipPath(path);
//     canvas.drawRRect(
//       rrect,
//       Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = width,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
