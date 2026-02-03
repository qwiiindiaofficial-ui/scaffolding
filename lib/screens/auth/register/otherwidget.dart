import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:signature/signature.dart';

class RadiusCirclePainter extends CustomPainter {
  final double progress;
  final int radius;

  RadiusCirclePainter({
    required this.progress,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate the circle radius based on the selected radius value
    // Scale it to fit within our container
    final maxRadius = math.min(size.width, size.height) / 2;
    final circleRadius =
        maxRadius * (radius / 500); // Scale to a reasonable max radius

    // Draw a semi-transparent fill
    final paint = Paint()
      ..color = ThemeColors.kPrimaryThemeColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, circleRadius, paint);

    // Draw ripple effect (multiple circles with decreasing opacity)
    for (int i = 1; i <= 3; i++) {
      final ripplePaint = Paint()
        ..color = ThemeColors.kPrimaryThemeColor.withOpacity(0.1 / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final rippleRadius = circleRadius + (i * 5 * progress);
      canvas.drawCircle(center, rippleRadius, ripplePaint);
    }

    // Draw circle border
    final borderPaint = Paint()
      ..color = ThemeColors.kPrimaryThemeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, circleRadius, borderPaint);
  }

  @override
  bool shouldRepaint(RadiusCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.radius != radius;
  }
}

class BusinessDetailsWidget4 extends StatefulWidget {
  final String mobilenumber;
  final bool emptyFields;
  const BusinessDetailsWidget4(
      {super.key, this.emptyFields = false, this.mobilenumber = ""});

  @override
  State<BusinessDetailsWidget4> createState() => _BusinessDetailsWidget4State();
}

class _BusinessDetailsWidget4State extends State<BusinessDetailsWidget4> {
  File? _selectedImage;

  Color _businessNameColor = Colors.black;

  final Map<String, String> gstData = {
    "GSTIN": "09DVYPK0644G1Z3", // Replace with actual GSTIN if needed
    "Trade Name": "ANKLEGAMING PRIVATE LIMITED",
    // "Legal Name": "NA",
    "Address":
        "T-389 THIRD FLOOR, BALJEET NAGAR, T-389 THIRD FLOOR, Central Delhi, Delhi, 110008",
    "State Code": "09",
    "Pin Code": "201301",
  };

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
        _showImagePreview();
      }
    } catch (e) {
      print("Error picking/cropping image: $e");
    }
  }

  void _showImagePreview() {
    if (_selectedImage != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {String? secondTitle}) {
    TextEditingController controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Spacer(),
              secondTitle == null
                  ? Container()
                  : Text(
                      secondTitle,
                      style: TextStyle(
                          color: ThemeColors.kPrimaryThemeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    )
            ],
          ),
          TextFormField(
            maxLines: value.contains("STRUCTURES")
                ? 10
                : label.contains("Address")
                    ? 4
                    : 1,
            controller: widget.emptyFields ? null : controller,
            style: TextStyle(
              color: value == "Active"
                  ? controller.text == "Active"
                      ? Colors.green
                      : Colors.red
                  : label.toLowerCase().contains("trade name")
                      ? _businessNameColor
                      : Colors.black,
            ),
            decoration: InputDecoration(
              suffixIcon: label.toLowerCase().contains("trade name")
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedImage != null)
                          IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: _showImagePreview,
                          ),
                        // IconButton(
                        //   icon: Icon(Icons.add_photo_alternate),
                        //   onPressed: _pickAndCropImage,
                        // ),
                        // DropdownButton<Color>(
                        //   value: _businessNameColor,
                        //   underline: Container(),
                        //   icon: Icon(Icons.arrow_drop_down,
                        //       color: _businessNameColor),
                        //   onChanged: (Color? newColor) {
                        //     if (newColor != null) {
                        //       setState(() {
                        //         _businessNameColor = newColor;
                        //       });
                        //     }
                        //   },
                        //   items: const [
                        //     DropdownMenuItem(
                        //       value: Colors.black,
                        //       child: Text("Black",
                        //           style: TextStyle(color: Colors.black)),
                        //     ),
                        //     DropdownMenuItem(
                        //       value: Colors.blue,
                        //       child: Text("Blue",
                        //           style: TextStyle(color: Colors.blue)),
                        //     ),
                        //     DropdownMenuItem(
                        //       value: Colors.red,
                        //       child: Text("Red",
                        //           style: TextStyle(color: Colors.red)),
                        //     ),
                        //     DropdownMenuItem(
                        //       value: Colors.green,
                        //       child: Text("Green",
                        //           style: TextStyle(color: Colors.green)),
                        //     ),
                        //     DropdownMenuItem(
                        //       value: Colors.purple,
                        //       child: Text("Purple",
                        //           style: TextStyle(color: Colors.purple)),
                        //     ),
                        //     DropdownMenuItem(
                        //       value: Colors.orange,
                        //       child: Text("Orange",
                        //           style: TextStyle(color: Colors.orange)),
                        //     ),
                        //   ],
                        // ),
                      ],
                    )
                  : null,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: gstData.entries
            .map((entry) => _buildDetailRow(entry.key, entry.value))
            .toList(),
      ),
    );
  }
}

