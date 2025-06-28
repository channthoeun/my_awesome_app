import 'package:flutter/material.dart';
import 'package:my_awesome_app/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final VoidCallback onProfileTap;

  const CustomAppBar({
    super.key,
    required this.user,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // 1. Profile Picture Avatar on the left
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(50),
          child: CircleAvatar(
            backgroundColor: Colors.indigo.shade300,
            child: user != null
                ? Text(
              user!.initials, // Using our new getter!
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
                : const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ),
      // 2. Logo in the center
      title: Image.asset(
        'assets/images/logo.png', // Your logo file
        height: 40,
        // Add a fallback in case the image fails to load
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.apps); // Fallback icon
        },
      ),
      centerTitle: true,
      // 3. Settings/Logout menu on the right
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings_outlined),
          onSelected: (value) {
            if (value == 'settings') {
              // TODO: Navigate to a real settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings page coming soon!')),
              );
            } else if (value == 'logout') {
              Provider.of<AuthProvider>(context, listen: false).logout();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}