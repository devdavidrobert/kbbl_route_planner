import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_state.dart';

class CustomerDetailsPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
      ),
      body: BlocListener<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state is OrdersLoaded) { // Updated state
            // Handle orders if needed
          } else if (state is SalesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${customer.name}', style: const TextStyle(fontSize: 18)),
              Text('Location: ${customer.location.locationName}'),
              // Add more customer details as needed
            ],
          ),
        ),
      ),
    );
  }
}