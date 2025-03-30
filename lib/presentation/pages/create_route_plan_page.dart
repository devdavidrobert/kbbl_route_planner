import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';

class CreateRoutePlanPage extends StatefulWidget {
  final String userId;

  const CreateRoutePlanPage({super.key, required this.userId});

  @override
  _CreateRoutePlanPageState createState() => _CreateRoutePlanPageState();
}

class _CreateRoutePlanPageState extends State<CreateRoutePlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _routeController = TextEditingController();
  final _scheduleController = TextEditingController();
  List<Customer> _selectedCustomers = [];
  List<Customer> _availableCustomers = [];

  @override
  void initState() {
    super.initState();
    context.read<SalesBloc>().add(FetchSalesData(widget.userId)); // Fetch data for planning
  }

  void _saveRoutePlan() {
    if (_formKey.currentState!.validate()) {
      // Here you’d typically dispatch to a RoutePlanBloc, but for this example, we’ll simulate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route plan saved (simulated)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _routeController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Route Plan')),
      body: BlocListener<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state is CustomerEnrolled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Customer enrolled successfully')),
            );
          } else if (state is SalesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _routeController,
                  decoration: const InputDecoration(
                    labelText: 'Route Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Route name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _scheduleController,
                  decoration: const InputDecoration(
                    labelText: 'Schedule *',
                    hintText: 'e.g., Monday 9 AM - 12 PM',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Schedule is required' : null,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<SalesBloc, SalesState>(
                    builder: (context, state) {
                      if (state is SalesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is OrdersLoaded) { // Replace SalesDataLoaded
                        // Simulate customer list from orders or fetch separately
                        _availableCustomers = []; // Update this logic if customers are fetched
                        return _buildCustomerSelection();
                      } else if (state is SalesError) {
                        return Center(child: Text(state.message));
                      }
                      return const Center(child: Text('No customers available'));
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveRoutePlan,
                  child: const Text('Save Route Plan'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Customers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _availableCustomers.length,
            itemBuilder: (context, index) {
              final customer = _availableCustomers[index];
              final isSelected = _selectedCustomers.contains(customer);
              return CheckboxListTile(
                title: Text(customer.name),
                subtitle: Text(customer.location.locationName),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedCustomers.add(customer);
                    } else {
                      _selectedCustomers.remove(customer);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}