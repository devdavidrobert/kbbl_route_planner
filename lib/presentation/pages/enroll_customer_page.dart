import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/distributor.dart';
import '../../domain/entities/location.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';

class EnrollCustomerPage extends StatefulWidget {
  final String userId;

  const EnrollCustomerPage({super.key, required this.userId});

  @override
  State<EnrollCustomerPage> createState() => _EnrollCustomerPageState();
}

class _EnrollCustomerPageState extends State<EnrollCustomerPage> {
  String? _userRegion;
  String? _userTerritory;

  @override
  void initState() {
    super.initState();
    _userRegion = 'Sample Region'; // Replace with actual logic
    _userTerritory = 'Sample Territory'; // Replace with actual logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enroll Customer')),
      body: EnrollCustomerForm(
        userId: widget.userId,
        userRegion: _userRegion,
        userTerritory: _userTerritory,
      ),
    );
  }
}

class EnrollCustomerForm extends StatefulWidget {
  final String userId;
  final String? userRegion;
  final String? userTerritory;

  const EnrollCustomerForm({
    super.key,
    required this.userId,
    this.userRegion,
    this.userTerritory,
  });

  @override
  State<EnrollCustomerForm> createState() => _EnrollCustomerFormState();
}

class _EnrollCustomerFormState extends State<EnrollCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _distributorNameController = TextEditingController();
  final _invoiceNameController = TextEditingController();
  final _locationNameController = TextEditingController();
  final List<Distributor> _distributors = [];
  Coordinates? _coordinates;

  Future<void> _captureLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _coordinates = Coordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture location: $e')),
      );
    }
  }

  void _addDistributor() {
    final name = _distributorNameController.text.trim();
    final invoiceName = _invoiceNameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _distributors.add(Distributor(
          id: DateTime.now().toIso8601String(),
          name: name,
          invoiceName: invoiceName.isEmpty ? name : invoiceName,
        ));
        _distributorNameController.clear();
        _invoiceNameController.clear();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _coordinates != null) {
      final customer = Customer(
        id: DateTime.now().toIso8601String(),
        name: _nameController.text.trim(),
        distributors: _distributors,
        location: Location(
          locationName: _locationNameController.text.trim(),
          coordinates: _coordinates!,
        ),
        userId: widget.userId,
        region: widget.userRegion,
        territory: widget.userTerritory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<SalesBloc>().add(EnrollCustomer(customer)); // Correct event
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields and capture location')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distributorNameController.dispose();
    _invoiceNameController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state is CustomerEnrolled) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer enrolled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SalesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Territory',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Region: ${widget.userRegion ?? 'Not set'}',
                        style: TextStyle(color: widget.userRegion == null ? Colors.red : Colors.black)),
                    Text('Territory: ${widget.userTerritory ?? 'Not set'}',
                        style: TextStyle(color: widget.userTerritory == null ? Colors.red : Colors.black)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name *',
                        hintText: 'Enter the name assigned by the rep',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Customer name is required' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distributor Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _distributorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Distributor Name',
                        hintText: 'Enter distributor name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _invoiceNameController,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Name',
                        hintText: 'Enter the name under which this customer is invoiced',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addDistributor,
                      icon: const Icon(Icons.add_business),
                      label: const Text('Add Distributor'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    ),
                    if (_distributors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Added Distributors:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ..._distributors.map((distributor) => Card(
                            child: ListTile(
                              title: Text(distributor.name),
                              subtitle: Text('Invoice Name: ${distributor.invoiceName}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _distributors.remove(distributor);
                                  });
                                },
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name *',
                        hintText: 'Enter a descriptive name for this location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Location name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _captureLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Capture Location'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                    ),
                    if (_coordinates != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Location captured: (${_coordinates!.latitude.toStringAsFixed(6)}, ${_coordinates!.longitude.toStringAsFixed(6)})',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('Enroll Customer'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}