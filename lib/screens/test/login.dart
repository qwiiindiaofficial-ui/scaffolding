import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage()));
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60), // Adjust for padding at the top

              // App Logo (Placeholder, replace with the real image)
              Image.asset(
                'images/logo.png', // Replace with your logo asset
                height: 80,
              ),

              SizedBox(height: 20),

              // Title
              Text(
                'Log in',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 5),

              // Subtitle
              Text(
                'Please log in with your phone number.\nIf you forget your password, please contact customer service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 20),

              // "Log in with phone" header
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.phone_iphone_outlined,color: Colors.redAccent,),
                      Text(
                        'Log in with phone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Phone number field
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone number",
                  labelStyle: TextStyle(color: Colors.redAccent),
                  hintText: "+91 Please enter the phone number",
                  hintStyle:TextStyle(color: Colors.redAccent) ,
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Password field
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  hintStyle:TextStyle(color: Colors.redAccent) ,
                  labelStyle: TextStyle(color: Colors.redAccent),
                  prefixIcon: Icon(Icons.lock),

                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Remember password checkbox
              Row(
                children: [
                  Checkbox(

                      checkColor: Colors.white,
                      activeColor: Colors.redAccent,
                      value: true, onChanged: (value) {}),
                  Text('Remember password')
                ],
              ),

              SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 170),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text('Log in', style: TextStyle(color: Colors.white,fontSize: 18)),
              ),

              SizedBox(height: 10),

              // Register Button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 170),
                  side: BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
              ),

              SizedBox(height: 40),

              // Bottom icons: Forgot Password and Customer Service
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.redAccent),
                      Text('Forgot password')
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.headset_mic_outlined, color: Colors.redAccent),
                      Text('Customer Service')
                    ],
                  ),
                ],
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
