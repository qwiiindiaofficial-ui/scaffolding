import 'dart:math';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppService {
  static void sendOTP(String phone, String otp) async {
    String url =
        "http://hindit.co.in/API/pushsms.aspx?loginID=T1Techcanopus&password=tech1234&mobile=${phone}&text=$otp is your OTP to register. DO NOT share with anyone. The OTP expires in 10 mins. TECHCANOPUS&senderid=TECNPS&route_id=3&Unicode=0&IP=x.x.x.x&Template_id=1707171101520604654";

    try {
      final response = await http.get(
        Uri.parse(
          url,
        ),
      );

      print(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "OTP Sent Successfully");
      } else {
        Fluttertoast.showToast(msg: "Failed To Send OTP");
        // Handle error
      }
    } catch (error) {
      // Handle error
      print('Error: $error');
    }
  }

  String generateOTP() {
    Random random = Random();
    // Generate a random 6-digit number
    int otp = random.nextInt(900000) + 100000;
    return otp.toString();
  }

  Future<String?> getPhoneNumber() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("phone");
  }
}
