import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/phonenumber.dart';
import 'package:scaffolding_sale/screens/auth/register/myprofile.dart';
import 'package:scaffolding_sale/screens/home/users.dart';
import 'package:scaffolding_sale/screens/test/login.dart';
import 'package:scaffolding_sale/screens/viewallyourpost.dart';
import 'package:scaffolding_sale/transporter/screens/list_transporters_screen.dart';
import 'package:share_plus/share_plus.dart';

import 'Activities.dart';
import 'All Bills.dart';
import 'All Payment.dart';
import 'App Setting.dart';
import 'Daily Backup.dart';
import 'Daily Entries.dart';
import 'Expenese.dart';
import 'GstPage.dart';
import 'Transportaion.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      // Aap yahan aur bhi options customize kar sakte hain
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Player"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(
                controller: _chewieController!,
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Loading Video...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

// Video ke data ko hold karne ke liye ek simple class
class VideoInfo {
  final String title;
  final String thumbnailUrl;
  final String videoUrl;

  VideoInfo({
    required this.title,
    required this.thumbnailUrl,
    required this.videoUrl,
  });
}

class VideoGalleryScreen extends StatelessWidget {
  VideoGalleryScreen({super.key});

  // Dummy data (aap isko server se bhi laa sakte hain)
  final List<VideoInfo> _videos = [
    VideoInfo(
      title: 'Big Buck Bunny',
      thumbnailUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Big_Buck_Bunny_thumbnail_vlc.png/1200px-Big_Buck_Bunny_thumbnail_vlc.png',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    VideoInfo(
      title: 'Elephants Dream',
      thumbnailUrl: 'https://i.ytimg.com/vi/dv_gOBi8Wpk/maxresdefault.jpg',
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
    VideoInfo(
      title: 'For Bigger Blazes',
      thumbnailUrl: 'https://i.ytimg.com/vi/Dr9ZPAp_vro/maxresdefault.jpg',
      videoUrl:
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    ),
    VideoInfo(
      title: 'For Bigger Escape',
      thumbnailUrl: 'https://i.ytimg.com/vi/120244199/maxresdefault.jpg',
      videoUrl:
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Videos'),
        // backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Ek row mein 2 video
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 16 / 12, // Thumbnail ka aspect ratio
          ),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final video = _videos[index];
            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return VideoPlayerScreen(videoUrl: video.videoUrl);
                }));
              },
              child: Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error));
                            },
                          ),
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              color: Colors.white70,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        video.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final String phone;
  const MorePage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'More',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProfileScreen(
                  phone: phone,
                );
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'My Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const Activites();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.edit_note,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Activities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ListTransportersScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Transporter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DailyEntries();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.calendar_today,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Daily Entries',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AppSetting();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.settings,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'App Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return VideoGalleryScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.play_circle,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'App Videos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BillsPage();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.book,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'All Bill (2025-26)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return DailyBackups();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.backup,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Daily Backups',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AllPayment();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.credit_card,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'All Payments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AllChallans();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.receipt_long,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'All Challan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return GSTR1();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.receipt,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'GST R1',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return GSTR2B();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.receipt,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'GST R2B',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return GSTR3B();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.receipt,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'GST R3B',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ExpenseListScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.currency_rupee,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) {
          //       return Transportion();
          //     }));
          //   },
          //   child: const ListTile(
          //     leading: CircleAvatar(
          //       radius: 30,
          //       child: Icon(
          //         Icons.emoji_transportation_outlined,
          //         size: 30,
          //         color: Colors.black,
          //       ),
          //     ),
          //     title: Text(
          //       'Transportion',
          //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          //     ),
          //     trailing: Icon(Icons.arrow_forward_ios),
          //   ),
          // ),
          // const Divider(),
          GestureDetector(
            onTap: () {
              SharePlus.instance.share(
                  ShareParams(text: 'check out my App https://example.com'));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.share,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Share',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return UsersScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.people,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'App Users',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TermsAndConditionsScreen();
              }));
            },
            leading: CircleAvatar(
              radius: 30,
              child: Icon(
                Icons.privacy_tip,
                size: 30,
                color: Colors.black,
              ),
            ),
            title: Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TermsAndConditionsScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.notes,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Terms & Conditions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return TermsAndConditionsScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.help_outline,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Help',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PhoneNumberScreen();
              }));
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.switch_account,
                  size: 30,
                  color: Colors.black,
                ),
              ),
              title: Text(
                'Switch Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
          GestureDetector(
            onTap: () {
              _showLogoutDialog(context);
            },
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(
                  Icons.logout_outlined,
                  size: 30,
                  color: Colors.red,
                ),
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.red),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          // "Cancel" button
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              // Dialog ko band karne ke liye
              Navigator.of(context).pop();
            },
          ),
          // "Logout" button
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red), // Ise red color de rahe hain
            ),
            onPressed: () {
              // YAHAN APNA LOGOUT LOGIC DAALEIN
              // Jaise ki user session clear karna aur login screen par bhejna.

              // Pehle dialog ko band karein
              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PhoneNumberScreen();
              }));

              // Phir login screen par navigate karein (example)
              // Navigator.of(context).pushAndRemoveUntil(
              //   MaterialPageRoute(builder: (context) => LoginScreen()),
              //   (Route<dynamic> route) => false
              // );
            },
          ),
        ],
      );
    },
  );
}

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms & Conditions'),
        backgroundColor:
            Colors.teal, // आप अपने ऐप की थीम के अनुसार रंग बदल सकते हैं
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last updated: September 07, 2025',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 16),
            Text(
              'Please read these terms and conditions carefully before using Our Service.',
            ),
            SizedBox(height: 24),
            _buildSectionTitle(context, '1. Interpretation and Definitions'),
            _buildParagraph(
                'The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.'),
            SizedBox(height: 24),
            _buildSectionTitle(context, '2. Acknowledgment'),
            _buildParagraph(
                'These are the Terms and Conditions governing the use of this Service and the agreement that operates between You and the Company. These Terms and Conditions set out the rights and obligations of all users regarding the use of the Service.'),
            _buildParagraph(
                'Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms and Conditions. These Terms and Conditions apply to all visitors, users and others who access or use the Service.'),
            SizedBox(height: 24),
            _buildSectionTitle(context, '3. User Accounts'),
            _buildParagraph(
                'When You create an account with Us, You must provide Us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of Your account on Our Service.'),
            _buildParagraph(
                'You are responsible for safeguarding the password that You use to access the Service and for any activities or actions under Your password, whether Your password is with Our Service or a Third-Party Social Media Service.'),
            SizedBox(height: 24),
            _buildSectionTitle(context, '4. Termination'),
            _buildParagraph(
                'We may terminate or suspend Your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if You breach these Terms and Conditions.'),
            _buildParagraph(
                'Upon termination, Your right to use the Service will cease immediately. If You wish to terminate Your account, You may simply discontinue using the Service.'),
            SizedBox(height: 24),
            _buildSectionTitle(
                context, '5. Changes to These Terms and Conditions'),
            _buildParagraph(
                'We reserve the right, at Our sole discretion, to modify or replace these Terms at any time. If a revision is material We will make reasonable efforts to provide at least 30 days\' notice prior to any new terms taking effect. What constitutes a material change will be determined at Our sole discretion.'),
            SizedBox(height: 24),
            _buildSectionTitle(context, '6. Contact Us'),
            _buildParagraph(
                'If you have any questions about these Terms and Conditions, You can contact us:'),
            SizedBox(height: 8),
            Text('- By email: contact@example.com'),
            Text('- By phone number: +91 12345 67890'),
          ],
        ),
      ),
    );
  }

  // शीर्षक बनाने के लिए एक हेल्पर विजेट
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  // पैराग्राफ बनाने के लिए एक हेल्पर विजेट
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(height: 1.5),
      ),
    );
  }
}
