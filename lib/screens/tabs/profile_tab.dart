import 'package:flutter/material.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // We can still get the user object the same way
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),

          // Card for basic user info
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('User Information'),
                  tileColor: Colors.black12,
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(user.fullName), // Using our new getter!
                  subtitle: const Text('Full Name'),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(user.username),
                  subtitle: const Text('Username'),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(user.email),
                  subtitle: const Text('Email'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card for branch info
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.store_outlined),
                  title: Text('Branch Information'),
                  tileColor: Colors.black12,
                ),
                ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: Text(user.branch.name),
                  subtitle: const Text('Branch Name'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(user.branch.address),
                  subtitle: const Text('Address'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(user.branch.phone),
                  subtitle: const Text('Phone'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card for permissions
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: const Text('Permissions'),
                  subtitle: Text('${user.permissions.length} permissions granted'),
                  tileColor: Colors.black12,
                ),
                // Example of using our hasPermission helper method!
                if (user.hasPermission('view_dashboard'))
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Dashboard Access'),
                    subtitle: Text('This user can view the dashboard.'),
                  ),
                if (user.hasPermission('add_pet'))
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Can Add Pets'),
                    subtitle: Text('This user can add new pets.'),
                  ),
                if (!user.hasPermission('add_pet'))
                  const ListTile(
                    leading: Icon(Icons.cancel, color: Colors.red),
                    title: Text('Cannot Add Pets'),
                    subtitle: Text('This user does not have permission.'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}