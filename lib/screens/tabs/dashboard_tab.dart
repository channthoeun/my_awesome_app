import 'package:flutter/material.dart';
import 'package:my_awesome_app/api/api_exceptions.dart';
import 'package:my_awesome_app/api/pet_service.dart';
import 'package:my_awesome_app/models/pet_model.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:my_awesome_app/screens/pet_detail_screen.dart';
import 'package:my_awesome_app/screens/qr_scanner_screen.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final PetService _petService = PetService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingDetails = false;

  /// Handles the entire flow of fetching full pet details and navigating to the detail screen.
  /// Includes robust error handling for API exceptions.
  Future<void> _fetchDetailsAndNavigate(String petId, String token) async {
    // Show a loading indicator on the main screen
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      // Fetch the full, detailed pet object from the service
      final detailedPet = await _petService.getPetDetails(petId, token);

      // IMPORTANT: Check if the widget is still in the tree before navigating.
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: detailedPet)),
        );
      }
    } on UnauthorizedException catch (e) {
      // --- CATCHES 401/403 ERRORS ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.amber.shade800,
          ),
        );
        // Log the user out, which will trigger a rebuild to the login screen
        Provider.of<AuthProvider>(context, listen: false).logout();
      }
    } catch (e) {
      // --- CATCHES ALL OTHER ERRORS (Network, Server, etc.) ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // IMPORTANT: Always turn off the loading indicator, whether success or failure.
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  /// Opens a modal bottom sheet to display a list of pets fetched from the API.
  void _showPetSelectionSheet(BuildContext context) {
    // Get the auth token once before opening the sheet
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            // FutureBuilder handles the async call to get the pet list
            return FutureBuilder<List<Pet>>(
              future: _petService.getPets(token),
              builder: (context, snapshot) {
                // --- LOADING STATE ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // --- ERROR STATE ---
                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error);
                }

                // --- EMPTY STATE ---
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pets found.'));
                }

                // --- SUCCESS STATE ---
                final pets = snapshot.data!;
                return ListView.builder(
                  controller: scrollController,
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (pet.fullImageUrl != null)
                            ? NetworkImage(pet.fullImageUrl!)
                            : null,
                        child: (pet.fullImageUrl == null) ? const Icon(Icons.pets) : null,
                      ),
                      title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Code: ${pet.code} - Owner: ${pet.owner.fullName}'),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the sheet
                        _fetchDetailsAndNavigate(pet.id, token);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Helper widget to display an appropriate error message inside the bottom sheet.
  Widget _buildErrorState(BuildContext context, Object? error) {
    String errorMessage = 'An unknown error occurred.';
    bool isUnauthorized = false;

    if (error is UnauthorizedException) {
      errorMessage = error.message;
      isUnauthorized = true;
    } else if (error is ApiException) {
      errorMessage = error.message;
    } else {
      errorMessage = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (isUnauthorized)
              ElevatedButton(
                child: const Text('Go to Login'),
                onPressed: () {
                  // Use listen:false in callbacks
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Navigation logic for the scanner (can be integrated with search)
  Future<void> _navigateToScanner(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (ctx) => const QrScannerScreen()),
    );

    if (result != null && result.isNotEmpty && mounted) {
      _searchController.text = result;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.pets, size: 80, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text(
              'Pet Management Dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select an option below to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),

            // Main action button to show the pet list
            if (_isLoadingDetails)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt, size: 28),
                label: const Text('Show Pet List'),
                onPressed: () => _showPetSelectionSheet(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),

            const SizedBox(height: 16),
            // Optional: Add other dashboard actions here if needed
            // For example, a quick access to the QR scanner
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan a Code'),
              onPressed: () => _navigateToScanner(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}