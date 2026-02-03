import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transporter_models.dart';
import '../services/transporter_service.dart';
import 'add_driver_screen.dart';
import 'add_vehicle_screen.dart';

class TransporterDetailScreen extends StatefulWidget {
  final String transporterId;
  const TransporterDetailScreen({super.key, required this.transporterId});

  @override
  State<TransporterDetailScreen> createState() =>
      _TransporterDetailScreenState();
}

class _TransporterDetailScreenState extends State<TransporterDetailScreen>
    with SingleTickerProviderStateMixin {
  final TransporterService _service = TransporterService();
  late TabController _tabController;

  // State variables to hold the loaded data and loading status
  Transporter? _transporter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load the data when the screen is first created
    _loadTransporterDetails();
  }

  // Method to fetch data from SharedPreferences
  Future<void> _loadTransporterDetails() async {
    // Set loading to true before fetching
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final allTransporters = await _service.getTransporters();
    final foundTransporter = allTransporters.firstWhere(
      (t) => t.id == widget.transporterId,
      orElse: () => Transporter(
          name: 'Not Found',
          contactPerson: '',
          phone: '',
          email: ''), // Return a default if not found
    );

    // Update the state with the loaded data
    if (mounted) {
      setState(() {
        _transporter = foundTransporter;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show transporter name from state, or 'Loading...'
        title: Text(_transporter?.name ?? 'Loading...'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          tabs: const [
            Tab(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.directions_car),
                  SizedBox(width: 8),
                  Text('Vehicles')
                ])),
            Tab(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.badge_outlined),
                  SizedBox(width: 8),
                  Text('Drivers')
                ])),
          ],
        ),
      ),
      // Show a loader while fetching, then show the content
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transporter == null || _transporter!.name == 'Not Found'
              ? const Center(
                  child: Text('Transporter details could not be found.'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVehiclesTab(_transporter!),
                    _buildDriversTab(_transporter!),
                  ],
                ),
    );
  }

  Widget _buildVehiclesTab(Transporter transporter) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Await for the add screen to close, then reload details
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AddVehicleScreen(transporterId: transporter.id)));
          _loadTransporterDetails(); // Refresh the list
        },
        label: const Text('Add Vehicle'),
        icon: const Icon(Icons.add),
      ),
      body: transporter.vehicles.isEmpty
          ? const Center(child: Text('No vehicles added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transporter.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = transporter.vehicles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.directions_car)),
                    title: Text(vehicle.vehicleNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('${vehicle.vehicleType} - ${vehicle.capacity}'),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDriversTab(Transporter transporter) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Await for the add screen to close, then reload details
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AddDriverScreen(transporterId: transporter.id)));
          _loadTransporterDetails(); // Refresh the list
        },
        label: const Text('Add Driver'),
        icon: const Icon(Icons.add),
      ),
      body: transporter.drivers.isEmpty
          ? const Center(child: Text('No drivers added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transporter.drivers.length,
              itemBuilder: (context, index) {
                final driver = transporter.drivers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        child: const Icon(Icons.person)),
                    title: Text(driver.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'DL Exp: ${DateFormat.yMMMd().format(driver.license.expiryDate)}'),
                    trailing: Text(driver.phone,
                        style: TextStyle(color: Colors.grey.shade700)),
                  ),
                );
              },
            ),
    );
  }
}
