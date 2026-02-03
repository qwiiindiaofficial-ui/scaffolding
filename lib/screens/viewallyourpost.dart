// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/screens/profile/MyProfile.dart';
import 'package:translator/translator.dart';
import 'package:scaffolding_sale/utils/colors.dart';
import 'package:scaffolding_sale/widgets/text.dart';
import '../../../widgets/textfield.dart';
import 'home/Union/NewStaff.dart';

// https://html.dynamiclayers.net/dl/xoom/templates/demo-2/image/index.html#

class ViewAllYourPost extends StatefulWidget {
  const ViewAllYourPost({super.key});

  @override
  _ViewAllYourPostState createState() => _ViewAllYourPostState();
}

class _ViewAllYourPostState extends State<ViewAllYourPost> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  String _selectedLanguage = 'en';
  final translator = GoogleTranslator();

  final Map<String, String> _languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Spanish': 'es',
    'French': 'fr',
    // Add more languages as needed
  };

  void _translateText() async {
    if (_textController.text.isNotEmpty) {
      var translation = await translator.translate(
        _textController.text,
        to: _selectedLanguage,
      );
      setState(() {
        _translatedText = translation.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ThemeColors.kPrimaryThemeColor,
        title: CustomText(
          text: "Your Post",
          color: ThemeColors.kWhiteTextColor,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const NewStaff();
              }));
            },
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: ThemeColors.kSecondaryThemeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Center(
                  child: CustomText(
                    text: "Add",
                    size: 12,
                    color: ThemeColors.kWhiteTextColor,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.calendar_today_rounded, size: 32),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              RegisterField(
                hint: "Search Area..",
                controller: TextEditingController(),
              ),
              const SizedBox(height: 8),
              /*  DropdownButton<String>(
                value: _selectedLanguage,
                items: _languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter text to translate',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _translateText,
                child: Text('Translate'),
              ),
              SizedBox(height: 16),
              if (_translatedText.isNotEmpty)
                Text('Translated: $_translatedText'),*/
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              height: 44,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ThemeColors.kPrimaryThemeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyProfile(
                                              ticketName: "ALPHABET HEIGHT"),
                                        ),
                                      );
                                    },
                                    child: Image.asset("images/person.png"),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyProfile(
                                              ticketName: "ALPHABET HEIGHT"),
                                        ),
                                      );
                                    },
                                    child: const CustomText(
                                      text: "ALPHABET HEIGHT",
                                      size: 16,
                                      color: Colors.white,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 34,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 6),
                                      child: Center(
                                        child: CustomText(
                                          text: "1234567",
                                          size: 13,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 260,
                                  child: CustomText(
                                    text: 'Type here....',
                                    color: Colors.grey,
                                    size: 13,
                                    weight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          /*Padding(
                            padding: const EdgeInsets.only(left: 120, right: 10),
                            child: Row(
                              children: [
                                const SizedBox(width: 162),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return const Slip();
                                        }),
                                      );
                                    },
                                    child: Container(
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: ThemeColors.kSecondaryThemeColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: CustomText(
                                          text: 'Send',
                                          align: TextAlign.center,
                                          color: Colors.white,
                                          size: 13,
                                          weight: FontWeight.w500,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),*/
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
