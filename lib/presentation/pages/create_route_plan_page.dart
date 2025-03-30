// lib/presentation/pages/create_route_plan_page.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/route_plan.dart';
import '../blocs/route_plan/route_plan_bloc.dart';
import '../blocs/route_plan/route_plan_event.dart';
import '../blocs/route_plan/route_plan_state.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/sales/sales_bloc.dart';
import '../blocs/sales/sales_state.dart';
import '../blocs/sales/sales_event.dart';

class CreateRoutePlanPage extends StatefulWidget {
  final String userId;

  const CreateRoutePlanPage({super.key, required this.userId});

  @override
  _CreateRoutePlanPageState createState() => _CreateRoutePlanPageState();
}

class _CreateRoutePlanPageState extends State<CreateRoutePlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _routeController = TextEditingController();
  final List<int> _selectedWeeks = [1];
  final List<Schedule> _schedules = [Schedule(week: 1, days: [])];
  List<String> _commonDays = [];
  bool _useSameDays = true;
  final List<String> _selectedCustomerIds = [];
  String? _userRegion;
  String? _userTerritory;

  @override
  void initState() {
    super.initState();
    // Get user profile data
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _userRegion = authState.profile.region;
      _userTerritory = authState.profile.territory;
    }
    // Fetch customers
    context.read<SalesBloc>().add(FetchSalesData(widget.userId));
  }

  void _toggleWeek(int week) {
    setState(() {
      if (_selectedWeeks.contains(week)) {
        _selectedWeeks.remove(week);
        _schedules.removeWhere((s) => s.week == week);
      } else {
        _selectedWeeks.add(week);
        _schedules.add(Schedule(
          week: week,
          days: _useSameDays ? List.from(_commonDays) : [],
        ));
      }
      _selectedWeeks.sort();
      _schedules.sort((a, b) => a.week.compareTo(b.week));
    });
  }

  void _toggleDay(int week, String day) {
    setState(() {
      if (_useSameDays) {
        if (_commonDays.contains(day)) {
          _commonDays.remove(day);
        } else {
          _commonDays.add(day);
        }
        for (var schedule in _schedules) {
          schedule.days.clear();
          schedule.days.addAll(_commonDays);
        }
      } else {
        final schedule = _schedules.firstWhere((s) => s.week == week);
        if (schedule.days.contains(day)) {
          schedule.days.remove(day);
        } else {
          schedule.days.add(day);
        }
      }
    });
  }

  void _toggleSameDays(bool? value) {
    setState(() {
      _useSameDays = value ?? true;
      if (_useSameDays) {
        _commonDays =
            _schedules.isNotEmpty ? List.from(_schedules.first.days) : [];
        for (var schedule in _schedules) {
          schedule.days.clear();
          schedule.days.addAll(_commonDays);
        }
      }
    });
  }

  void _toggleCustomer(String customerId) {
    setState(() {
      if (_selectedCustomerIds.contains(customerId)) {
        _selectedCustomerIds.remove(customerId);
      } else {
        _selectedCustomerIds.add(customerId);
      }
    });
  }

  void _createRoutePlan() {
    if (_formKey.currentState!.validate()) {
      if (_userRegion == null || _userTerritory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Region and territory not set in your profile'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      for (var schedule in _schedules) {
        if (schedule.days.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Each week must have at least one day selected')),
          );
          return;
        }
      }

      final routePlan = RoutePlan(
        id: '', // Let MongoDB generate the ID
        userId: widget.userId,
        region: _userRegion!,
        territory: _userTerritory!,
        route: _routeController.text,
        schedule: _schedules,
        customerIds: _selectedCustomerIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<RoutePlanBloc>().add(CreateRoutePlanEvent(routePlan));
    }
  }

  @override
  void dispose() {
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Route Plan')),
      body: BlocListener<RoutePlanBloc, RoutePlanState>(
        listener: (context, state) {
          if (state is RoutePlanLoaded) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Route plan created successfully')),
            );
          } else if (state is RoutePlanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Display user's region and territory
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Region: ${_userRegion ?? 'Not set'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Territory: ${_userTerritory ?? 'Not set'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _routeController,
                  decoration: const InputDecoration(labelText: 'Route Name *'),
                  validator: (value) =>
                      value!.isEmpty ? 'Route name is required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Select Weeks',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: [1, 2, 3, 4].map((week) {
                    return ChoiceChip(
                      label: Text('Week $week'),
                      selected: _selectedWeeks.contains(week),
                      onSelected: (selected) => _toggleWeek(week),
                    );
                  }).toList(),
                ),
                if (_selectedWeeks.length > 1)
                  Row(
                    children: [
                      const Text('Use same days for all weeks?'),
                      Switch(
                        value: _useSameDays,
                        onChanged: _toggleSameDays,
                      ),
                    ],
                  ),
                const Text('Select Days',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_useSameDays && _selectedWeeks.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Days for all weeks:'),
                      Wrap(
                        spacing: 8,
                        children: [
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday'
                        ].map((day) {
                          return ChoiceChip(
                            label: Text(day),
                            selected: _commonDays.contains(day),
                            onSelected: (selected) => _toggleDay(1, day),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                if (!_useSameDays)
                  ..._schedules.map((schedule) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Week ${schedule.week}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Wrap(
                          spacing: 8,
                          children: [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday'
                          ].map((day) {
                            return ChoiceChip(
                              label: Text(day),
                              selected: schedule.days.contains(day),
                              onSelected: (selected) =>
                                  _toggleDay(schedule.week, day),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }),
                const SizedBox(height: 16),
                const Text('Assign Customers',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text(
                  'Optionally select customers to include in this route:',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, state) {
                    if (state is SalesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is SalesDataLoaded) {
                      final filteredCustomers = state.customers.where((customer) {
                        // Only show customers in the user's region/territory
                        final regionMatch = _userRegion == null ||
                            customer.region == _userRegion;
                        final territoryMatch = _userTerritory == null ||
                            customer.territory == _userTerritory;
                        return regionMatch && territoryMatch;
                      }).toList();

                      if (filteredCustomers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No customers found in your region/territory.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          ...filteredCustomers.map((customer) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: CheckboxListTile(
                                title: Text(customer.name),
                                subtitle: Text(
                                    '${customer.location.locationName}\nDistributor: ${customer.distributors.first.name}'),
                                value: _selectedCustomerIds.contains(customer.id),
                                onChanged: (bool? value) =>
                                    _toggleCustomer(customer.id),
                              ),
                            );
                          }),
                        ],
                      );
                    }
                    return const Center(
                        child: Text('Failed to load customers'));
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<RoutePlanBloc, RoutePlanState>(
                  builder: (context, state) {
                    if (state is RoutePlanLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _createRoutePlan,
                      child: const Text('Create Route Plan'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
