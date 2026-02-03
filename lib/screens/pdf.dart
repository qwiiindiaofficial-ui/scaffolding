// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:scaffolding_sale/backend/models.dart';
import 'package:scaffolding_sale/companydetails.dart';
import 'package:scaffolding_sale/screens/challanhistory.dart' as history;
import 'package:scaffolding_sale/utils/pdfhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ChallanFormScreen extends StatefulWidget {
  final ChallanModel? initialChallan;
  final bool isNewChallan;

  const ChallanFormScreen({
    Key? key,
    this.initialChallan,
    this.isNewChallan = false,
  }) : super(key: key);

  @override
  State<ChallanFormScreen> createState() => _ChallanFormScreenState();
}

class _ChallanFormScreenState extends State<ChallanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late ChallanModel challan;
  bool withStamp = false;
  bool useBillingAsShipping = false;

  final TextEditingController billToMobileController = TextEditingController();
  final TextEditingController billToCompanyController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverMobileController =
      TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverMobileController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTerms();
    _loadCompanyDetails();

    challan = widget.initialChallan ?? ChallanModel();
    billToMobileController.text = challan.billToMobile;
    billToCompanyController.text = challan.billToCompany;
    receiverNameController.text = challan.contactPerson;
    receiverMobileController.text = challan.contactNo;
    driverNameController.text = challan.driverName;
    driverMobileController.text = challan.driverMobile;
    dateController.text = challan.date;
  }

  @override
  void dispose() {
    perPieceWeightControllers.values.forEach((c) => c.dispose());

    billToMobileController.dispose();
    billToCompanyController.dispose();
    receiverNameController.dispose();
    receiverMobileController.dispose();
    driverNameController.dispose();
    driverMobileController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanyDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      challan.companyName = prefs.getString('companyName') ?? '';
      challan.companyAddress = prefs.getString('companyAddress') ?? '';
      challan.companyGst = prefs.getString('companyGst') ?? '';
      List<String>? phoneList = prefs.getStringList('companyPhones');
      challan.companyPhone = phoneList?.join(', ') ?? '';
      challan.companyLogoPath = prefs.getString('companyLogoPath');
      challan.companyNameImagePath = prefs.getString('companyNameImagePath');
      challan.companyStampPath = prefs.getString('companyStampPath');
      challan.terms = prefs.getString('terms') ?? '';
      challan.isoNumber = prefs.getString('isoNumber') ?? '';
    });
  }

  Future<void> _pickContact(String type) async {
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        final fullContact = await FlutterContacts.getContact(contact.id);
        if (fullContact?.phones.isNotEmpty == true) {
          if (fullContact!.phones.length > 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select Phone Number'),
                  content: Container(
                    width: double.minPositive,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: fullContact.phones.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(fullContact.phones[index].number),
                          onTap: () {
                            String cleanNumber = fullContact
                                .phones[index].number
                                .replaceAll(RegExp(r'[^\d]'), '');
                            if (cleanNumber.length > 10) {
                              cleanNumber = cleanNumber
                                  .substring(cleanNumber.length - 10);
                            }
                            _updateContactInfo(
                              type,
                              cleanNumber,
                              "${fullContact.name.first} ${fullContact.name.last}",
                            );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            String cleanNumber = fullContact.phones.first.number
                .replaceAll(RegExp(r'[^\d]'), '');
            if (cleanNumber.length > 10) {
              cleanNumber = cleanNumber.substring(cleanNumber.length - 10);
            }
            _updateContactInfo(
              type,
              cleanNumber,
              "${fullContact.name.first} ${fullContact.name.last}",
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing contacts: $e')),
      );
    }
  }

  void _updateContactInfo(String type, String number, String name) {
    setState(() {
      switch (type) {
        case 'billTo':
          billToMobileController.text = number;
          billToCompanyController.text = name;
          challan.billToMobile = number;
          challan.billToCompany = name;
          break;
        case 'receiver':
          receiverMobileController.text = number;
          receiverNameController.text = name;
          challan.contactNo = number;
          challan.contactPerson = name;
          break;
        case 'driver':
          driverMobileController.text = number;
          driverNameController.text = name;
          challan.driverMobile = number;
          challan.driverName = name;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: Row(
            children: [
              Expanded(child: _buildChallanTypeSection()),
              _buildBillTypeSection(),
            ],
          ),
        ),
        title: InkWell(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.blue,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CompanyDetailsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.history,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => history.ChallanHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf,
              color: Colors.teal,
            ),
            onPressed: () async {
              _formKey.currentState!.save();
              bool? saveChallan = await generatePdf(
                context,
                challan: challan,
                withStamp: withStamp,
              );

              if (saveChallan != null && saveChallan) {
                // Save the challan
                await history.ChallanHistoryManager.saveChallan(challan);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challan saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challan not saved.'),
                    backgroundColor: Colors.grey,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildRentPeriodSection(),
              _buildBasicDetailsCard(),
              const SizedBox(height: 16),
              _buildBillToDetailsCard(),
              const SizedBox(height: 16),
              _buildShipToDetailsCard(),
              const SizedBox(height: 16),
              challan.billType == "Rent" || challan.billType == 'Service'
                  ? Container()
                  : _buildTransportDetailsCard(),
              const SizedBox(height: 16),
              challan.challanType == "Tax Invoice" && challan.billType == "Sale"
                  ? Container()
                  : _buildAreaSection(),
              const SizedBox(height: 16),
              challan.challanType == "Tax Invoice" &&
                      challan.billType == "Service"
                  ? Container()
                  : _buildItemsSection(),
              const SizedBox(height: 16),
              _buildOtherChargesSection(),
              const SizedBox(height: 16),
              challan.challanType.contains("Challan")
                  ? Container()
                  : _buildGstOptionsCard(),
              const SizedBox(height: 16),
              _buildStampControl(),
              const SizedBox(height: 16),
              challan.challanType == "Estimate" ||
                      challan.challanType == "Quotation"
                  ? _buildTerms()
                  : Container(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallanTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Document Type *',
            border: OutlineInputBorder(),
          ),
          value: challan.challanType,
          items: [
            'Outward Challan',
            'Inward Challan',
            'Tax Invoice',
            'Estimate',
            'Quotation'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              // challan.items.clear();
              challan.challanType = value ?? "Outward Challan";
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select document type';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildBillTypeSection() {
    if (!(challan.challanType == 'Tax Invoice' ||
        challan.challanType == 'Estimate' ||
        challan.challanType == 'Quotation')) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Bill Type:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: challan.billType,
              items: ['Sale', 'Rent', 'Service'].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  challan.billType = val!;
                  if (val == 'Sale') {
                    challan.fromDate = null;
                    challan.toDate = null;
                    challan.days = 0;
                    for (var item in challan.items) {
                      item.rentPerDay = '';
                      item.fromDate = null;
                      item.toDate = null;
                      item.days = 0;
                    }
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Date *',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    challan.date = date.toString().split(' ')[0];
                    dateController.text = challan.date;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: '${challan.challanType} No.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: challan.challanNo,
              onChanged: (value) => challan.challanNo = value,
            ),
          ],
        ),
      ),
    );
  }

  // Dummy history list
  final List<Map<String, String>> companyHistory = [
    {
      'company': 'aa Infaara',
      'mobile': '9876543210',
      'gst': 'GSTIN1234',
      'address': '123, aa Road, Delhi',
    },
    {
      'company': 'ABC Infra',
      'mobile': '9876543210',
      'gst': 'GSTIN1234',
      'address': '123, Main Road, Delhi',
    },
    {
      'company': 'XYZ Constructions',
      'mobile': '9123456780',
      'gst': 'GSTIN5678',
      'address': '456, Market, Mumbai',
    },
    {
      'company': 'PQR Builders',
      'mobile': '9988776655',
      'gst': 'GSTIN9999',
      'address': '789, Street, Pune',
    },
  ];

  Widget _buildBillToDetailsCard() {
    // Helper to filter suggestions

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill To Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Company Name with suggestion dropdown

            TextFormField(
              controller: billToCompanyController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                challan.billToCompany = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Mobile with suggestion dropdown

            TextFormField(
              controller: billToMobileController,
              maxLength: 10,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.contact_phone),
                  onPressed: () => _pickContact('billTo'),
                ),
                labelText: 'Mobile No.',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                challan.billToMobile = value;
              },
            ),

            const SizedBox(height: 16),

            // GST No. with suggestion dropdown

            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'GST No.',
                border: OutlineInputBorder(),
              ),
              initialValue: challan.billToGst,
              onChanged: (value) {
                challan.billToGst = value;
                // setStateSB(() {});
              },
            ),

            const SizedBox(height: 16),

            // Address with suggestion dropdown

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
              ),
              initialValue: challan.billToAddress,
              maxLines: 3,
              onChanged: (value) {
                challan.billToAddress = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  late TextEditingController _shippingAddressController;

  Widget _buildShipToDetailsCard() {
    _shippingAddressController =
        TextEditingController(text: challan.shipToAddress);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: useBillingAsShipping,
                  onChanged: (val) {
                    setState(() {
                      useBillingAsShipping = val!;
                      if (useBillingAsShipping) {
                        challan.shipToAddress = challan.billToAddress;
                        _shippingAddressController.text = challan.billToAddress;
                      }
                    });
                  },
                ),
                const Text('Use billing address as shipping address'),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Shipping Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              controller: _shippingAddressController,
              onChanged: (value) => challan.shipToAddress = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: receiverNameController,
              decoration: InputDecoration(
                labelText: 'Receiver Name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.contact_phone),
                  onPressed: () => _pickContact('receiver'),
                ),
              ),
              onChanged: (value) => challan.contactPerson = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLength: 10,
              controller: receiverMobileController,
              decoration: const InputDecoration(
                labelText: 'Receiver Mobile',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => challan.contactNo = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transport Details ${challan.billType}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'E-way Bill No.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: challan.ewayBillNo,
              onChanged: (value) => challan.ewayBillNo = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Vehicle No.',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              initialValue: challan.vehicleNumber,
              onChanged: (value) => challan.vehicleNumber = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: driverNameController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.contact_phone),
                  onPressed: () => _pickContact('driver'),
                ),
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => challan.driverName = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: driverMobileController,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Driver Mobile',
                border: OutlineInputBorder(),
                prefixText: '+91 ',
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) => challan.driverMobile = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Driving License No.',
                border: OutlineInputBorder(),
              ),
              initialValue: challan.drivingLicense,
              onChanged: (value) => challan.drivingLicense = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Areas',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Area'),
                  onPressed: () {
                    setState(() {
                      challan.areas.add(AreaModel());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challan.areas.length,
              itemBuilder: (context, index) => _buildAreaCard(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard(int index) {
    // Calculate total area and value
    double length = double.tryParse(challan.areas[index].length) ?? 0;
    double width = double.tryParse(challan.areas[index].width) ?? 0;
    double height = double.tryParse(challan.areas[index].height) ?? 0;
    double rate = double.tryParse(challan.areas[index].rate) ?? 0;

    double totalArea = length * width * height;
    double totalValue = totalArea * rate;
    if (challan.billType == 'Rent') {
      totalValue *= challan.areas[index].days;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              value: challan.areas[index].areaname.isNotEmpty
                  ? challan.areas[index].areaname
                  : null,
              items: const [
                DropdownMenuItem(
                  value: 'Scaffolding Material',
                  child: Text('Scaffolding Material'),
                ),
                DropdownMenuItem(
                  value: 'Scaffolding Material Area',
                  child: Text('Scaffolding Material Area'),
                ),
                DropdownMenuItem(
                  value: 'Scaffolding Area',
                  child: Text('Scaffolding Area'),
                ),
                DropdownMenuItem(
                  value: 'Scaffolding Fixing',
                  child: Text('Scaffolding Fixing'),
                ),
                DropdownMenuItem(
                  value: 'Scaffolding Closing',
                  child: Text('Scaffolding Closing'),
                ),
                DropdownMenuItem(
                  value: 'Fixing And Closing',
                  child: Text('Scaffolding Fixing And Closing'),
                ),
                DropdownMenuItem(
                  value: 'Scaffolding Set',
                  child: Text('Scaffolding Set'),
                ),
                DropdownMenuItem(
                  value: 'Scaffolding Wheel Set',
                  child: Text('Scaffolding Wheel Set'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  challan.areas[index].areaname = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'HSN Code',
                border: OutlineInputBorder(),
              ),
              initialValue: challan.areas[index].hsnCode,
              onChanged: (value) {
                setState(() {
                  challan.areas[index].hsnCode = value;
                });
              },
            ),
            if (challan.billType == "Service") ...[
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'From Date',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                controller: TextEditingController(
                  text: challan.areas[index].fromDate != null
                      ? DateFormat('dd-MM-yyyy')
                          .format(challan.areas[index].fromDate!)
                      : '',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        challan.areas[index].fromDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      challan.areas[index].fromDate = date;
                      _calculateAreaDays(index);
                    });
                  }
                },
              ),
            ],
            if (challan.billType == 'Rent') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: challan.areas[index].fromDate != null
                            ? DateFormat('dd-MM-yyyy')
                                .format(challan.areas[index].fromDate!)
                            : '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              challan.areas[index].fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            challan.areas[index].fromDate = date;
                            _calculateAreaDays(index);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: challan.areas[index].toDate != null
                            ? DateFormat('dd-MM-yyyy')
                                .format(challan.areas[index].toDate!)
                            : '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              challan.areas[index].toDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            challan.areas[index].toDate = date;
                            _calculateAreaDays(index);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: challan.areas[index].days.toString(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Length',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: challan.areas[index].length,
                    onChanged: (value) {
                      setState(() {
                        challan.areas[index].length = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: challan.areas[index].height,
                    onChanged: (value) {
                      setState(() {
                        challan.areas[index].height = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: challan.areas[index].width,
                    onChanged: (value) {
                      setState(() {
                        challan.areas[index].width = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Area (cubic ft)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          totalArea == 0.0 ? "" : totalArea.toStringAsFixed(2),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      challan.areas.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    initialValue: challan.areas[index].rate,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        challan.areas[index].rate = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    readOnly: true,
                    controller: TextEditingController(
                      text: totalValue == 0.0
                          ? ""
                          : totalValue.toStringAsFixed(0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _calculateAreaDays(int index) {
    var area = challan.areas[index];
    if (area.fromDate != null && area.toDate != null) {
      area.days = area.toDate!.difference(area.fromDate!).inDays + 1;
    }
  }

  Map<int, TextEditingController> perPieceWeightControllers = {};

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                challan.items.isEmpty
                    ? ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                        onPressed: () {
                          setState(() {
                            challan.items.add(ChallanItem());
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challan.items.length,
              itemBuilder: (context, index) => _buildItemCard(index),
            ),
            challan.items.isEmpty
                ? Container()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    onPressed: () {
                      setState(() {
                        challan.items.add(ChallanItem());
                        int newIndex = challan.items.length - 1;
                        perPieceWeightControllers[newIndex] =
                            TextEditingController(
                                text: challan.items[newIndex].perPieceWeight);
                        totalWeightControllers[newIndex] =
                            TextEditingController(
                                text: challan.items[newIndex].totalWeight);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Map<int, TextEditingController> totalWeightControllers = {};
  bool _isUpdating = false; // Add this flag in your State class

  Widget _buildItemCard(int index) {
    bool isRent =
        challan.challanType == "Tax Invoice" && challan.billType == 'Rent';

    // Helper to safely parse double
    double _parseDouble(String? value) {
      if (value == null || value.isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }

    void _updateTotalWeight(int idx) {
      if (_isUpdating) return;
      final qty = _parseDouble(challan.items[idx].quantity);
      final perPieceWt = _parseDouble(challan.items[idx].perPieceWeight);
      if (qty > 0 && perPieceWt > 0) {
        _isUpdating = true;
        final totalWt = (qty * perPieceWt).toStringAsFixed(3);
        challan.items[idx].totalWeight = totalWt;
        totalWeightControllers[idx]?.text = totalWt;
        _isUpdating = false;
      }
    }

// _updatePerPieceWeight me controller update karo:
    void _updatePerPieceWeight(int idx) {
      if (_isUpdating) return;
      final qty = _parseDouble(challan.items[idx].quantity);
      final totalWt = _parseDouble(challan.items[idx].totalWeight);
      if (qty > 0 && totalWt > 0) {
        _isUpdating = true;
        final perPiece = (totalWt / qty).toStringAsFixed(3);
        challan.items[idx].perPieceWeight = perPiece;
        perPieceWeightControllers[idx]?.text = perPiece;
        _isUpdating = false;
      }
    }

    final controller = perPieceWeightControllers[index] ??
        TextEditingController(text: challan.items[index].perPieceWeight);

    // Store controller to map
    perPieceWeightControllers[index] = controller;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      challan.items.removeAt(index);
                      perPieceWeightControllers[index]?.dispose();
                      perPieceWeightControllers.remove(index);

                      // Rebuild controllers map keys because indices shifted
                      final newControllers = <int, TextEditingController>{};
                      for (int i = 0; i < challan.items.length; i++) {
                        if (perPieceWeightControllers.containsKey(i)) {
                          newControllers[i] = perPieceWeightControllers[i]!;
                        } else {
                          newControllers[i] = TextEditingController(
                              text: challan.items[i].perPieceWeight);
                        }
                      }
                      perPieceWeightControllers = newControllers;
                    });
                  },
                ),
              ],
            ),
            if (isRent) ...[
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'From Date',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: challan.items[index].fromDate != null
                            ? DateFormat('dd-MM-yyyy')
                                .format(challan.items[index].fromDate!)
                            : '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              challan.items[index].fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setState(() {
                            challan.items[index].fromDate = date;

                            // Auto-set toDate to last day of selected month
                            challan.items[index].toDate =
                                DateTime(date.year, date.month + 1, 0);

                            _calculateItemDays(index);
                            _calculateItemTotal(index);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: challan.items[index].toDate != null
                            ? DateFormat('dd-MM-yyyy')
                                .format(challan.items[index].toDate!)
                            : '',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              challan.items[index].toDate ?? DateTime.now(),
                          firstDate: challan.items[index].fromDate ??
                              DateTime(2000), // 👈 yahan change
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          if (challan.items[index].fromDate != null &&
                              date.isBefore(challan.items[index].fromDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("To Date cannot be before From Date."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            challan.items[index].toDate = date;
                            _calculateItemDays(index);
                            _calculateItemTotal(index);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: challan.items[index].days.toString(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                border: OutlineInputBorder(),
              ),
              initialValue: challan.items[index].itemName,
              onChanged: (value) {
                challan.items[index].itemName = value;
                _calculateItemTotal(index);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: challan.items[index].quantity,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      challan.items[index].quantity = value;
                      _updateTotalWeight(index);
                      _updatePerPieceWeight(index);
                      _calculateItemTotalWeight(index);
                      _calculateItemTotal(index);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'HSN Code',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: challan.items[index].hsnCode,
                          onChanged: (value) =>
                              challan.items[index].hsnCode = value,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isRent) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Weight per piece (kg)',
                        border: OutlineInputBorder(),
                      ),
                      controller: controller,
                      onChanged: (value) {
                        challan.items[index].perPieceWeight = value;
                        _updateTotalWeight(index);
                        _calculateItemTotalWeight(index);
                        _calculateItemTotal(index);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Total Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: challan.items[index].totalWeight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        challan.items[index].totalWeight = value;
                        _updatePerPieceWeight(index);
                        _calculateItemTotalWeight(index);
                        _calculateItemTotal(index);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Rate per kg',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      initialValue: challan.items[index].rate,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        challan.items[index].rate = value;
                        _calculateItemTotal(index);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isRent) ...[
              const SizedBox(height: 16),
              TextFormField(
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Rent per Day',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                initialValue: challan.items[index].rentPerDay,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  challan.items[index].rentPerDay = value;
                  _calculateItemTotal(index);
                },
              ),
              const SizedBox(height: 16),
            ],
            challan.challanType.contains("Outward")
                ? SizedBox(
                    width: 16,
                  )
                : Container(),
            challan.challanType.contains("Outward")
                ? TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Rent per Day',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    initialValue: challan.items[index].rentPerDay,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      challan.items[index].rentPerDay = value;
                      _calculateItemTotal(index);
                    },
                  )
                : Container(),
            challan.challanType.contains("Challan")
                ? SizedBox(
                    height: 16,
                  )
                : Container(),
            TextFormField(
              key: UniqueKey(),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹',
              ),
              readOnly: true,
              initialValue: challan.items[index].amount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherChargesSection() {
    double totalOtherCharges = challan.otherCharges.fold(
      0,
      (sum, charge) => sum + charge.amount,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Other Charges',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Charge'),
                  onPressed: () {
                    setState(() {
                      challan.otherCharges.add(OtherChargeModel());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: challan.otherCharges.length,
              itemBuilder: (context, index) => _buildOtherChargeCard(index),
            ),
            if (challan.otherCharges.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total Other Charges: ₹${totalOtherCharges.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOtherChargeCard(int index) {
    var charge = challan.otherCharges[index];
    final List<String> unitOptions = ['Kgs', 'Pcs', 'Nos'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: charge.hsnController,
                    decoration: const InputDecoration(
                      labelText: 'HSN Code',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => charge.hsnCode = value,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      challan.otherCharges.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: charge.descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => charge.description = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  // flex: 2,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: charge.qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      charge.quantity = double.tryParse(value) ?? 0;

                      charge.amount = charge.quantity * charge.rate;
                      charge.amtController.text =
                          charge.amount.toStringAsFixed(2);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: charge.unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: unitOptions.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        charge.unit = value ?? 'Kgs';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Expanded(
                  // flex: 3,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: charge.rateController,
                    decoration: const InputDecoration(
                      labelText: 'Rate',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      charge.rate = double.tryParse(value) ?? 0;
                      charge.amount = charge.quantity * charge.rate;
                      charge.amtController.text =
                          charge.amount.toStringAsFixed(2);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // flex: 3,
                  child: TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: charge.amtController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixText: '₹',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      charge.amount = double.tryParse(value) ?? 0;
                      if (charge.quantity != 0) {
                        charge.rate = charge.amount / charge.quantity;
                        charge.rateController.text =
                            charge.rate.toStringAsFixed(2);
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _calculateItemTotalWeight(int index) {
    final item = challan.items[index];

    final quantity = double.tryParse(item.quantity ?? '0') ?? 0;
    final weightPerPiece = double.tryParse(item.perPieceWeight ?? '0') ?? 0;

    final totalWeight = quantity * weightPerPiece;
    item.totalWeight = totalWeight.toString();
  }

  void _calculateTotalWeight(ChallanItem item) {
    final qty = double.tryParse(item.quantity) ?? 0;
    final weight = double.tryParse(item.perPieceWeight) ?? 0;
    setState(() {
      item.totalWeight = (qty * weight).toStringAsFixed(2);
    });
  }

  Widget _buildGstOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GST Options',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('CGST-SGST'),
                    value: 'CGST-SGST',
                    groupValue: challan.gstType,
                    onChanged: (value) {
                      setState(() {
                        challan.gstType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('IGST'),
                    value: 'IGST',
                    groupValue: challan.gstType,
                    onChanged: (value) {
                      setState(() {
                        challan.gstType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('No GST'),
                    value: 'No GST',
                    groupValue: challan.gstType,
                    onChanged: (value) {
                      setState(() {
                        challan.gstType = value!;
                      });
                    },
                  ),
                ),
                if (challan.gstType != 'No GST')
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'GST Rate (%)',
                          border: const OutlineInputBorder(),
                          suffixText:
                              challan.gstType == 'CGST-SGST' ? '18%' : '%',
                        ),
                        initialValue: challan.gstType == 'CGST-SGST'
                            ? '9+9'
                            : challan.gstRate.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (value) {
                          setState(() {
                            challan.gstRate = double.tryParse(value) ?? 18;
                          });
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStampControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Include Digital Stamp:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Switch(
              value: withStamp,
              onChanged: (bool value) {
                setState(() {
                  withStamp = value;
                });
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Terms And Conditions:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  challan.terms = value;
                });
              },
              maxLines: 4,
              controller: TextEditingController(
                  text: challan.challanType == "Estimate"
                      ? estimateTerms
                      : quotationTerms),
              decoration: InputDecoration(
                labelText: 'Terms And Conditions:',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateItemDays(int index) {
    var item = challan.items[index];
    if (item.fromDate != null && item.toDate != null) {
      item.days = item.toDate!.difference(item.fromDate!).inDays + 1;
    }
  }

  String quotationTerms = "";
  String estimateTerms = "";

  loadTerms() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    quotationTerms = preferences.getString('quotationTerms') ??
        'Default Quotation Terms: xxx';
    estimateTerms =
        preferences.getString('estimateTerms') ?? 'Default Estimate Terms: xxx';
    setState(() {});
  }

  void _calculateItemTotal(int index) {
    setState(() {
      var item = challan.items[index];
      if (challan.billType == 'Rent') {
        double quantity = double.tryParse(item.quantity) ?? 0;
        double rentPerDay = double.tryParse(item.rentPerDay) ?? 0;
        item.amount = (quantity * rentPerDay * item.days).toStringAsFixed(2);
      } else {
        double quantity = double.tryParse(item.quantity) ?? 0;
        double weight = double.tryParse(item.perPieceWeight) ?? 0;
        double rate = double.tryParse(item.rate) ?? 0;
        item.totalWeight = (quantity * weight).toStringAsFixed(2);
        item.amount = (quantity * weight * rate).toStringAsFixed(2);
      }
    });
  }
}

// Helper function to format numbers without trailing zeros
String formatNumber(dynamic value) {
  if (value == null) return '';
  if (value is int) return value.toString();
  if (value is double) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }
  return value.toString();
}

Future<bool?> generatePdf(
  BuildContext context, {
  required ChallanModel challan,
  required bool withStamp,
}) async {
  try {
    final pdf = await _createPdfDocument();

    final headersAndRows = _generateHeadersAndRows(challan);

    final totals = _calculateTotals(challan);

    final gstData = _calculateGst(totals.subtotal, challan);

    final headerAndAddress = await buildPdfHeaderAndAddressSection(
      shipToName: challan.contactPerson,
      challanType: challan.challanType,
      billToName: challan.billToCompany,
      billToAddress: challan.billToAddress,
      billToGst: challan.billToGst,
      billToMobile: challan.billToMobile,
      shipToAddress: challan.shipToAddress,
      shipToContact: challan.contactNo,
      challanNo: challan.challanNo,
      date: challan.date,
      billtype: challan.challanType == "Tax Invoice" ? challan.billType : null,
    );

    final footerSection =
        await buildPdfFooterSection(challan.challanType, withStamp);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    final String bankDetails = preferences.getString('bankDetails') ?? 'N/A';

    pdf.addPage(
      _buildPdfPage(
        headersAndRows.headers,
        headersAndRows.rows,
        headerAndAddress,
        footerSection,
        challan,
        totals,
        gstData,
        bankDetails,
      ),
    );

    final output = await getTemporaryDirectory();
    final file =
        File('${output.path}/${challan.challanType}${challan.challanNo}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF generated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Challan?'),
          content: const Text('Do you want to save this challan to history?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Error generating PDF: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to generate PDF: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    return null;
  }
}

Future<pw.Document> _createPdfDocument() async {
  return pw.Document(
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.quicksandRegular(),
      bold: await PdfGoogleFonts.quicksandMedium(),
      icons: await PdfGoogleFonts.materialIcons(),
      fontFallback: [
        await PdfGoogleFonts.notoEmojiBold(),
      ],
    ),
  );
}

class _HeadersAndRows {
  final List<String> headers;
  final List<List<String>> rows;
  _HeadersAndRows(this.headers, this.rows);
}

_HeadersAndRows _generateHeadersAndRows(ChallanModel challan) {
  List<String> headers = [];
  List<List<String>> itemRows = [];

  if (['Tax Invoice', 'Estimate', 'Quotation'].contains(challan.challanType)) {
    if (challan.billType == 'Rent') {
      headers = [
        'Item Name',
        'Qty',
        'From Date',
        'To Date',
        'Days',
        'Rent/Day',
        'Amount'
      ];
      List<double> qtyList = [];
      List<int> amountList = [];
      List<double> rentPerDayList = [];
      List<int> daysList = [];

      for (var item in challan.items) {
        itemRows.add([
          item.itemName,
          num.parse(item.quantity).toInt().toString(),
          DateFormat('dd-MM-yyyy').format(item.fromDate ?? DateTime.now()),
          DateFormat('dd-MM-yyyy').format(item.toDate ?? DateTime.now()),
          item.days.toString(),
          item.rentPerDay,
          item.amount,
        ]);
        qtyList.add(double.tryParse(item.quantity) ?? 0.0);
        amountList.add(int.tryParse(item.amount) ?? 0);
        rentPerDayList.add(double.tryParse(item.rentPerDay) ?? 0.0);
        daysList.add(item.days);
      }

      for (var area in challan.areas) {
        String areaDesc =
            '${area.areaname} (${area.length}*${area.height}*${area.width})';
        int areaAmount = ((double.tryParse(area.length) ?? 0.0) *
                (double.tryParse(area.width) ?? 0.0) *
                (double.tryParse(area.height) ?? 0.0) *
                (double.tryParse(area.rate) ?? 0.0))
            .toInt();
        if (challan.billType == 'Rent') {
          areaAmount *= area.days;
        }
        itemRows.add([
          areaDesc,
          ((double.tryParse(area.width) ?? 0.0) *
                  (double.tryParse(area.height) ?? 0.0) *
                  (double.tryParse(area.length) ?? 0.0))
              .toString(),
          DateFormat('dd-MM-yyyy').format(area.fromDate ?? DateTime.now()),
          DateFormat('dd-MM-yyyy').format(area.toDate ?? DateTime.now()),
          area.days.toString(),
          area.rate,
          areaAmount.toStringAsFixed(2),
        ]);
        amountList.add(areaAmount);
      }

      for (var c in challan.otherCharges) {
        itemRows.add([
          c.description,
          c.quantity?.toStringAsFixed(2) ?? '',
          c.hsnCode,
          '',
          '',
          c.rate?.toStringAsFixed(2) ?? '',
          c.amount?.toStringAsFixed(2) ?? '',
        ]);
        amountList.add(c.amount.toInt());
      }

      // Add subtotal row
      List<String> totalsRow = [];
      totalsRow.add('Subtotal');
      totalsRow
          .add(formatNumber(qtyList.fold(0.0, (double a, double b) => a + b)));
      totalsRow.add('');
      totalsRow.add('');
      totalsRow.add('');
      double totalRentPerDayTimesDays = 0.0;
      for (int i = 0; i < challan.items.length; i++) {
        totalRentPerDayTimesDays +=
            (double.tryParse(challan.items[i].rentPerDay) ?? 0.0) * daysList[i];
      }
      totalsRow.add(formatNumber(totalRentPerDayTimesDays));
      totalsRow.add(formatNumber(amountList.fold(0, (int a, int b) => a + b)));
      itemRows.add(totalsRow);
    } else if (challan.billType == 'Service') {
      headers = [
        'Item Name',
        'Qty',
        'HSN\nCode',
        'Date',
        'Rate',
        'Amount',
      ];
      List<double> qtyList = [];
      List<int> amountList = [];
      List<int> areaQtyList = [];

      for (var area in challan.areas) {
        String areaDesc =
            '${area.areaname} (${area.length}*${area.height}*${area.width})';
        int areaAmount = ((double.tryParse(area.length) ?? 0.0) *
                (double.tryParse(area.width) ?? 0.0) *
                (double.tryParse(area.height) ?? 0.0) *
                (double.tryParse(area.rate) ?? 0.0))
            .toInt();
        int areaQty = (num.parse(area.length).toInt() *
                num.parse(area.width) *
                num.parse(area.height))
            .toInt();
        itemRows.add([
          areaDesc,
          areaQty.toString(),
          area.hsnCode,
          DateFormat('dd-MM-yyyy').format(area.fromDate ?? DateTime.now()),
          area.rate,
          areaAmount.toStringAsFixed(0),
        ]);
        amountList.add(areaAmount);
        areaQtyList.add(areaQty);
      }

      for (var c in challan.otherCharges) {
        itemRows.add([
          c.description,
          c.quantity?.toStringAsFixed(0) ?? '',
          c.hsnCode,
          '',
          c.rate.toStringAsFixed(0) ?? '',
          c.amount.toStringAsFixed(0) ?? '',
        ]);
        amountList.add(c.amount.toInt() ?? 0);
      }

      List<String> totalsRow = [];
      totalsRow.add('Subtotal');
      int totalAreaQty = areaQtyList.fold(0, (sum, qty) => sum + qty);
      totalsRow.add(formatNumber(totalAreaQty));
      totalsRow.add('');
      totalsRow.add('');
      totalsRow.add('');
      totalsRow.add(formatNumber(amountList.fold(0, (int a, int b) => a + b)));
      itemRows.add(totalsRow);
    } else if (challan.billType == 'Sale') {
      headers = [
        'Item Name',
        'Qty',
        'HSN Code',
        'Rate',
        'Amount',
      ];
      itemRows = [];

      for (var item in challan.items) {
        itemRows.add([
          item.itemName,
          item.quantity,
          item.hsnCode ?? '',
          item.rate ?? '',
          item.amount,
        ]);
      }

      for (var area in challan.areas) {
        String areaDesc =
            '${area.areaname} (${area.length}*${area.height}*${area.width})';
        double areaAmount = (double.tryParse(area.length) ?? 0.0) *
            (double.tryParse(area.width) ?? 0.0) *
            (double.tryParse(area.height) ?? 0.0) *
            (double.tryParse(area.rate) ?? 0.0);
        itemRows.add([
          areaDesc,
          '',
          area.hsnCode ?? '',
          area.rate ?? '',
          areaAmount.toStringAsFixed(2),
        ]);
      }

      for (var c in challan.otherCharges) {
        itemRows.add([
          c.description,
          c.quantity?.toString() ?? '',
          c.hsnCode ?? '',
          c.rate?.toString() ?? '',
          c.amount?.toStringAsFixed(2) ?? '',
        ]);
      }

      double totalAmount = challan.items
          .fold(0, (sum, item) => sum + (double.tryParse(item.amount) ?? 0));
      double areaTotal = challan.areas.fold(
          0,
          (sum, area) =>
              sum +
              ((double.tryParse(area.length) ?? 0.0) *
                  (double.tryParse(area.width) ?? 0.0) *
                  (double.tryParse(area.height) ?? 0.0) *
                  (double.tryParse(area.rate) ?? 0.0)));
      double otherChargesTotal =
          challan.otherCharges.fold(0, (sum, c) => sum + (c.amount ?? 0.0));
      double subtotal = totalAmount + areaTotal + otherChargesTotal;

      itemRows.add(['Subtotal', '', '', '', subtotal.toStringAsFixed(2)]);
    }
  } else if (challan.challanType.contains("Challan")) {
    bool isOutwardChallan = challan.challanType == 'Outward Challan';
    bool isInwardChallan = challan.challanType == 'Inward Challan';

    headers = [
      'Item Name',
      'Qty',
      'HSN\nCode',
      'Weight\nper pc',
      'Total\nWeight',
      if (isOutwardChallan) 'Rent/day',
      if (isOutwardChallan || isInwardChallan) 'Rate/kg',
      'Amount',
    ];

    List<double> qtyList = [];
    List<double> weightPerPcList = [];
    List<double> totalWeightList = [];
    List<int> amountList = [];
    List<double> rentPerDayList = [];
    List<double> ratePerKgList = [];

    itemRows = [];

    for (var item in challan.items) {
      qtyList.add(double.tryParse(item.quantity) ?? 0.0);
      weightPerPcList.add(double.tryParse(item.perPieceWeight) ?? 0.0);
      totalWeightList.add(double.tryParse(item.totalWeight) ?? 0.0);
      amountList.add(int.tryParse(item.amount) ?? 0);
      rentPerDayList.add(double.tryParse(item.rentPerDay) ?? 0.0);
      ratePerKgList.add(double.tryParse(item.rate ?? '0.0') ?? 0.0);

      List<String> row = [
        item.itemName,
        num.parse(item.quantity).toInt().toString(),
        item.hsnCode,
        item.perPieceWeight,
        "${item.totalWeight} Kgs",
      ];

      if (isOutwardChallan) {
        row.add(item.rentPerDay);
      }

      if (isOutwardChallan || isInwardChallan) {
        row.add(item.rate ?? '');
      }

      row.add(item.amount);
      itemRows.add(row);
    }

    for (var area in challan.areas) {
      String areaDesc =
          '${area.areaname} (${area.length}*${area.height}*${area.width})';
      double areaAmount = (double.tryParse(area.length) ?? 0.0) *
          (double.tryParse(area.width) ?? 0.0) *
          (double.tryParse(area.height) ?? 0.0) *
          (double.tryParse(area.rate) ?? 0.0);

      if (challan.billType == 'Rent') {
        areaAmount *= area.days;
      }

      List<String> row = [
        areaDesc,
        ((double.tryParse(area.width) ?? 0.0) *
                (double.tryParse(area.height) ?? 0.0) *
                (double.tryParse(area.length) ?? 0.0))
            .toInt()
            .toString(),
        DateFormat('dd-MM-yyyy').format(area.fromDate ?? DateTime.now()),
        DateFormat('dd-MM-yyyy').format(area.toDate ?? DateTime.now()),
        area.days.toString(),
      ];

      if (isOutwardChallan) {
        row.add(area.rate);
      }

      if (isOutwardChallan || isInwardChallan) {
        row.add('');
      }

      row.add(areaAmount.toInt().toString());
      itemRows.add(row);
    }

    for (var c in challan.otherCharges) {
      List<String> row = [
        c.description,
        c.quantity?.toString() ?? '',
        c.hsnCode,
        '',
        '',
      ];

      if (isOutwardChallan) {
        row.add(c.rate.toString());
      }

      if (isOutwardChallan || isInwardChallan) {
        row.add('');
      }

      row.add(c.amount.toInt().toString());
      itemRows.add(row);
    }

    List<String> totalsRow = [
      'Subtotal',
      formatNumber(qtyList.fold(0.0, (a, b) => a + b)),
      '',
      formatNumber(weightPerPcList.fold(0.0, (a, b) => a + b)),
      formatNumber(totalWeightList.fold(0.0, (a, b) => a + b)),
    ];

    if (isOutwardChallan) {
      totalsRow.add(formatNumber(rentPerDayList.fold(0.0, (a, b) => a + b)));
    }

    if (isOutwardChallan || isInwardChallan) {
      totalsRow.add(formatNumber(ratePerKgList.fold(0.0, (a, b) => a + b)));
    }

    totalsRow.add(formatNumber(amountList.fold(0, (a, b) => a + b)));
    itemRows.add(totalsRow);
  }

  return _HeadersAndRows(headers, itemRows);
}

class _Totals {
  final double totalAmount;
  final int areaTotal;
  final double otherChargesTotal;
  final double subtotal;

  _Totals({
    required this.totalAmount,
    required this.areaTotal,
    required this.otherChargesTotal,
    required this.subtotal,
  });
}

_Totals _calculateTotals(ChallanModel challan) {
  double totalAmount = 0.0;
  for (var item in challan.items) {
    totalAmount += double.tryParse(item.amount) ?? 0.0;
  }

  int areaTotal = 0;
  for (var area in challan.areas) {
    double areaAmount = (double.tryParse(area.length) ?? 0.0) *
        (double.tryParse(area.width) ?? 0.0) *
        (double.tryParse(area.height) ?? 0.0) *
        (double.tryParse(area.rate) ?? 0.0);
    if (challan.billType == 'Rent') {
      areaAmount *= area.days;
    }
    areaTotal += areaAmount.toInt();
  }

  double otherChargesTotal = 0.0;
  if (challan.otherCharges != null && challan.otherCharges.isNotEmpty) {
    otherChargesTotal = challan.otherCharges.fold(
      0.0,
      (sum, charge) => sum + (charge.amount ?? 0.0),
    );
  }

  double subtotal = totalAmount + areaTotal + otherChargesTotal;

  return _Totals(
    totalAmount: totalAmount,
    areaTotal: areaTotal,
    otherChargesTotal: otherChargesTotal,
    subtotal: subtotal,
  );
}

class _GstData {
  final double gstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double grandTotal;
  final double roundOff;

  _GstData({
    required this.gstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.grandTotal,
    required this.roundOff,
  });
}

_GstData _calculateGst(double subtotal, ChallanModel challan) {
  double gstAmount = 0.0;
  double cgstAmount = 0.0;
  double sgstAmount = 0.0;
  double grandTotal = subtotal;
  double roundOff = grandTotal.roundToDouble() - grandTotal;

  if (['Tax Invoice', 'Estimate', 'Quotation'].contains(challan.challanType) &&
      challan.gstType != 'No GST') {
    if (challan.gstType == 'CGST/SGST') {
      cgstAmount = subtotal * (challan.gstRate / 2 / 100);
      sgstAmount = subtotal * (challan.gstRate / 2 / 100);
      gstAmount = cgstAmount + sgstAmount;
    } else {
      gstAmount = subtotal * (challan.gstRate / 100);
    }
    grandTotal = subtotal + gstAmount + roundOff;
  }

  return _GstData(
    gstAmount: gstAmount,
    cgstAmount: cgstAmount,
    sgstAmount: sgstAmount,
    grandTotal: grandTotal,
    roundOff: roundOff,
  );
}

pw.Page _buildPdfPage(
  List<String> headers,
  List<List<String>> rows,
  pw.Widget headerAndAddress,
  pw.Widget footerSection,
  ChallanModel challan,
  _Totals totals,
  _GstData gstData,
  String bankDetails,
) {
  return pw.MultiPage(
    margin: const pw.EdgeInsets.all(20),
    pageFormat: PdfPageFormat.a4,
    header: (pw.Context context) {
      return headerAndAddress;
    },
    build: (pw.Context context) {
      return [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey),
          columnWidths: {
            for (var i = 0; i < headers.length; i++)
              i: const pw.IntrinsicColumnWidth(),
          },
          children: [
            pw.TableRow(
              children: headers
                  .map((header) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Center(
                        child: pw.Text(header,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      )))
                  .toList(),
            ),
            ...rows.map((row) {
              return pw.TableRow(
                children: row.map((cell) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child:
                        pw.Text(cell, style: const pw.TextStyle(fontSize: 8)),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
        pw.SizedBox(height: 2),
        if (['Tax Invoice', 'Estimate', 'Quotation']
                .contains(challan.challanType) &&
            challan.gstType != 'No GST')
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  height: 55,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'Bank Details:\n$bankDetails',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ),
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 100,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      padding: const pw.EdgeInsets.all(2),
                      child: pw.Text(
                          'Subtotal: ${formatNumber(totals.subtotal)}',
                          style: const pw.TextStyle(fontSize: 8)),
                    ),
                    if (challan.gstType == 'CGST-SGST')
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 100,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                                'CGST ${challan.gstRate / 2}%: ${formatNumber(gstData.gstAmount / 2)}',
                                style: const pw.TextStyle(fontSize: 8)),
                          ),
                          pw.Container(
                            width: 100,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Text(
                                'SGST ${challan.gstRate / 2}%: ${formatNumber(gstData.gstAmount / 2)}',
                                style: const pw.TextStyle(fontSize: 8)),
                          ),
                        ],
                      )
                    else
                      pw.Container(
                        width: 100,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                            'GST ${challan.gstRate}%: ${formatNumber(gstData.gstAmount)}',
                            style: const pw.TextStyle(fontSize: 8)),
                      ),
                    pw.Container(
                      width: 100,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5),
                      ),
                      padding: const pw.EdgeInsets.all(2),
                      child: pw.Text(
                          'Round Off: ${formatNumber(gstData.roundOff)}',
                          style: const pw.TextStyle(fontSize: 8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        pw.SizedBox(height: 12),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "In Words: ${convertNumberToWords(gstData.grandTotal.round())} rupees only",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: PdfColors.black),
              ),
              pw.Spacer(),
              pw.Text(
                "Grand Total: ${gstData.grandTotal.toStringAsFixed(2)} ",
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                    color: PdfColors.blue900),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        challan.challanType == "Tax Invoice" && challan.billType == "Sale" ||
                challan.challanType.contains("Challan")
            ? pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                ),
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.TableRow(
                      verticalAlignment: pw.TableCellVerticalAlignment.middle,
                      decoration: const pw.BoxDecoration(),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'E-way Bill No',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Vehicle Number',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Driver Name',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Driver Mobile',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Driving License',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(challan.ewayBillNo,
                              style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(challan.vehicleNumber,
                              style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(challan.driverName,
                              style: const pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.UrlLink(
                            destination: 'tel:${challan.driverMobile}',
                            child: pw.Text(
                              challan.driverMobile,
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.blue,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(challan.drivingLicense,
                              style: const pw.TextStyle(fontSize: 8)),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : pw.Container(),
        pw.SizedBox(height: 10),
        footerSection
      ];
    },
  );
}

String convertNumberToWords(int number) {
  // Aap yahan koi bhi logic ya package use kar sakte hain
  // For demo, main ek simple version de raha hoon
  // Production ke liye package use karna better hai
  final units = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen"
  ];
  final tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety"
  ];

  if (number == 0) return "Zero";
  if (number < 20) return units[number];
  if (number < 100) {
    return tens[number ~/ 10] +
        (number % 10 != 0 ? " ${units[number % 10]}" : "");
  }
  if (number < 1000) {
    return "${units[number ~/ 100]} Hundred${number % 100 != 0 ? " ${convertNumberToWords(number % 100)}" : ""}";
  }
  if (number < 100000) {
    return "${convertNumberToWords(number ~/ 1000)} Thousand${number % 1000 != 0 ? " ${convertNumberToWords(number % 1000)}" : ""}";
  }
  if (number < 10000000) {
    return "${convertNumberToWords(number ~/ 100000)} Lakh${number % 100000 != 0 ? " ${convertNumberToWords(number % 100000)}" : ""}";
  }
  return "${convertNumberToWords(number ~/ 10000000)} Crore${number % 10000000 != 0 ? " ${convertNumberToWords(number % 10000000)}" : ""}";
}
