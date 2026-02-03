// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class RegisterField extends StatelessWidget {
//   final String hint;
//   final int? maxLines;
//   final bool enabled;
//   final Widget? suffixIcon;
//   final TextEditingController? controller;
//   final void Function(String)? onChanged;
//   final TextInputType? keyboardType;
//   const RegisterField({
//     super.key,
//     required this.hint,
//     this.suffixIcon,
//     this.controller,
//     this.onChanged,
//     this.maxLines,
//     this.enabled = true, this.keyboardType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       onChanged: onChanged,
//       controller: controller,
//       enabled: enabled,
//       keyboardType: keyboardType,
//       maxLines: maxLines ?? 1,
//       decoration: InputDecoration(
//           suffixIcon: suffixIcon,
//           border: OutlineInputBorder(
//             borderSide: const BorderSide(color: Colors.black, width: 0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           filled: true,
//           hintStyle: TextStyle(
//             color: const Color(0xFF959595),
//             fontSize: 13,
//             fontFamily: GoogleFonts.inter().fontFamily,
//             fontWeight: FontWeight.w400,
//             height: 0,
//           ),
//           fillColor: Colors.white,
//           hintText: hint),
//     );
//   }
// }