class AddStoreForm extends StatefulWidget {
  final String phone;
  final bool showStore;

  AddStoreForm({super.key, required this.showStore, required this.phone});
  @override
  _AddStoreFormState createState() => _AddStoreFormState();
}

class _AddStoreFormState extends State<AddStoreForm> {
  Widget _buildStoreTypeRadio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Store ${getStoreLetter(0)} Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Sale Radio Button
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Sale'),
                  value: 'Sale',
                  groupValue: _selectedStoreType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStoreType = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              // Rent Radio Button
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Rent'),
                  value: 'Rent',
                  groupValue: _selectedStoreType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStoreType = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              // Both Radio Button
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Both'),
                  value: 'Both',
                  groupValue: _selectedStoreType,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedStoreType = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  List<Widget> storeForms = [];
  // Add a counter to keep track of stores
  int storeCount = 0;

  void _addStoreForm() {
    setState(() {
      storeCount++; // Increment store counter
      storeForms.add(_buildStoreForm());
    });
  }

  List addedContacts = [];
  TextEditingController _mobileController = TextEditingController();

  // Helper function to get store letter based on index
  String getStoreLetter(int index) {
    // Convert number to corresponding letter (0 = A, 1 = B, etc.)
    return String.fromCharCode(65 + index); // 65 is ASCII for 'A'
  }

