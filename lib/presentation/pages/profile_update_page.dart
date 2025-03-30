// lib/presentation/pages/profile_update_page.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../routes.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

class ProfileUpdatePage extends StatelessWidget {
  final User user;
  final UserProfile? profile;

  const ProfileUpdatePage({required this.user, this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: ProfileUpdateForm(user: user, profile: profile),
    );
  }
}

class ProfileUpdateForm extends StatefulWidget {
  final User user;
  final UserProfile? profile;

  const ProfileUpdateForm({required this.user, this.profile, super.key});

  @override
  _ProfileUpdateFormState createState() => _ProfileUpdateFormState();
}

class _ProfileUpdateFormState extends State<ProfileUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _territoryController = TextEditingController();
  final _branchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _regionController.text = widget.profile!.region ?? '';
      _territoryController.text = widget.profile!.territory ?? '';
      _branchController.text = widget.profile!.branch ?? '';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfile(
        userId: widget.user.id,
        email: widget.user.email,
        name: widget.user.displayName ?? '',
        region: _regionController.text,
        territory: _territoryController.text,
        branch: _branchController.text.isEmpty ? null : _branchController.text,
        createdAt: widget.profile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context
          .read<AuthBloc>()
          .add(AuthProfileUpdated(widget.user, updatedProfile));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  @override
  void dispose() {
    _regionController.dispose();
    _territoryController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          // Navigate to HomePage
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
            (route) => false,
            arguments: {'userId': state.profile.userId},
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              Text(
                'Please enter your profile details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Region',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Region is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _territoryController,
                decoration: const InputDecoration(
                  labelText: 'Territory',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Territory is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(
                  labelText: 'Branch (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Save Profile'),
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
