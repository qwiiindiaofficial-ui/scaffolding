import 'package:flutter/material.dart';
import 'package:scaffolding_sale/screens/home/rental/menu/view_payment.dart';
import 'package:scaffolding_sale/screens/purchase/add.dart';
import 'package:scaffolding_sale/screens/purchase/model.dart';
import 'package:scaffolding_sale/screens/purchase/service.dart';

class SelectPartyScreen extends StatefulWidget {
  final String transactionType; // 'purchase' or 'payment'
  const SelectPartyScreen({super.key, required this.transactionType});

  @override
  State<SelectPartyScreen> createState() => _SelectPartyScreenState();
}

class _SelectPartyScreenState extends State<SelectPartyScreen> {
  final PartyService _partyService = PartyService();
  late final List<Party> _allParties;
  List<Party> _filteredParties = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // In a real app, you might fetch this data asynchronously.
    _allParties = _partyService.getParties();
    _filteredParties = _allParties;
    _searchController.addListener(_filterParties);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterParties);
    _searchController.dispose();
    super.dispose();
  }

  void _filterParties() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParties = _allParties.where((party) {
        final partyName = party.name.toLowerCase();
        return partyName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Party for ${widget.transactionType}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by party name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredParties.length,
              itemBuilder: (context, index) {
                final party = _filteredParties[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(party.name),
                    subtitle: Text(party.address),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      if (widget.transactionType == 'purchase') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddPurchaseScreen(party: party),
                          ),
                        );
                      } else if (widget.transactionType == 'payment') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewPayment(
                              party: party,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