  @override
  void initState() {
    _mobileController = TextEditingController(text: widget.phone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RegisterField(
                keyboardType: TextInputType.number,
                hint: "Store Phone Number",
                controller: _mobileController,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.contact_phone),
                  onPressed: () async {
                    await FlutterContacts.requestPermission();
                    try {
                      final contact = await FlutterContacts.openExternalPick();
                      if (contact != null) {
                        final fullContact =
                            await FlutterContacts.getContact(contact.id);
                        if (fullContact?.phones.isNotEmpty == true) {
                          if (fullContact!.phones.length > 1) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Select Phone Number'),
                                  content: Container(
                                    width: double.minPositive,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: fullContact.phones.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                              fullContact.phones[index].number),
                                          onTap: () {
                                            String cleanNumber = fullContact
                                                .phones[index].number
                                                .replaceAll(
                                                    RegExp(r'[^\d]'), '');
                                            if (cleanNumber.length > 10) {
                                              cleanNumber =
                                                  cleanNumber.substring(
                                                      cleanNumber.length - 10);
                                            }
                                            setState(() {
                                              _mobileController.text =
                                                  cleanNumber;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            String cleanNumber = fullContact.phones.first.number
                                .replaceAll(RegExp(r'[^\d]'), '');
                            if (cleanNumber.length > 10) {
                              cleanNumber = cleanNumber
                                  .substring(cleanNumber.length - 10);
                            }
                            setState(() {
                              _mobileController.text = cleanNumber;
                            });
                          }
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to access contacts: $e')),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              child: IconButton.filled(
                color: Colors.white,
                onPressed: () {
                  addedContacts.add(_mobileController.text);
                  _mobileController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        if (addedContacts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addedContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(addedContacts[index]),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        RegisterField(
          keyboardType: TextInputType.emailAddress,
          hint: "Store Email",
          controller: TextEditingController(),
        ),
        const SizedBox(height: 12),
        _buildStoreTypeRadio(),
        SizedBox(
          height: 12,
        ),
        widget.showStore
            ? PrimaryButton(onTap: _addStoreForm, text: "Add Store")
            : Container(),
        Column(children: storeForms),
      ],
    );
  }

  Widget _buildStoreForm() {
    final storeLetter = getStoreLetter(storeCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Store $storeLetter Details"),
        _buildDetailRow("Store Name", ""),
        _buildStoreTypeRadio(), // New method for store type radio buttons
        _buildDetailRow("Store Address", "", maxlines: true),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      await FlutterContacts.requestPermission();
                      if (true) {
                        try {
                          final contact =
                              await FlutterContacts.openExternalPick();
                          if (contact != null) {
                            final fullContact =
                                await FlutterContacts.getContact(contact.id);
                            if (fullContact?.phones.isNotEmpty == true) {
                              if (fullContact!.phones.length > 1) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Select Phone Number'),
                                      content: Container(
                                        width: double.minPositive,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: fullContact.phones.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(fullContact
                                                  .phones[index].number),
                                              onTap: () {
                                                setState(() {
                                                  String cleanNumber =
                                                      fullContact
                                                          .phones[index].number
                                                          .replaceAll(
                                                              RegExp(r'[^\d]'),
                                                              '');
                                                  if (cleanNumber.length > 10) {
                                                    cleanNumber =
                                                        cleanNumber.substring(
                                                            cleanNumber.length -
                                                                10);
                                                  }
                                                  _mobileController.text =
                                                      cleanNumber;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                String cleanNumber = fullContact
                                    .phones.first.number
                                    .replaceAll(RegExp(r'[^\d]'), '');
                                if (cleanNumber.length > 10) {
                                  cleanNumber = cleanNumber
                                      .substring(cleanNumber.length - 10);
                                }
                                setState(() {
                                  _mobileController.text = cleanNumber;
                                });
                              }
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to access contacts: $e')),
                          );
                        }
                      }
                    },
                    child: IgnorePointer(
                      child: RegisterField(
                        keyboardType: TextInputType.number,
                        hint: "Store Phone Number",
                        suffixIcon: const Icon(Icons.contact_phone),
                        controller: _mobileController,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  child: IconButton.filled(
                    color: Colors.white,
                    onPressed: () {
                      addedContacts.add(_mobileController.text);
                      _mobileController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            if (addedContacts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addedContacts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(addedContacts[index]),
                    );
                  },
                ),
              ),
          ],
        ),
        _buildDetailRow("Store Email", ""),
        _buildDetailRow("Website", ""),
        _buildDetailRow("Other Details", "", maxlines: true),
        const SizedBox(height: 20),
      ],
    );
  }

  // Add this to your state variables at the top of the class
  String _selectedStoreType = 'Sale';

  Widget _buildDetailRow(String label, String value, {bool maxlines = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RegisterField(
        maxLines: maxlines ? 3 : null,
        hint: label,
        controller: TextEditingController(text: value),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}

class HandSignatureDialog extends StatefulWidget {
  const HandSignatureDialog({super.key});

  @override
  _HandSignatureDialogState createState() => _HandSignatureDialogState();
}

class _HandSignatureDialogState extends State<HandSignatureDialog> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hand Signature',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),

        // Signature Canvas
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  _controller.clear();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    final signature = await _controller.toPngBytes();
                    // Save or use the signature image
                    Navigator.pop(context, signature);
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StateDropdown extends StatelessWidget {
  final String hint;
  final List<String> states;
  final String? selectedState;
  final void Function(String?)? onChanged;
  final bool enabled;

  const StateDropdown({
    super.key,
    required this.hint,
    required this.states,
    required this.selectedState,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedState,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: const Color(0xFF959595),
          fontSize: 13,
          fontFamily: GoogleFonts.inter().fontFamily,
          fontWeight: FontWeight.w400,
          height: 0,
        ),
        fillColor: Colors.white,
        hintText: hint,
      ),
      items: states.map((String state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(state),
        );
      }).toList(),
    );
  }
}

class RegisterField extends StatelessWidget {
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final void Function(String)? onChanged;
  final bool enabled;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const RegisterField({
    super.key,
    required this.hint,
    this.onChanged,
    this.controller,
    this.maxLines,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUnfocus,
      enabled: enabled,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines ?? 1,
      controller: controller,
      style: TextStyle(),
      validator: validator,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: const Color(0xFF959595),
          fontSize: 13,
          fontFamily: GoogleFonts.inter().fontFamily,
          fontWeight: FontWeight.w400,
          height: 0,
        ),
        fillColor: Colors.white,
        hintText: hint,
      ),
    );
  }
}
