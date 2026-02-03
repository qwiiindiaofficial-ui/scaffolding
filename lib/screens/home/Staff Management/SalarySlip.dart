import 'package:flutter/material.dart';

import 'Salary detail.dart';

class SalarySlip extends StatefulWidget {
  SalarySlip({Key? key}) : super(key: key);

  @override
  _SalarySlipState createState() => _SalarySlipState();
}

class _SalarySlipState extends State<SalarySlip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
        title: Text(
          "Salary Slip",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total CTC',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildRow('Monthly', '₹ 0.00/month'),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildRow('Daily', '₹ 0.00/ day'),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildRow('Hourly', '₹ 0.00/hour'),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 24),
            Text(
              'Salary Calculations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildCalculationRow(
              'Total Salary',
              'Check',
              primaryButtonColor: Colors.blue,
              firstAction: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context)=>
                        SalarySlipScreen()));
              },
              firstButton: 'Show Details >>',
              secondaryButton: null,
              secondaryAction: null,
              thirdAction: null,
              thirdButton: null,
            ),
            SizedBox(height: 16),
            _buildCalculationRow(
              'Pending Amount',
              'Check',
              primaryButtonColor: Colors.green,
              firstButton: null,
              firstAction: null,
              secondaryButton: 'Payment History',
              secondaryAction: () {},
              thirdAction: (){},
              thirdButton: 'Salary',
            ),
            SizedBox(height: 16),
            _buildCalculationRow(
              'Advance Paid',
              'Check',
              primaryButtonColor: Colors.red,
              firstButton: null,
              firstAction: null,
              secondaryButton: 'Payment History',
              secondaryAction: () {},
              thirdAction: (){},
              thirdButton: 'Enter Amount',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculationRow(
      String title,
      String buttonText, {
        required Color primaryButtonColor,
        String? secondaryButton,
        Function? secondaryAction,
        String? thirdButton,
        Function? thirdAction,
        String? firstButton,
        Function? firstAction,

      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 80,),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(buttonText,style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryButtonColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                      ),
                      if (firstButton != null)
                      TextButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>SalarySlipScreen()));}, child: Text("Show Details>>",
                        style: TextStyle(color: Colors.blue),                          ))
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (thirdButton != null)
                    Container(
                      width: 200,
                      height: 46,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(thirdButton,style: TextStyle(fontSize: 16),
                            ),
                          ),

                        ],
                      ),
                    ),
                  SizedBox(width: 10,),
                  if (secondaryButton != null)
                    Container(
                      width: 150,
                      height: 46,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(secondaryButton,style: TextStyle(fontSize: 16),
                            ),
                          ),

                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
