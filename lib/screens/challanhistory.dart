import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/backend/models.dart';
import 'package:scaffolding_sale/screens/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChallanHistoryScreen extends StatefulWidget {
  const ChallanHistoryScreen({super.key});

  @override
  _ChallanHistoryScreenState createState() => _ChallanHistoryScreenState();
}

class _ChallanHistoryScreenState extends State<ChallanHistoryScreen> {
  List<ChallanModel> _history = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterType = 'All';
  final _dateFormat = DateFormat('dd-MM-yyyy');

  Future<void> _pickContact() async {
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
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing contacts: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await ChallanHistoryManager.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading history: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  List<ChallanModel> get filteredHistory {
    return _history.where((challan) {
      final matchesSearch = challan.challanNo
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          challan.billToCompany
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          challan.billToMobile
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterType == 'All' || challan.challanType == _filterType;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _deleteChallan(ChallanModel challan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Challan'),
        content: Text('Are you sure you want to delete this challan?\n\n'
            'Challan No: ${challan.challanNo}\n'
            'Company: ${challan.billToCompany}\n'
            'Mobile: ${challan.billToMobile}'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ChallanHistoryManager.deleteChallan(challan.challanNo);
        setState(() {
          _history.removeWhere((item) => item.challanNo == challan.challanNo);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Challan deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete challan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All History'),
        content: Text('Are you sure you want to delete all challans?\n'
            'This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ChallanHistoryManager.clearHistory();
        setState(() {
          _history.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('History cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challan History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: const [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All History'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear_all') _clearAllHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: _pickContact,
                          icon: Icon(Icons.contact_page)),
                      hintText: 'Search by challan no, company or mobile',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _filterType,
                        items: [
                          'All',
                          'Outward Challan',
                          'Inward Challan',
                          'Tax Invoice',
                          'Estimate',
                          'Quotation'
                        ]
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _filterType = value!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No history found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final challan = filteredHistory[index];
                          return Dismissible(
                            key: Key(challan.challanNo),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Challan'),
                                  content: Text(
                                      'Are you sure you want to delete this challan?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.red),
                                      child: Text('Delete'),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) => _deleteChallan(challan),
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${challan.challanNo}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getChallanTypeColor(
                                            challan.challanType),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        challan.challanType,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      'Date: ${challan.date}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Company: ${challan.billToCompany}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Mobile: ${challan.billToMobile}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    if (challan.totalAmount > 0)
                                      Text(
                                        'Amount: ₹${challan.totalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.copy, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChallanFormScreen(
                                              initialChallan: challan,
                                              isNewChallan: true,
                                            ),
                                          ),
                                        );
                                      },
                                      tooltip: 'Copy Challan',
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.picture_as_pdf,
                                          color: Colors.red),
                                      onPressed: () => generatePdf(
                                        context,
                                        challan: challan,
                                        withStamp: false,
                                      ),
                                      tooltip: 'Generate PDF',
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteChallan(challan),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getChallanTypeColor(String type) {
    switch (type) {
      case 'Outward Challan':
        return Colors.blue;
      case 'Inward Challan':
        return Colors.green;
      case 'Tax Invoice':
        return Colors.purple;
      case 'Estimate':
        return Colors.orange;
      case 'Quotation':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class ChallanHistoryManager {
  static const String _storageKey = 'challan_history';

  /// Save or update a challan in history
  static Future<void> saveChallan(ChallanModel challan) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_storageKey) ?? [];

    // Remove existing challan with same challanNo if exists
    history.removeWhere((jsonStr) {
      try {
        final map = jsonDecode(jsonStr);
        return map['challanNo'] == challan.challanNo;
      } catch (_) {
        return false;
      }
    });

    // Add new challan JSON string
    history.add(jsonEncode(challan.toMap()));

    await prefs.setStringList(_storageKey, history);
  }

  /// Get all challan history as List<ChallanModel>
  static Future<List<ChallanModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_storageKey) ?? [];

    List<ChallanModel> result = [];
    for (var challanJson in history) {
      try {
        final decoded = jsonDecode(challanJson);
        if (decoded is Map<String, dynamic>) {
          result.add(ChallanModel.fromMap(decoded));
        }
      } catch (e) {
        // Skip corrupted entries
        print('Skipping corrupted entry in history: $e');
      }
    }

    // Optional: sort by date descending if your ChallanModel has a DateTime field
    result.sort((a, b) {
      // Assuming challan.date is a String in 'yyyy-MM-dd' or ISO format
      DateTime dateA = DateTime.tryParse(a.date) ?? DateTime(1970);
      DateTime dateB = DateTime.tryParse(b.date) ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    return result;
  }

  /// Delete a challan by challanNo
  static Future<void> deleteChallan(String challanNo) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_storageKey) ?? [];

    history.removeWhere((jsonStr) {
      try {
        final map = jsonDecode(jsonStr);
        return map['challanNo'] == challanNo;
      } catch (_) {
        return false;
      }
    });

    await prefs.setStringList(_storageKey, history);
  }

  /// Clear all challan history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
