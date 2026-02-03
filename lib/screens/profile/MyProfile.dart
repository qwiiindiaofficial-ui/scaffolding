import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/profile/EditProfile.dart';
import 'package:scaffolding_sale/widgets/button.dart';

class MyProfile extends StatefulWidget {
  final String? ticketName;

  const MyProfile({super.key, this.ticketName});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title:
            const Text('Party Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const EditProfile();
              }));
            },
          ),
          IconButton(
            icon: Image.asset('images/whatsapp.png'),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(
                    0, 100, 0, 0), // Adjust position as needed
                items: [
                  const PopupMenuItem(
                    value: 'Owner',
                    child: Text('Company Owner',
                        style: TextStyle(color: Colors.green)),
                  ),
                  const PopupMenuItem(
                    value: 'Accountant',
                    child: Text('Accountant'),
                  ),
                  const PopupMenuItem(
                    value: 'Project Manager',
                    child: Text('Project Manager'),
                  ),
                  const PopupMenuItem(
                    value: 'General Manager',
                    child: Text('General Manager'),
                  ),
                  const PopupMenuItem(
                    value: 'Store Manager',
                    child: Text('Store Manager'),
                  ),
                  const PopupMenuItem(
                    value: 'site engineer',
                    child: Text('Site Engineer'),
                  ),
                  const PopupMenuItem(
                    value: 'Site Supervisor',
                    child: Text('Site Supervisor'),
                  ),
                  const PopupMenuItem(
                    value: 'Property Owner',
                    child: Text('Property Owner',
                        style: TextStyle(color: Colors.red)),
                  ),
                  const PopupMenuItem(
                    value: 'Others',
                    child: Text('Others'),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  // Create this function to handle WhatsApp
                }
              });
              // Your existing WhatsApp menu code
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(
                    0, 100, 0, 0), // Adjust position as needed
                items: [
                  const PopupMenuItem(
                    value: 'Owner',
                    child: Text('Company Owner',
                        style: TextStyle(color: Colors.green)),
                  ),
                  const PopupMenuItem(
                    value: 'Accountant',
                    child: Text('Accountant'),
                  ),
                  const PopupMenuItem(
                    value: 'Project Manager',
                    child: Text('Project Manager'),
                  ),
                  const PopupMenuItem(
                    value: 'General Manager',
                    child: Text('General Manager'),
                  ),
                  const PopupMenuItem(
                    value: 'Store Manager',
                    child: Text('Store Manager'),
                  ),
                  const PopupMenuItem(
                    value: 'site engineer',
                    child: Text('Site Engineer'),
                  ),
                  const PopupMenuItem(
                    value: 'Site Supervisor',
                    child: Text('Site Supervisor'),
                  ),
                  const PopupMenuItem(
                    value: 'Property Owner',
                    child: Text('Property Owner',
                        style: TextStyle(color: Colors.red)),
                  ),
                  const PopupMenuItem(
                    value: 'Others',
                    child: Text('Others'),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  // Create this function to handle WhatsApp
                }
              });
              // Your existing call menu code
            },
          ),
          const SizedBox(
            width: 50,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Profile Completion: 75%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '75/100',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value:
                        0.75, // Set this value according to your completion percentage (0.0 to 1.0)
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              _showPickerOptions(context);
            },
            child: Center(
              child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  backgroundImage: _selectedImage == null
                      ? null
                      : FileImage(_selectedImage!),
                  child: _selectedImage == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                      : Container()),
            ),
          ),
          //TODO addpicturewidget
          const Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: BusinessDetailsWidget4(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                RegisterField(
                    hint: "Email", controller: TextEditingController()),
                SizedBox(
                  height: 12,
                ),
                RegisterField(
                    hint: "Phone No.", controller: TextEditingController())
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Text(
                  'G.S.T Certificate',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: 80,
                ),
                Text(
                  "MSME Number",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showPickerOptions(context);
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: 'Upload',
                            suffixIcon:
                                Icon(Icons.add_photo_alternate_rounded)),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _showPickerOptions(context);
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            hintText: 'Upload',
                            suffixIcon:
                                Icon(Icons.add_photo_alternate_rounded)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: PrimaryButton(onTap: () {}, text: "Save"),
          )
        ],
      ),
    );
  }

  void _showPickerOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _pickFromCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('File'),
            onTap: () {
              Navigator.pop(context);
              _pickFromFile();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  File? _selectedImage;
  ImagePicker _picker = ImagePicker();
}
