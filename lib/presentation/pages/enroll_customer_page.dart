// lib/presentation/pages/enroll_customer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/distributor.dart';
import '../../domain/entities/location.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';

class EnrollCustomerPage extends StatelessWidget {
  final String userId;

  const EnrollCustomerPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enroll Customer')),
      body: EnrollCustomerForm(userId: userId),
    );
  }
}

class EnrollCustomerForm extends StatefulWidget {
  final String userId;

  const EnrollCustomerForm({required this.userId, super.key});

  @override
  _EnrollCustomerFormState createState() => _EnrollCustomerFormState();
}

class _EnrollCustomerFormState extends State<EnrollCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _invoiceNameController = TextEditingController();
  final _distributorNameController = TextEditingController();
  final _distributorContactController = TextEditingController();
  final _locationNameController = TextEditingController();
  Coordinates? _coordinates;
  final List<Distributor> _distributors = [];

  Future<void> _captureLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permissions are permanently denied')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _coordinates = Coordinates(
            latitude: position.latitude, longitude: position.longitude);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location captured successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture location: $e')),
      );
    }
  }

  void _addDistributor() {
    if (_distributorNameController.text.isNotEmpty &&
        _distributorContactController.text.isNotEmpty) {
      setState(() {
        _distributors.add(Distributor(
          id: DateTime.now().toIso8601String(),
          name: _distributorNameController.text,
          contactInfo: _distributorContactController.text,
        ));
        _distributorNameController.clear();
        _distributorContactController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter both distributor name and contact info')),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _coordinates != null &&
        _distributors.isNotEmpty) {
      final customer = Customer(
        id: DateTime.now().toIso8601String(),
        name: _nameController.text,
        distributors: _distributors,
        invoiceName: _invoiceNameController.text,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _invoiceNameController.dispose();
    _distributorNameController.dispose();
    _distributorContactController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state is SalesDataLoaded) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer enrolled successfully')),
          );
        } else if (state is SalesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _invoiceNameController,
              decoration: const InputDecoration(labelText: 'Invoice Name'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _distributorNameController,
              decoration: const InputDecoration(labelText: 'Distributor Name'),
            ),
            TextFormField(
              controller: _distributorContactController,
              decoration:
                  const InputDecoration(labelText: 'Distributor Contact Info'),
            ),
            ElevatedButton(
              onPressed: _addDistributor,
              child: const Text('Add Distributor'),
            ),
            if (_distributors.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text('Distributors:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ..._distributors.map((distributor) {
                    return Text(
                        '${distributor.name} (${distributor.contactInfo})');
                  }),
                ],
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationNameController,
              decoration: const InputDecoration(labelText: 'Location Name'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            ElevatedButton(
              onPressed: _captureLocation,
              child: const Text('Capture Location'),
            ),
            if (_coordinates != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Coordinates: (${_coordinates!.latitude}, ${_coordinates!.longitude})',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 16),
            BlocBuilder<SalesBloc, SalesState>(
              builder: (context, state) {
                if (state is SalesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Enroll'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
