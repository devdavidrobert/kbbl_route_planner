// lib/presentation/pages/enroll_customer_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/distributor.dart';
import '../../domain/entities/location.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class EnrollCustomerPage extends StatelessWidget {
  final String userId;

  const EnrollCustomerPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Customer'),
        elevation: 0,
      ),
      body: EnrollCustomerForm(userId: userId),
    );
  }
}

class EnrollCustomerForm extends StatefulWidget {
  final String userId;

  const EnrollCustomerForm({required this.userId, super.key});

  @override
  State<EnrollCustomerForm> createState() => _EnrollCustomerFormState();
}

class _EnrollCustomerFormState extends State<EnrollCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _distributorNameController = TextEditingController();
  final _invoiceNameController = TextEditingController();
  final _locationNameController = TextEditingController();
  Coordinates? _coordinates;
  final List<Distributor> _distributors = [];
  String? _userRegion;
  String? _userTerritory;

  @override
  void initState() {
    super.initState();
    // Get user profile data
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      setState(() {
        _userRegion = authState.profile.region;
        _userTerritory = authState.profile.territory;
      });
    }
  }

  Future<void> _captureLocation() async {
    if (!mounted) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _coordinates = Coordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location captured successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addDistributor() {
    if (_distributorNameController.text.isNotEmpty &&
        _invoiceNameController.text.isNotEmpty) {
      setState(() {
        _distributors.add(Distributor(
          id: DateTime.now().toIso8601String(),
          name: _distributorNameController.text,
          invoiceName: _invoiceNameController.text,
        ));
        _distributorNameController.clear();
        _invoiceNameController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both distributor name and invoice name'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _submit() {
    if (_userRegion == null || _userTerritory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your profile must have a region and territory set'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate() &&
        _coordinates != null &&
        _distributors.isNotEmpty) {
      final customer = Customer(
        id: DateTime.now().toIso8601String(),
        name: _nameController.text,
        region: _userRegion!,
        territory: _userTerritory!,
        distributors: _distributors,
        location: Location(
          locationName: _locationNameController.text,
          coordinates: _coordinates!,
        ),
        userId: widget.userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<SalesBloc>().add(AddCustomerEvent(customer));
    } else {
      String missingFields = '';
      if (_coordinates == null) missingFields += 'Location, ';
      if (_distributors.isEmpty) missingFields += 'Distributor, ';
      if (!_formKey.currentState!.validate()) {
        missingFields += 'Required form fields, ';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please complete: ${missingFields.substring(0, missingFields.length - 2)}'),
          backgroundColor: Colors.red,
        ),
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
            // User's Region and Territory Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Territory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Region: ${_userRegion ?? 'Not set'}',
                      style: TextStyle(
                        color: _userRegion == null ? Colors.red : Colors.black,
                      ),
                    ),
                    Text(
                      'Territory: ${_userTerritory ?? 'Not set'}',
                      style: TextStyle(
                        color:
                            _userTerritory == null ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Basic Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name *',
                        hintText: 'Enter the name assigned by the rep',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Customer name is required'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Distributor Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distributor Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                        hintText:
                            'Enter the name under which this customer is invoiced',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addDistributor,
                      icon: const Icon(Icons.add_business),
                      label: const Text('Add Distributor'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    if (_distributors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Added Distributors:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._distributors.map((distributor) {
                        return Card(
                          child: ListTile(
                            title: Text(distributor.name),
                            subtitle: Text(
                                'Invoice Name: ${distributor.invoiceName}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _distributors.remove(distributor);
                                });
                              },
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name *',
                        hintText: 'Enter a descriptive name for this location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Location name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _captureLocation,
                      icon: const Icon(Icons.location_on),
                      label: const Text('Capture Location'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
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

            // Submit Button
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
