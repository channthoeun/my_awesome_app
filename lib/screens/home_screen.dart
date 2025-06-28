import 'package:flutter/material.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:my_awesome_app/screens/tabs/dashboard_tab.dart';
import 'package:my_awesome_app/screens/tabs/profile_tab.dart';
import 'package:my_awesome_app/screens/tabs/upload_tab.dart';
import 'package:my_awesome_app/widgets/custom_app_bar.dart'; // <-- Import the new widget
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardTab(),
    ProfileTab(),
    UploadTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This function will be passed to the AppBar to handle profile avatar taps
  void _navigateToProfile() {
    setState(() {
      _selectedIndex = 1; // Index 1 is the ProfileTab
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the user from the provider
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      // Replace the old AppBar with our new CustomAppBar
      appBar: CustomAppBar(
        user: user,
        onProfileTap: _navigateToProfile,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}