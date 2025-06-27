import 'package:flutter/material.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: Text('Could not load profile.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.name),
              subtitle: const Text('Name'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: Text(user.email),
              subtitle: const Text('Email'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(user.id),
              subtitle: const Text('User ID'),
            ),
          ),
        ],
      ),
    );
  }
}