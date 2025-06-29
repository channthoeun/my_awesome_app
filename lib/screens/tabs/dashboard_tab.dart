import 'package:flutter/material.dart';
import 'package:my_awesome_app/api/pet_service.dart';
import 'package:my_awesome_app/models/pet_model.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:my_awesome_app/screens/qr_scanner_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../pet_detail_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final PetService _petService = PetService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingDetails = false;

  void _showPetSelectionSheet(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // We use the simpler getPets() here for the list
        return FutureBuilder<List<Pet>>(
          future: _petService.getPets(token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Could not load pets.'));
            }
            final pets = snapshot.data!;
            // print('Pets: $pets');
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text(pet.name),
                  subtitle: Text('Code: ${pet.code} - Owner: ${pet.owner.fullName}'),
                  // When a pet is tapped, fetch details and navigate
                  onTap: () {
                    Navigator.of(context).pop(); // Close the bottom sheet first
                    _fetchDetailsAndNavigate(pet.id, token);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _fetchDetailsAndNavigate(String petId, String token) async {
    setState(() { _isLoadingDetails = true; });
    try {
      final detailedPet = await _petService.getPetDetails(petId, token);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: detailedPet)),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load details: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() { _isLoadingDetails = false; });
      }
    }
  }

  Future<void> _navigateToScanner(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (ctx) => const QrScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      // Handle the scanned data, e.g., put it in the search box
      setState(() {
        _searchController.text = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: $result')),
      );
    }
  }

  // void _performCheckIn(BuildContext context) {
  //   // In a real app, call an API for check-in
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Checking in ${_selectedPet!.name}...'), backgroundColor: Colors.green),
  //   );
  // }
  //
  // void _performCheckOut(BuildContext context) {
  //   // In a real app, call an API for check-out
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Checking out ${_selectedPet!.name}...'), backgroundColor: Colors.orange),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Pet Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),

          // Search Bar and Scanner
          // ... (Search Bar UI remains the same)

          const SizedBox(height: 24),

          // Main Action Button to select a pet
          if (_isLoadingDetails)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.list_alt),
                label: const Text('Show Pet List'),
                onPressed: () => _showPetSelectionSheet(context),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}