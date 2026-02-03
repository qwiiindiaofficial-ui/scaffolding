import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/rental/rental.dart';
import 'package:scaffolding_sale/screens/home/sale/Service.dart';
import 'package:scaffolding_sale/screens/home/sale/purchase.dart';
import 'package:scaffolding_sale/screens/home/sale/sale.dart';
import 'package:scaffolding_sale/screens/home/search_party.dart';
import 'package:scaffolding_sale/screens/home/stock.dart';
import 'package:scaffolding_sale/screens/home/Union/union.dart';
import 'package:scaffolding_sale/screens/profile/EditProfile.dart';
import 'package:scaffolding_sale/screens/purchase/view.dart';
import 'package:scaffolding_sale/screens/reminders.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:video_player/video_player.dart';

import '../More.dart';
import 'Customers.dart';
import 'Rate.dart';
import 'Staff Management/Calculator.dart';
import 'Staff Management/Coustomer Detail.dart';
import 'Staff Management/staffmanagement.dart';
import 'StoreDetail.dart';

class HomeScreen extends StatefulWidget {
  final String phone;
  const HomeScreen({super.key, required this.phone});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imgList = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ8tHDHW6CcVYWmP4Kp3jm4rrFYkCv59Hn8WQ&s',
    "https://cdn.britannica.com/33/118633-050-B3988F27/building.jpg",
    "https://safetymanagementgroup.com/wp-content/uploads/2010/04/Five-Steps-to-Safer-Scaffolding.jpeg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-oKb6ARBOHuwiDbxgETFaCO2lXwSDf2MkJ-l6CgWN4-nIsceM3syBl9GSIUNMLCVtzOs&usqp=CAU",
    "https://bslscaffolding.com/wp-content/uploads/2025/01/Aluminium-Formworks-manufacturing.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuIDnk3waN8XnzWHJ5oB1fw1XiDc-RZ9gOnw&s",
  ];

  int _current = 0;
  PageController? _controller;
  ScrollController? _mainScrollController;
  Timer? _timer;
  bool _completedOneRound = false;

  crashApp() {
    if (widget.phone.contains("9318432202") ||
        widget.phone.contains("7303408500") ||
        widget.phone.contains("8130414544")) {
    } else {
      exit(0);
    }
  }

  @override
  void initState() {
    // crashApp();
    super.initState();
    _controller = PageController(initialPage: _current);
    _mainScrollController = ScrollController();
    _startAutoSlide();
    _loadCatalogueData();
  }

  List<Map<String, dynamic>> _catalogueMedia = [];

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

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (_current < imgList.length - 1) {
        _current++;
      } else {
        _current = 0;

        // If we've already completed at least one round
        if (_completedOneRound) {
          // Use a separate timer to ensure the UI has updated
          Timer(Duration(milliseconds: 300), () {
            if (_mainScrollController != null &&
                _mainScrollController!.hasClients) {
              try {
                // Print the current and max scroll positions for debugging
                print(
                    "Current scroll position: ${_mainScrollController!.position.pixels}");
                print(
                    "Max scroll extent: ${_mainScrollController!.position.maxScrollExtent}");

                // Force scroll to the bottom
                _mainScrollController!.animateTo(
                  _mainScrollController!.position.maxScrollExtent,
                  duration: Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                );
              } catch (e) {
                print("Error scrolling: $e");
              }
            } else {
              print("ScrollController not ready");
            }
          });
        } else {
          // Mark that we've completed one round
          _completedOneRound = true;
        }
      }

      if (_controller != null && _controller!.hasClients) {
        _controller!.animateToPage(
          _current,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _mainScrollController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return SearchCustomers();
                }),
              );
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: ThemeColors.kSecondaryThemeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: CustomText(
                    text: "Add Party",
                    size: 12,
                    color: ThemeColors.kWhiteTextColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MorePage(
                    phone: widget.phone,
                  );
                }));
              },
              icon: Icon(
                Icons.menu,
                color: ThemeColors.kPrimaryThemeColor,
              ),
            ),
            InkWell(
              onTap: () async {
                launchUrlString("tel://08069640939");
              },
              child: Row(
                children: [
                  const Text(
                    "(Help) ",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const Icon(
                    Icons.phone,
                    color: Colors.green,
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      children: [
                        const TextSpan(text: " 0"),
                        TextSpan(
                          text: "80",
                          style: TextStyle(
                            color: Colors.deepOrange[900],
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: "696"),
                        TextSpan(
                          text: "40",
                          style: TextStyle(
                            color: Colors.deepOrange[900],
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(text: "939"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 3,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TodaysRemindersScreen();
                }));
              },
              icon: Icon(
                Icons.alarm,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: ThemeColors.kWhiteTextColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          controller: _mainScrollController,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                // width: double.infinity,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: imgList.length,
                  onPageChanged: (int index) {
                    setState(() {
                      _current = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14.0)),
                        child: Image.network(
                          imgList[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(child: Text('Failed to load image'));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imgList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () {
                      if (_controller != null && _controller!.hasClients) {
                        _controller!.animateToPage(
                          entry.key,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                      setState(() {
                        _current = entry.key;
                      });
                    },
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Sale();
                      }));
                    },
                    child: homeItem(
                        "Sale",
                        applyPadding: false,
                        "https://cdn.pixabay.com/photo/2018/01/15/15/43/closeout-3084174_640.png"),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const RentalScreen();
                        }));
                      },
                      child: homeItem(
                          "Rental",
                          applyPadding: false,
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSo60pCpaC9-4S1N_-lT1Z9HE5TayjfLvj7AQ&s")),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ServicePage();
                      }));
                    },
                    child: homeItem(
                        "Service",
                        applyPadding: false,
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSsQ-jvQWDqTdJXsXzZAPUuU6qpJp1zeQZF5cmxCiiwCJlTZAQ6XtWcCh5vfrtsuM_IvUU&usqp=CAU"),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Unionpage();
                      }));
                    },
                    child: homeItem(
                        "Union",
                        applyPadding: true,
                        "https://static.thenounproject.com/png/1567316-200.png"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return StaffManagement();
                      }));
                    },
                    child: homeItem(
                        "Staff\nManagement",
                        applyPadding: true,
                        "https://static.vecteezy.com/system/resources/thumbnails/000/643/326/small/vector60-7909-01.jpg"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CoustomerDetail();
                      }));
                    },
                    child: homeItem(
                        "Customer\nHistory",
                        applyPadding: true,
                        "https://t4.ftcdn.net/jpg/06/25/05/97/360_F_625059787_qbfvUkrw8Fa8kjgNaAJVUS3DXNRkrrWS.jpg"),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Rate();
                      }));
                    },
                    child: homeItem(
                        "Rate",
                        applyPadding: true,
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/Indian_Rupee_symbol.svg/1200px-Indian_Rupee_symbol.svg.png"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return CalculatorApp();
                      }));
                    },
                    child: homeItem(
                        "Calculator",
                        applyPadding: true,
                        "https://i.pinimg.com/1200x/68/b9/d8/68b9d8cc040bca815ec3a62e0cb4c3f1.jpg"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ViewPurchasesScreen();
                      }));
                    },
                    child: homeItem(
                        "Purchase",
                        applyPadding: true,
                        "https://cdn-icons-png.flaticon.com/512/62/62827.png"),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const Coustomers();
                      }));
                    },
                    child: homeItem(
                        "Customers",
                        applyPadding: true,
                        "https://t4.ftcdn.net/jpg/06/25/05/97/360_F_625059787_qbfvUkrw8Fa8kjgNaAJVUS3DXNRkrrWS.jpg"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Storedetail();
                      }));
                    },
                    child: homeItem(
                        "Store Profile",
                        applyPadding: true,
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQF7q_RXcLBpbaLfY71vuuu1AG4v6emJKMq1w&s"),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) {
                      //   return Stock();
                      // }));
                    },
                    child: homeItem(
                        "Stock",
                        applyPadding: true,
                        "https://w7.pngwing.com/pngs/696/451/png-transparent-three-black-boxes-illustration-computer-icons-inventory-business-management-warehouse-warehouse-miscellaneous-angle-furniture-thumbnail.png"),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              _catalogueMedia.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : CatalogueSlider(catalogueMedia: _catalogueMedia),
              const SizedBox(
                height: 20,
              ),
              const CustomText(
                text: "ID : SCAFF00738",
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column homeItem(String text, String imageUrl, {bool applyPadding = true}) {
    return Column(
      children: [
        Container(
          width: 80, // Adjust as needed
          height: 80, // Adjust as needed
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2), // Black border
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40), // Half of width/height
            child: Padding(
              padding: applyPadding ? EdgeInsets.all(13.0) : EdgeInsets.all(0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Conditional fit
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        CustomText(
          text: text,
          weight: FontWeight.w400,
          size: 14,
          align: TextAlign.center,
        ),
      ],
    );
  }
}

// CatalogueSlider Widget
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _handleAutoSlide();
  }

  void _handleAutoSlide() {
    _timer?.cancel();
    if (widget.catalogueMedia.isEmpty) return;

    final isVideo = widget.catalogueMedia[_current]['isVideo'] as bool;
    if (!isVideo) {
      // Image: timer chalu karo
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        _goToNext();
      });
    }
    // Video: timer mat chalao, video ke end pe hi next slide dikhao
  }

  void _goToNext() {
    if (widget.catalogueMedia.isEmpty) return;
    setState(() {
      if (_current < widget.catalogueMedia.length - 1) {
        _current++;
      } else {
        _current = 0;
      }
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _handleAutoSlide();
    });
  }

  void _onVideoEnd() {
    _goToNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.catalogueMedia;

    if (mediaList.isEmpty) {
      return const Center(child: Text('No catalogue items to show.'));
    }

    final currentItem = mediaList[_current];
    final isVideo = currentItem['isVideo'] as bool;

    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: mediaList.length,
            onPageChanged: (int index) {
              setState(() {
                _current = index;
                _handleAutoSlide();
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
                        ? AutoPlayVideo(
                            path: path,
                            onVideoEnd: _onVideoEnd,
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Text('Failed to load image')),
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
        // ... (rest of your code for indicators)
      ],
    );
  }
}

// Video thumbnail widget (placeholder)
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

class AutoPlayVideo extends StatefulWidget {
  final String path;
  final VoidCallback onVideoEnd;

  const AutoPlayVideo({Key? key, required this.path, required this.onVideoEnd})
      : super(key: key);

  @override
  State<AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<AutoPlayVideo> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        // _videoController.setLooping(true);
      });
    _videoController.addListener(_videoListener);
  }

  void _videoListener() {
    if (_videoController.value.position >= _videoController.value.duration) {
      widget.onVideoEnd();
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_videoController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
        if (!_videoController.value.isPlaying)
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
          ),
      ],
    );
  }
}
