// transporter/screens/list_transporters_screen.dart
import 'package:flutter/material.dart';
import '../models/transporter_models.dart';
import '../services/transporter_service.dart';
import 'add_transporter_screen.dart';
import 'transporter_detail_screen.dart';

class ListTransportersScreen extends StatefulWidget {
  const ListTransportersScreen({super.key});

  @override
  State<ListTransportersScreen> createState() => _ListTransportersScreenState();
}

class _ListTransportersScreenState extends State<ListTransportersScreen> {
  late Future<List<Transporter>> _transportersFuture;
  final TransporterService _transporterService = TransporterService();

  @override
  void initState() {
    super.initState();
    _loadTransporters();
  }

  // Method to fetch/refresh the data
  void _loadTransporters() {
    setState(() {
      _transportersFuture = _transporterService.getTransporters();
    });
  }

  // Method to handle navigation and refresh on return
  void _navigateAndRefresh() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTransporterScreen()),
    );
    // When we come back from the add screen, reload the list
    _loadTransporters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transporters')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh, // Use the new navigation method
        tooltip: 'Add Transporter',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Transporter>>(
        future: _transportersFuture,
        builder: (context, snapshot) {
          // While data is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there's an error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If data is empty or null
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          // If data is loaded successfully
          final transporters = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: transporters.length,
            itemBuilder: (context, index) {
              final transporter = transporters[index];
              return TransporterListItemCard(
                transporter: transporter,
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        TransporterDetailScreen(transporterId: transporter.id),
                  ));
                  // Refresh when returning from detail screen too
                  _loadTransporters();
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('No Transporters Added',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Tap the "+" button to add a new transporter.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class TransporterListItemCard extends StatelessWidget {
  final Transporter transporter;
  final VoidCallback onTap;

  const TransporterListItemCard(
      {super.key, required this.transporter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transporter.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(transporter.contactPerson,
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone_outlined,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(transporter.phone,
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildStatChip(context, Icons.directions_car,
                      '${transporter.vehicles.length} Vehicles'),
                  const SizedBox(width: 8),
                  _buildStatChip(context, Icons.badge_outlined,
                      '${transporter.drivers.length} Drivers'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Theme.of(context).primaryColor),
      label: Text(label),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
