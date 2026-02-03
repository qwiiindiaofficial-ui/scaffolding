import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/screens/home/rental/tabs/all.dart';
import 'package:scaffolding_sale/screens/profile/EditProfile.dart';
import 'package:scaffolding_sale/screens/purchase/add.dart';
import 'package:scaffolding_sale/screens/purchase/detailscreen.dart';
import 'package:scaffolding_sale/screens/purchase/ledger.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:scaffolding_sale/screens/purchase/pdf.dart';
import 'package:scaffolding_sale/screens/purchase/service.dart';
import 'package:scaffolding_sale/screens/purchase/select_party.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewPurchasesScreen extends StatefulWidget {
  const ViewPurchasesScreen({super.key});

  @override
  State<ViewPurchasesScreen> createState() => _ViewPurchasesScreenState();
}

class _ViewPurchasesScreenState extends State<ViewPurchasesScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  Set<String> _closedAccounts = {}; // Store closed account names

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('What would you like to add?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                title: const Text('Add Purchase'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        SelectPartyScreen(transactionType: 'purchase'),
                  ));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.blue),
                title: const Text('Add Payment'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        SelectPartyScreen(transactionType: 'payment'),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeAccount(String partyName) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Close Account'),
          content: Text(
              'Are you sure you want to close the account for "$partyName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _closedAccounts.add(partyName);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account closed for $partyName'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Close Account'),
            ),
          ],
        );
      },
    );
  }

  void _reopenAccount(String partyName) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Reopen Account'),
          content: Text(
              'Are you sure you want to reopen the account for "$partyName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _closedAccounts.remove(partyName);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account reopened for $partyName'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Reopen Account'),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseOptions(BuildContext context, Purchase purchase) {
    final isClosed = _closedAccounts.contains(purchase.partyName);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text('View Details'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PurchaseDetailScreen(purchase: purchase),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('View as PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchasePDFView(purchase: purchase),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Colors.teal),
                title: Text('View Party Ledger'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartyLedgerScreen(
                        partyName: purchase.partyName,
                      ),
                    ),
                  );
                },
              ),
              Divider(),
              if (!isClosed) ...[
                ListTile(
                  leading: Icon(Icons.shopping_cart, color: Colors.teal),
                  title: Text('Add Purchase'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPurchaseScreen(
                            party: Party(
                                name: purchase.partyName,
                                address: purchase.hsnCode,
                                gst: purchase.grandTotal.toString(),
                                mobile: purchase.invoiceNo)),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment, color: Colors.blue),
                  title: Text('Add Payment'),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewPayment(
                                party: Party(
                                    name: purchase.partyName,
                                    address: purchase.hsnCode,
                                    gst: purchase.igst.toString(),
                                    mobile: purchase.invoiceNo),
                              )),
                    );
                  },
                ),
              ],
              Divider(),
              ListTile(
                leading: Icon(
                  isClosed ? Icons.lock_open : Icons.lock,
                  color: isClosed ? Colors.green : Colors.red,
                ),
                title: Text(isClosed ? 'Reopen Account' : 'Close Account'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isClosed) {
                    _reopenAccount(purchase.partyName);
                  } else {
                    _closeAccount(purchase.partyName);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDuesOptions(BuildContext context, PartyDueSummary summary) {
    final isClosed = _closedAccounts.contains(summary.partyName);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.account_balance_wallet, color: Colors.teal),
                title: Text('View Ledger'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartyLedgerScreen(
                        partyName: summary.partyName,
                      ),
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  isClosed ? Icons.lock_open : Icons.lock,
                  color: isClosed ? Colors.green : Colors.red,
                ),
                title: Text(isClosed ? 'Reopen Account' : 'Close Account'),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isClosed) {
                    _reopenAccount(summary.partyName);
                  } else {
                    _closeAccount(summary.partyName);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search party name...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
              : const Text('Purchases & Dues'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Purchase History'),
              Tab(text: 'Due Payments'),
              Tab(text: 'Closed Accounts'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return EditProfile();
            }));
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<void>(
          stream: _purchaseService.dataStream,
          builder: (context, snapshot) {
            final allPurchases = _purchaseService.purchases;
            final allDues = _purchaseService.getPartyDues();

            // Filter purchases - exclude closed accounts
            final activePurchases = allPurchases
                .where((p) => !_closedAccounts.contains(p.partyName))
                .toList();

            // Filter dues - exclude closed accounts
            final activeDues = allDues
                .where((d) => !_closedAccounts.contains(d.partyName))
                .toList();

            // Get closed accounts data
            final closedPurchases = allPurchases
                .where((p) => _closedAccounts.contains(p.partyName))
                .toList();

            final closedDues = allDues
                .where((d) => _closedAccounts.contains(d.partyName))
                .toList();

            // Apply search filter
            final filteredPurchases = _searchQuery.isEmpty
                ? activePurchases
                : activePurchases
                    .where(
                        (p) => p.partyName.toLowerCase().contains(_searchQuery))
                    .toList();

            final filteredDues = _searchQuery.isEmpty
                ? activeDues
                : activeDues
                    .where(
                        (d) => d.partyName.toLowerCase().contains(_searchQuery))
                    .toList();

            final filteredClosedDues = _searchQuery.isEmpty
                ? closedDues
                : closedDues
                    .where(
                        (d) => d.partyName.toLowerCase().contains(_searchQuery))
                    .toList();

            return TabBarView(
              children: [
                _buildPurchaseList(filteredPurchases),
                _buildDuesList(filteredDues),
                _buildClosedAccountsList(filteredClosedDues),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPurchaseList(List<Purchase> purchases) {
    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? "No purchases found"
                  : "No results for '$_searchQuery'",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: const Icon(Icons.shopping_bag, color: Colors.teal),
            ),
            title: Text(
              purchase.partyName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${DateFormat.yMMMd().format(purchase.date)} • Inv: ${purchase.invoiceNo}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📞 Call Icon
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () {
                    // Add your call action here
                  },
                ),

                // 💬 WhatsApp Icon
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.whatsapp,
                      color: Colors.green, size: 24),
                  onPressed: () {
                    final number = "";
                    final whatsappUrl = "https://wa.me/$number";
                  },
                ),

                // ⋮ More Options
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onPressed: () => _showPurchaseOptions(context, purchase),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PurchaseDetailScreen(purchase: purchase),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDuesList(List<PartyDueSummary> summaryList) {
    if (summaryList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? "No dues data available"
                  : "No results for '$_searchQuery'",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: summaryList.length,
      itemBuilder: (context, index) {
        final item = summaryList[index];
        final isCleared = item.balanceDue <= 0;
        final statusColor = isCleared ? Colors.green : Colors.red;

        return Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartyLedgerScreen(
                    partyName: item.partyName,
                  ),
                ),
              );
            },
            onLongPress: () => _showDuesOptions(context, item),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.partyName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCleared ? "CLEARED" : "PENDING",
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.more_vert, color: Colors.grey[600]),
                            onPressed: () => _showDuesOptions(context, item),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn(
                          "Purchased", item.totalPurchased, Colors.black87),
                      _buildStatColumn("Paid", item.totalPaid, Colors.green),
                      _buildStatColumn(
                          "Balance Due", item.balanceDue, Colors.red,
                          isBold: true),
                    ],
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartyLedgerScreen(
                              partyName: item.partyName,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.account_balance_wallet, size: 16),
                      label: Text('View Ledger'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClosedAccountsList(List<PartyDueSummary> closedDues) {
    if (closedDues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? "No closed accounts"
                  : "No results for '$_searchQuery'",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: closedDues.length,
      itemBuilder: (context, index) {
        final item = closedDues[index];

        return Card(
          elevation: 3,
          color: Colors.grey[100],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartyLedgerScreen(
                    partyName: item.partyName,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.lock, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.partyName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "CLOSED",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn(
                          "Purchased", item.totalPurchased, Colors.black54),
                      _buildStatColumn("Paid", item.totalPaid, Colors.black54),
                      _buildStatColumn(
                          "Balance", item.balanceDue, Colors.black54,
                          isBold: true),
                    ],
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _reopenAccount(item.partyName),
                      icon: Icon(Icons.lock_open, size: 16),
                      label: Text('Reopen Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, double amount, Color color,
      {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
