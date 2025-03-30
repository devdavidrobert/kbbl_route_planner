// lib/presentation/widgets/user_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

class UserCard extends StatelessWidget {
  final UserProfile profile;

  const UserCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${profile.email}'),
            if (profile.region != null) Text('Region: ${profile.region}'),
            if (profile.territory != null)
              Text('Territory: ${profile.territory}'),
            if (profile.branch != null) Text('Branch: ${profile.branch}'),
          ],
        ),
      ),
    );
  }
}
