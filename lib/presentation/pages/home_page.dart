// lib/presentation/pages/home_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logging/logging.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';
import 'create_route_plan_page.dart';
import 'enroll_customer_page.dart';

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({required this.userId, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _logger = Logger('HomePage');
  bool _isInitialFetchDone = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    if (!_isInitialFetchDone && mounted) {
      _logger.info('Performing initial orders fetch');
      context.read<SalesBloc>().add(FetchOrders(widget.userId));
      _isInitialFetchDone = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        return true;
      },
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
        body: SafeArea(
          child: BlocConsumer<SalesBloc, SalesState>(
            listener: (context, state) {
              if (!mounted) return;
              
              if (state is OrderPlaced) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed successfully: ${state.orderId}')),
                );
                // Orders will be automatically refreshed by the bloc
              } else if (state is CustomerEnrolled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Customer enrolled successfully: ${state.customerId}')),
                );
                // Orders will be automatically refreshed by the bloc
              } else if (state is SalesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
  if (state is SalesLoading) {
    return const Center(child: CircularProgressIndicator());
  } else if (state is OrdersLoaded) {
    return ListView.builder(
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return ListTile(
          title: Text('Order ${order.id}'),
          subtitle: Text('Customer: ${order.customerId}'),
        );
      },
    );
  } else if (state is SalesError) {
    return Center(child: Text('Error: ${state.message}'));
  }
  return const Center(child: Text('No data'));
},
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.person_add),
              label: 'Enroll Customer',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EnrollCustomerPage(userId: widget.userId),
                  ),
                );
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.route),
              label: 'Create Route Plan',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateRoutePlanPage(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
