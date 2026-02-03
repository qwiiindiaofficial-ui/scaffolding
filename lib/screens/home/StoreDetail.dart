import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/BankDetail.dart';
import 'package:scaffolding_sale/screens/Catalogue.dart';
import 'package:scaffolding_sale/screens/Review.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/Calculator.dart';
import 'package:scaffolding_sale/screens/home/Staff%20Management/SalarySlip.dart';
import 'package:scaffolding_sale/screens/home/rental/select_terms.dart';
import 'package:scaffolding_sale/screens/home/users.dart';

import '../StoreDetail.dart';

class Storedetail extends StatefulWidget {
  @override
  _StoredetailState createState() => _StoredetailState();
}

class _StoredetailState extends State<Storedetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Store Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => StoreDetail()));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Store Details",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        //   SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Review()));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Review",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        //  SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Bankdetail()));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Bank Details",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        //   SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Catalogue()));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Catalogue",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        // SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TermsSelectionScreen(editable: true);
                  }));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Agreement",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        // SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TermsSelectionScreen(editable: true);
                  }));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Privacy Policy",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        //  SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TermsSelectionScreen(editable: true);
                  }));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Terms And Conditions",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        // SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return UsersScreen();
                  }));
                },
                child: Container(
                  width: 510,
                  height: 46,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Manage Users",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                        // SizedBox(width: 198,),
                        Icon(Icons.arrow_forward_ios_sharp)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
