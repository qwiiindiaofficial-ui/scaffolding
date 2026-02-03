import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:scaffolding_sale/screens/trimmer.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_player/video_player.dart';

class Catalogue extends StatefulWidget {
  @override
  _CatalogueState createState() => _CatalogueState();
}

class _CatalogueState extends State<Catalogue> {
  final ImagePicker _picker = ImagePicker();

  // Separate lists for photos and videos, each item has path and description
  List<Map<String, String>> photos = [];
  List<Map<String, String>> videos = [];

  String? _mainImagePath; // Path to the main image

  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  Future<void> loadMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final String? photosJson = prefs.getString('cataloguePhotosWithDesc');
    final String? videosJson = prefs.getString('catalogueVideosWithDesc');
    _mainImagePath = prefs.getString('mainImagePath'); // Load main image path

    if (photosJson != null) {
      final List<dynamic> decodedPhotos = jsonDecode(photosJson);
      photos = decodedPhotos.map((e) => Map<String, String>.from(e)).toList();
    }
    if (videosJson != null) {
      final List<dynamic> decodedVideos = jsonDecode(videosJson);
      videos = decodedVideos.map((e) => Map<String, String>.from(e)).toList();
    }
    setState(() {});
  }

  Future<void> saveMedia() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cataloguePhotosWithDesc', jsonEncode(photos));
    await prefs.setString('catalogueVideosWithDesc', jsonEncode(videos));
    await prefs.setString(
        'mainImagePath', _mainImagePath!); // Save main image path
  }

  Future<String?> _getDescriptionFromUser(BuildContext context,
      [String? initialDesc]) async {
    TextEditingController controller =
        TextEditingController(text: initialDesc ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Description'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Description'),
          autofocus: true,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, [int? index]) async {
    if (photos.length >= 50) {
      _showMessage(context, 'Maximum 50 photos allowed.');
      return;
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final int sizeInBytes = await file.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 5) {
        _showMessage(context, 'Photo size should be less than 5 MB.');
        return;
      }

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.teal,
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
        String? description = await _getDescriptionFromUser(context);
        if (description == null) return;

        setState(() {
          if (index == null || index >= photos.length) {
            photos.add({'path': croppedFile.path, 'desc': description});
          } else {
            photos[index] = {'path': croppedFile.path, 'desc': description};
          }
        });

        await saveMedia();

        _showSelectedMediaDialog(context, croppedFile.path, description,
            isVideo: false);
      }
    }
  }

  // final Trimmer _trimmer = Trimmer();

  Future<void> _pickVideo(BuildContext context) async {
    if (videos.length >= 5) {
      _showMessage(context, 'Maximum 5 videos allowed.');
      return;
    }

    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      // await _trimmer.loadVideo(videoFile: File(pickedFile.path));

      // // Navigate to trimming screen
      // final double? startValue = await Navigator.of(context).push<double>(
      //   MaterialPageRoute(
      //     builder: (context) => TrimmerView(trimmer: _trimmer),
      //   ),
      // );

      // if (startValue != null) {
      //   // Save the trimmed video
      //   String? outputPath;
      //   await _trimmer.saveTrimmedVideo(
      //     startValue: 0.0,
      //     endValue: startValue,
      //     onSave: (String? path) {
      //       outputPath = path;
      //     },
      //   );

      //   if (outputPath != null) {
      //     String? description = await _getDescriptionFromUser(context);
      //     if (description == null) return;

      //     setState(() {
      //       videos.add({'path': outputPath!, 'desc': description});
      //     });

      //     await saveMedia();

      //     _showSelectedMediaDialog(context, outputPath!, description,
      //         isVideo: true);
      //   }
      // }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSelectedMediaDialog(
      BuildContext context, String path, String description,
      {required bool isVideo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isVideo ? 'Selected Video' : 'Selected Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isVideo
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayerWidget(videoFile: File(path)),
                  )
                : Image.file(File(path)),
            SizedBox(height: 8),
            Text(description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _editDescription(
      BuildContext context, bool isVideo, int index) async {
    List<Map<String, String>> list = isVideo ? videos : photos;
    String currentDesc = list[index]['desc'] ?? '';
    String? newDesc = await _getDescriptionFromUser(context, currentDesc);
    if (newDesc != null) {
      setState(() {
        list[index]['desc'] = newDesc;
      });
      await saveMedia();
    }
  }

  Future<void> _deleteMedia(bool isVideo, int index) async {
    setState(() {
      if (isVideo) {
        videos.removeAt(index);
      } else {
        photos.removeAt(index);
      }
    });
    await saveMedia();
  }

  Future<void> _selectMainImage(BuildContext context) async {
    if (photos.isEmpty) {
      _showMessage(context, 'No photos available to select as main image.');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            for (int i = 0; i < photos.length; i++)
              ListTile(
                leading: Image.file(
                  File(photos[i]['path']!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(photos[i]['desc']!),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _mainImagePath = photos[i]['path'];
                  });
                  saveMedia();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combine photos and videos for display, with a type flag
    List<Map<String, dynamic>> combinedMedia = [
      ...photos.map((e) => {...e, 'isVideo': false}),
      ...videos.map((e) => {...e, 'isVideo': true}),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Catalogue', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            tooltip: 'Add Photo',
            onPressed: () => _pickImage(context),
          ),
          IconButton(
            icon: Icon(Icons.video_library),
            tooltip: 'Add Video',
            onPressed: () => _pickVideo(context),
          ),
          IconButton(
            icon: Icon(Icons.star),
            tooltip: 'Select Main Image',
            onPressed: () => _selectMainImage(context),
          ),
          // IconButton(
          //   icon: Icon(Icons.delete_outline),
          //   tooltip: 'Clear All',
          //   onPressed: () async {
          //     setState(() {
          //       photos.clear();
          //       videos.clear();
          //     });
          //     await saveMedia();
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: combinedMedia.isEmpty
            ? Center(child: Text('No photos or videos added yet.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "You can add upto 50 images and 5 videos",
                    weight: FontWeight.normal,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (_mainImagePath != null) ...[
                    const Text('Main Image:'),
                    Image.file(
                      File(_mainImagePath!),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                  ],
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: combinedMedia.length,
                    itemBuilder: (context, index) {
                      final media = combinedMedia[index];
                      final isVideo = media['isVideo'] as bool;
                      final path = media['path'] as String;
                      final desc = media['desc'] as String? ?? '';

                      return GestureDetector(
                        onTap: () {
                          if (isVideo) {
                            _showSelectedMediaDialog(context, path, desc,
                                isVideo: true);
                          } else {
                            // _openGallery(context,
                            //     photos.indexWhere((p) => p['path'] == path));
                          }
                        },
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit Description'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _editDescription(
                                          context,
                                          isVideo,
                                          isVideo
                                              ? videos.indexWhere(
                                                  (v) => v['path'] == path)
                                              : photos.indexWhere(
                                                  (p) => p['path'] == path));
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      _deleteMedia(
                                          isVideo,
                                          isVideo
                                              ? videos.indexWhere(
                                                  (v) => v['path'] == path)
                                              : photos.indexWhere(
                                                  (p) => p['path'] == path));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      isVideo
                                          ? VideoThumbnail(path: path)
                                          : Image.file(
                                              File(path),
                                              fit: BoxFit.cover,
                                            ),
                                      if (isVideo)
                                        Center(
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white70,
                                            size: 50,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                alignment: Alignment.center,
                                child: Text(
                                  desc,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

// Widget to show video thumbnail using VideoPlayerController
class VideoThumbnail extends StatefulWidget {
  final String path;
  const VideoThumbnail({required this.path});

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(color: Colors.black12);
    }
    return VideoPlayer(_controller);
  }
}

// Widget to play video in dialog
class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;
  const VideoPlayerWidget({required this.videoFile});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
            _controller.play();
            _isPlaying = true;
          });
        }
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _controller.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          _ControlsOverlay(
            controller: _controller,
            isPlaying: _isPlaying,
            togglePlayPause: _togglePlayPause,
          ),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isPlaying;
  final VoidCallback togglePlayPause;

  const _ControlsOverlay({
    required this.controller,
    required this.isPlaying,
    required this.togglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: togglePlayPause,
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: Colors.white,
            size: 64,
          ),
        ),
      ),
    );
  }
}
