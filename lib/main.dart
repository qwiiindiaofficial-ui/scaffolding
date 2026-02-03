import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffolding_sale/backend/supabase_service.dart';
import 'package:scaffolding_sale/controllers/app_controller.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/home/home.dart';
import 'package:scaffolding_sale/screens/splash.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> downloadAndOpenNewMethod(bool isStamp) async {
  final String pdfUrl =
      isStamp ? "https://hobbeeme.com/pdf.pdf" : "https://hobbeeme.com/r.pdf";
  launchUrlString(pdfUrl);

  try {} catch (e) {
    print("Error: $e");
  }
}

Future<void> downloadAndOpenPDF() async {
  const String pdfUrl = "https://hobbeeme.com/r.pdf";
  // launchUrlString(pdfUrl);
  // OpenFilex.open(pdfUrl);

  try {
    // Get the directory to save the file
    // Directory dir = await getApplicationDocumentsDirectory();
    // String filePath = "${dir.path}/service.pdf";
    // OpenFilex.open(pdfUrl);
    // OpenFilex.open(filePath);

    // Download the file
    // FileDownloaderFlutter fileDownloaderFlutter = FileDownloaderFlutter();
    // await fileDownloaderFlutter.urlFileSaver(
    //     url: pdfUrl, fileName: "service.pdf");

    // Open the downloaded file
  } catch (e) {
    print("Error downloading or opening file: $e");
  }
}

Future<void> showDownloadOptions(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "Download Pdf",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text("Download With Stamp"),
            onTap: () {
              Navigator.pop(context);
              downloadAndOpenNewMethod(true);
            },
          ),
          ListTile(
            leading: Icon(Icons.cancel, color: Colors.red),
            title: Text("Download Without Stamp"),
            onTap: () {
              Navigator.pop(context);
              downloadAndOpenNewMethod(false);
            },
          ),
        ]),
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Initializing Supabase...');
    await SupabaseService.initialize();
    print('Supabase initialized successfully');

    print('Initializing AppController...');
    Get.put(AppController());
    print('AppController initialized successfully');
  } catch (e) {
    print('Failed to initialize: $e');
  }

  runApp(
    const SafeArea(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Scaffolding & Shuttering App',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: ThemeColors.kPrimaryThemeColor,
          scaffoldBackgroundColor: ThemeColors.kWhiteTextColor,
          fontFamily: 'Roboto', // A clean, modern font

          // App Bar Theme
          appBarTheme: AppBarTheme(
            backgroundColor: ThemeColors.kPrimaryThemeColor,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Card Theme
          // cardTheme: CardTheme(
          //   elevation: 1,
          //   color: Colors.white,
          //   surfaceTintColor: Colors.white,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12.0),
          //   ),
          // ),

          // Input Decoration Theme (for text fields)
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  BorderSide(color: ThemeColors.kPrimaryThemeColor, width: 2.0),
            ),
            labelStyle: const TextStyle(color: Colors.black),
          ),

          // Text Theme
          textTheme: const TextTheme(
            titleLarge:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.black, height: 1.5),
          ),

          // Stepper Theme
          colorScheme: ColorScheme.fromSeed(
            seedColor: ThemeColors.kPrimaryThemeColor,
            primary: ThemeColors.kPrimaryThemeColor,
            background: ThemeColors.kPrimaryThemeColor,
          ).copyWith(surface: Colors.white),

          // Button Themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.kPrimaryThemeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: ThemeColors.kPrimaryThemeColor,
            ),
          ),
        ),
        home: SplashScreen());
  }
}

Future<void> launchPDF() async {
  downloadAndOpenPDF();
}
