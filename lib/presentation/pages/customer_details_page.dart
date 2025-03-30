// lib/presentation/pages/customer_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';
import 'new_order_page.dart';

class CustomerDetailsPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              context.read<SalesBloc>().add(
                  GetCustomerPerformanceEvent(customer.id, customer.userId));
            },
          ),
        ],
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesDataLoaded && state.performance != null) {
            final performance = state.performance!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer ID: ${customer.id}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Distributor: ${customer.distributors.first.name}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Location: ${customer.location.locationName}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Coordinates: (${customer.location.coordinates.latitude}, ${customer.location.coordinates.longitude})',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text('Performance',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Total Orders: ${performance['totalOrders']}'),
                  Text('Total Volume: ${performance['totalVolume']}'),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer ID: ${customer.id}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Distributor: ${customer.distributors.first.name}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Location: ${customer.location.locationName}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'Coordinates: (${customer.location.coordinates.latitude}, ${customer.location.coordinates.longitude})',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewOrderPage(customer: customer),
          ),
        ),
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
