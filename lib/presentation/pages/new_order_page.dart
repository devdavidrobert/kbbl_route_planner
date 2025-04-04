import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_constants.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/order.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_event.dart';
import '../blocs/sales/sales_state.dart';

class NewOrderPage extends StatefulWidget {
  final Customer customer;

  const NewOrderPage({super.key, required this.customer});

  @override
  _NewOrderPageState createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final Map<String, Map<String, int>> _skus = {
    'Original': {'300ml': 0, '400ml': 0, '500ml': 0},
    'Power': {'300ml': 0, '400ml': 0, '500ml': 0},
    'Recharge': {'300ml': 0, '400ml': 0, '500ml': 0},
  };

  Future<bool> _checkProximity() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.customer.location.coordinates.latitude,
        widget.customer.location.coordinates.longitude,
      );
      return distance <= AppConstants.proximityThreshold;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check proximity: $e')),
      );
      return false;
    }
  }

  void _placeOrder() async {
    final isWithinProximity = await _checkProximity();
    if (!isWithinProximity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are too far from the customer location')),
      );
      return;
    }

    final order = Order(
      id: DateTime.now().toIso8601String(),
      customerId: widget.customer.id,
      userId: widget.customer.userId,
      skus: _skus,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.read<SalesBloc>().add(PlaceOrderEvent(order));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Order')),
      body: BlocListener<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state is OrderPlaced) { // Updated state
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully')),
            );
          } else if (state is SalesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Select SKUs and Quantities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('300ml')),
                  DataColumn(label: Text('400ml')),
                  DataColumn(label: Text('500ml')),
                ],
                rows: _skus.entries.map((entry) {
                  final product = entry.key;
                  final sizes = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Text(product)),
                      DataCell(
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          onChanged: (value) {
                            setState(() {
                              sizes['300ml'] = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      DataCell(
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          onChanged: (value) {
                            setState(() {
                              sizes['400ml'] = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      DataCell(
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                          onChanged: (value) {
                            setState(() {
                              sizes['500ml'] = int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SalesBloc, SalesState>(
                builder: (context, state) {
                  if (state is SalesLoading) {
                    return const CircularProgressIndicator();
                  }
                  return ElevatedButton(
                    onPressed: _placeOrder,
                    child: const Text('Place Order'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}