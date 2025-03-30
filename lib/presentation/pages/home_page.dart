// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';
import '../../domain/entities/distributor.dart';
import '../../domain/entities/location.dart';
import '../../injection.dart' as di;

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SalesBloc>()..add(FetchOrders(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sales App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is OrderPlaced) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Order placed successfully: ${state.orderId}')),
              );
            } else if (state is CustomerEnrolled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Customer enrolled successfully: ${state.customerId}')),
              );
            } else if (state is SalesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('An error occurred. Please try again.')),
              );
            }
          },
          child: BlocBuilder<SalesBloc, SalesState>(
            builder: (context, state) {
              if (state is SalesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is OrdersLoaded) {
                if (state.orders.isEmpty) {
                  return const Center(child: Text('No orders available'));
                }
                return ListView.builder(
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return ListTile(
                      title: Text('Order #${order.id}'),
                      subtitle: Text('Customer ID: ${order.customerId}'),
                      trailing: Text('SKUs: ${order.skus.toString()}'),
                    );
                  },
                );
              } else if (state is SalesError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load orders. Please try again.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<SalesBloc>().add(FetchOrders(userId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('No data available'));
            },
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.shopping_cart),
              label: 'Place Order',
              onTap: () {
                context.read<SalesBloc>().add(PlaceOrder(
                      userId: userId,
                      customerId: 'CUST001',
                      skus: {
                        'Original': {'300ml': 5},
                        'Lite': {'500ml': 3},
                      },
                    ));
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.person_add),
              label: 'Enroll Customer',
              onTap: () {
                context.read<SalesBloc>().add(EnrollCustomer(
                      customerId: 'CUST001',
                      customerName: 'Test Customer',
                      userId: userId,
                      distributors: [
                        Distributor(
                          id: 'DIST001',
                          name: 'Distributor 1',
                          contactInfo: 'dist1@example.com',
                        ),
                      ],
                      invoiceName: 'Test Invoice',
                      location: Location(
                        locationName: 'Test Location',
                        coordinates: Coordinates(
                          latitude: 1.0,
                          longitude: 2.0,
                        ),
                      ),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
