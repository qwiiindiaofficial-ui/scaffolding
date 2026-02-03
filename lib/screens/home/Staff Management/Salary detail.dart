import 'package:flutter/material.dart';


class SalarySlipScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Salary Slip',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Salary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Staff Count',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹ 0.00',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 490,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),Text("₹ 0.00")
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
            _buildEarningsItem('Basic', '₹ 0.00'),
            Divider(),
            _buildEarningsItem('Bonus', '₹ 0.00'),
            Divider(),
            _buildEarningsItem('Overtime', '₹ 0.00'),
            Divider(),
            _buildEarningsItem('Other Allowance', '₹ 0.00'),
            Divider(),
            _buildEarningsItem('Workbasis', '₹ 0.00'),
            Divider(),
            _buildDeductionsItem('Employer PF Contribution', '₹ 0.00'),
            Divider(),
            _buildDeductionsItem('Employer ESI Contribution', '₹ 0.00'),
            Divider(),
            _buildDeductionsItem('Admin EDLI charges', '₹ 0.00'),
            Divider(),
            _buildDeductionsItem('Employer LWF', '₹ 0.00'),
            Divider(),
            SizedBox(height: 20.0),

            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 490,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Deductions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),Text("₹ 0.00")
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsItem(String title, String amount) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDeductionsItem(String title, String amount) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}