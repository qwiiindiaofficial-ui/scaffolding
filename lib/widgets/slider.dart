import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class CatalogueSlider extends StatefulWidget {
  final List<Map<String, dynamic>> catalogueMedia; // [{path, desc, isVideo}]

  const CatalogueSlider({Key? key, required this.catalogueMedia})
      : super(key: key);

  @override
  State<CatalogueSlider> createState() => _CatalogueSliderState();
}

class _CatalogueSliderState extends State<CatalogueSlider> {
  int _current = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.catalogueMedia;

    if (mediaList.isEmpty) {
      return const Center(child: Text('No catalogue items to show.'));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          // width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: mediaList.length,
            onPageChanged: (int index) {
              setState(() {
                _current = index;
              });
            },
            itemBuilder: (context, index) {
              final item = mediaList[index];
              final isVideo = item['isVideo'] as bool;
              final path = item['path'] as String;
              final desc = item['desc'] as String? ?? '';

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isVideo
                        ? Stack(
                            children: [
                              // Show video thumbnail or placeholder
                              VideoThumbnail(path: path),
                              const Center(
                                child: Icon(Icons.play_circle_fill,
                                    color: Colors.white, size: 50),
                              ),
                            ],
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.fill,
                            width: double.infinity,
                            // height: 300,
                            // errorBuilder: (context, error, stackTrace) =>
                            //     const Center(
                            //         child: Text('Failed to load image')),
                          ),
                  ),
                  if (desc.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        child: Text(
                          desc,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: mediaList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                // Delay the animateToPage call
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_controller.hasClients) {
                    _controller.animateToPage(
                      entry.key,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                    setState(() {
                      _current = entry.key;
                    });
                  }
                });
              },
              child: Container(
                width: 12.0,
                height: 12.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Video thumbnail widget (placeholder, you can use a package for real thumbnail)
class VideoThumbnail extends StatelessWidget {
  final String path;
  const VideoThumbnail({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For real thumbnail, use 'video_thumbnail' package or similar
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white70, size: 60),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<Map<String, dynamic>> _catalogueMedia = [];

  @override
  void initState() {
    super.initState();
    _loadCatalogueData();
  }

  Future<void> _loadCatalogueData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? photosJson = prefs.getString('cataloguePhotosWithDesc');
    final String? videosJson = prefs.getString('catalogueVideosWithDesc');

    List<Map<String, String>> photos = [];
    List<Map<String, String>> videos = [];

    if (photosJson != null) {
      final List<dynamic> decodedPhotos = jsonDecode(photosJson);
      photos = decodedPhotos.map((e) => Map<String, String>.from(e)).toList();
    }
    if (videosJson != null) {
      final List<dynamic> decodedVideos = jsonDecode(videosJson);
      videos = decodedVideos.map((e) => Map<String, String>.from(e)).toList();
    }

    // Combine photos and videos
    List<Map<String, dynamic>> combinedMedia = [
      ...photos.map((e) => {...e, 'isVideo': false}),
      ...videos.map((e) => {...e, 'isVideo': true}),
    ];

    setState(() {
      _catalogueMedia = combinedMedia;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue Slider Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _catalogueMedia.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CatalogueSlider(catalogueMedia: _catalogueMedia),
      ),
    );
  }
}
