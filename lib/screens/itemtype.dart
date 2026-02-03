import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scaffolding_sale/screens/home/stock.dart';
import 'package:scaffolding_sale/widgets/button.dart';

import '../utils/colors.dart';

class ItemTypeScreen extends StatelessWidget {
  final List<Map<String, String>> items = [
    {"title": "All Items", "dispatch": "1", "available": "1"},
    {"title": "Base/Jack", "dispatch": "1", "available": "1"},
    {"title": "Botal", "dispatch": "1", "available": "1"},
    {"title": "Challe", "dispatch": "1", "available": "1"},
    {"title": "Channel", "dispatch": "1", "available": "1"},
    {"title": "Clamps", "dispatch": "1", "available": "1"},
    {"title": "Joint Pin", "dispatch": "1", "available": "1"},
    {"title": "Ledger", "dispatch": "1", "available": "1"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Item Type',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Show bottom sheet
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return AddItemTypeBottomSheet();
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: ThemeColors.kSecondaryThemeColor,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Add item type',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All item Value'),
                Text('Dispatch Value: 1',
                    style: TextStyle(color: Colors.black)),
                Text('Available Value: 1',
                    style: TextStyle(color: Colors.black)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    isThreeLine: true,
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.orange,
                      child: Text(
                        item['title']![0],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    title: Text(item['title']!),
                    subtitle: Row(
                      children: [
                        const Text('All Items: 1',
                            style: TextStyle(color: Colors.red)),
                        const SizedBox(width: 16),
                        Text('Dispatch: ${item['dispatch']}',
                            style: const TextStyle(color: Colors.yellow)),
                        const SizedBox(width: 16),
                        Text('Available: ${item['available']}',
                            style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.red),
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: 'Edit',
                            child: Text("Edit",
                                style: TextStyle(color: Colors.black))),
                        PopupMenuItem(
                            value: 'Delete',
                            child: Text("Delete",
                                style: TextStyle(color: Colors.red))),
                        PopupMenuItem(
                            value: 'View Details', child: Text("View Details")),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 1, // Adjust thickness as needed
                    color: Colors.grey, // Adjust color as needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddItemTypeBottomSheet extends StatefulWidget {
  @override
  _AddItemTypeBottomSheetState createState() => _AddItemTypeBottomSheetState();
}

class _AddItemTypeBottomSheetState extends State<AddItemTypeBottomSheet> {
  ImagePicker _picker = ImagePicker();

  Future<void> _pickFromFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Do something with the picked file
      print('Picked file: ${result.files.single.path}');
    }
  }

  Future<void> _pickFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Do something with the picked file
      print('Picked image from camera: ${pickedFile.path}');
    }
  }

  // Function to pick image from gallery
  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Do something with the picked file
      print('Picked image from gallery: ${pickedFile.path}');
    }
  }

  final _formKey = GlobalKey<FormState>();
  void _showPickerOptions() {
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

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  bool _isCeilingCategory = false;
  bool _isPlate = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Item Type',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _showPickerOptions();
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _imageController,
                          decoration: InputDecoration(
                            suffixIcon:
                                const Icon(Icons.add_photo_alternate_outlined),
                            labelText: 'Image',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'HSN Code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              PrimaryButton(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: MediaQuery.of(context).size.height * 0.86,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0),
                            ),
                          ),
                          child: OpeningStockAddItemBottomSheet(
                            scrollController: ScrollController(),
                          ),
                        );
                      },
                    );
                  },
                  text: "Save")
            ],
          ),
        ),
      ),
    );
  }
}
