// screens/home/NewStaff.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/button.dart';
import 'package:scaffolding_sale/widgets/text.dart';

// models/post_model.dart

class Post {
  File? image;
  String text;
  DateTime timestamp;

  Post({this.image, required this.text, required this.timestamp});
}

// Yeh static list "session" ki tarah kaam karegi. App jab tak chal raha hai,
// posts ismein store rahenge.
class PostService {
  static List<Post> posts = [];
}

class NewStaff extends StatefulWidget {
  const NewStaff({super.key});

  @override
  State<NewStaff> createState() => _NewStaffState();
}

class _NewStaffState extends State<NewStaff> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to handle the post submission
  void _submitPost() {
    if (_textController.text.trim().isEmpty) {
      // Show an error if text is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text for your post.')),
      );
      return;
    }

    // Create a new post object
    final newPost = Post(
      image: _selectedImage,
      text: _textController.text,
      timestamp: DateTime.now(),
    );

    // Add the post to our static list (session)
    // We add to the beginning of the list to show newest first
    PostService.posts.insert(0, newPost);

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post added successfully!')),
    );

    // Go back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kWhiteTextColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Add New Post",
          color: ThemeColors.kWhiteTextColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_sharp,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Tap to select an image"),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Text Input Field
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                hintText: 'Type here...',
              ),
              maxLines: 7,
            ),
            const Spacer(),
            PrimaryButton(
              onTap: _submitPost,
              text: "Post",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// files/PostEditorPage.dart (NewStaff.dart का नाम बदलकर)

// ----------------------------------------------------

class PostEditorPage extends StatefulWidget {
  // अगर हम Edit कर रहे हैं तो existingPost null नहीं होगा
  final Post? existingPost;
  // अगर हम Edit कर रहे हैं तो postIndex का पता होगा
  final int? postIndex;

  const PostEditorPage({super.key, this.existingPost, this.postIndex});

  @override
  State<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing =
      false; // यह ट्रैक करने के लिए कि हम Edit कर रहे हैं या Create

  @override
  void initState() {
    super.initState();
    // अगर existingPost है, तो Edit मोड ऑन करें और डेटा लोड करें
    if (widget.existingPost != null) {
      _isEditing = true;
      _textController.text = widget.existingPost!.text;
      _selectedImage = widget.existingPost!.image;
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // Function to handle the post submission/update
  void _submitPost() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text for your post.')),
      );
      return;
    }

    if (_isEditing) {
      // 1. **EDIT Logic**
      if (widget.postIndex != null) {
        // existing post को सीधे list में update करें
        PostService.posts[widget.postIndex!]
          ..text = _textController.text
          ..image = _selectedImage
          ..timestamp = DateTime.now(); // Edit करने पर timestamp अपडेट करें

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!')),
        );
      }
    } else {
      // 2. **CREATE Logic**
      final newPost = Post(
        image: _selectedImage,
        text: _textController.text,
        timestamp: DateTime.now(),
      );
      PostService.posts.insert(0, newPost);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post added successfully!')),
      );
    }

    // Go back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.kWhiteTextColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: _isEditing
              ? "Edit Post"
              : "Add New Post", // Title dynamic किया गया
          color: ThemeColors.kWhiteTextColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150),
                          ),
                          // Remove Image Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: _removeImage,
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_sharp,
                              size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Tap to select an image"),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Text Input Field
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                hintText: 'Type here...',
              ),
              maxLines: 7,
            ),
            const Spacer(),
            PrimaryButton(
              onTap: _submitPost,
              text: _isEditing
                  ? "Update Post"
                  : "Post", // Button text dynamic किया गया
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
