import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/auth/register/form.dart';
import 'package:scaffolding_sale/screens/auth/register/otherwidget.dart';
import 'package:scaffolding_sale/widgets/button.dart';

class CompanyDetailsPage extends StatefulWidget {
  final String phone;
  const CompanyDetailsPage({super.key, required this.phone});

  @override
  State<CompanyDetailsPage> createState() => _CompanyDetailsPageState();
}

class _CompanyDetailsPageState extends State<CompanyDetailsPage> {
  bool showStoreFields = false;
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController storePhoneController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();
  final TextEditingController storeEmailController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController otherDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BusinessDetailsWidget4(),
            if (showStoreFields) ...[
              _buildTextField(
                  controller: storePhoneController, label: "Store Phone"),
              _buildTextField(
                  controller: storeAddressController,
                  label: "Store Address",
                  maxlines: 4),
              _buildTextField(
                  controller: storeEmailController, label: "Store Email"),
              _buildTextField(controller: websiteController, label: "Website"),
              _buildTextField(
                  controller: otherDetailsController,
                  label: "Other Details",
                  maxlines: 4),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                onTap: () {
                  setState(() {
                    showStoreFields = true;
                  });
                },
                text: showStoreFields ? "Submit Store Details" : "Add Store",
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      int? maxlines}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 20, right: 20),
      child: TextField(
        controller: controller,
        maxLines: maxlines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
