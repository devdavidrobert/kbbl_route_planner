// lib/presentation/pages/create_route_plan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/route_plan.dart';
import '../blocs/route_plan/route_plan_bloc.dart';
import '../blocs/route_plan/route_plan_event.dart';
import '../blocs/route_plan/route_plan_state.dart';
import '../blocs/sales/sales_bloc.dart';
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
  final List<int> _selectedWeeks = [1];
  final List<Schedule> _schedules = [Schedule(week: 1, days: [])];
  List<String> _commonDays = [];
  bool _useSameDays = true;
  final List<String> _selectedCustomerIds = [];

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
        id: DateTime.now().toIso8601String(),
        userId: widget.userId,
        region: 'Region', // Replace with actual region
        territory: 'Territory', // Replace with actual territory
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
                TextFormField(
                  controller: _routeController,
                  decoration: const InputDecoration(labelText: 'Route Name'),
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
                if (_selectedWeeks.isNotEmpty)
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
                BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, state) {
                    if (state is SalesDataLoaded) {
                      return Column(
                        children: state.customers.map((customer) {
                          return CheckboxListTile(
                            title: Text(customer.name),
                            value: _selectedCustomerIds.contains(customer.id),
                            onChanged: (value) => _toggleCustomer(customer.id),
                          );
                        }).toList(),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 16),
                BlocBuilder<RoutePlanBloc, RoutePlanState>(
                  builder: (context, state) {
                    if (state is RoutePlanLoading) {
                      return const CircularProgressIndicator();
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
