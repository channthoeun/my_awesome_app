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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handles the entire flow of fetching full pet details and navigating.
  /// Includes robust error handling for API exceptions.
  Future<void> _fetchDetailsAndNavigate(String petId, String token) async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final detailedPet = await _petService.getPetDetails(petId, token);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: detailedPet)),
        );
      }
    } on UnauthorizedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.amber.shade800),
        );
        Provider.of<AuthProvider>(context, listen: false).logout();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  /// Opens a modal bottom sheet to display a list of pets, with filtering.
  void _showPetSelectionSheet(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    final String searchTerm = _searchController.text.trim().toLowerCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return FutureBuilder<List<Pet>>(
              future: _petService.getPets(token),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorState(context, snapshot.error);
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No pets found.'));
                }

                List<Pet> allPets = snapshot.data!;
                List<Pet> filteredPets = allPets;

                if (searchTerm.isNotEmpty) {
                  filteredPets = allPets.where((pet) {
                    final petName = pet.name.toLowerCase();
                    final petCode = pet.code.toLowerCase();
                    final ownerName = pet.owner.fullName.toLowerCase();
                    return petName.contains(searchTerm) ||
                        petCode.contains(searchTerm) ||
                        ownerName.contains(searchTerm);
                  }).toList();
                }

                if (filteredPets.isEmpty) {
                  return Center(child: Text('No pets found for "$searchTerm"'));
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: filteredPets.length,
                  itemBuilder: (context, index) {
                    final pet = filteredPets[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade100,
                        backgroundImage: (pet.fullImageUrl != null && pet.imageUrl!.isNotEmpty)
                            ? NetworkImage(pet.fullImageUrl!)
                            : null,
                        child: (pet.imageUrl == null || pet.imageUrl!.isEmpty)
                            ? Text(pet.initials, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800))
                            : null,
                      ),
                      title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Code: ${pet.code} - Owner: ${pet.owner.fullName}'),
                      onTap: () {
                        Navigator.of(context).pop();
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

  /// Helper widget to display an error message inside the bottom sheet.
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
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the QR scanner screen and handles the result.
  Future<void> _navigateToScanner(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (ctx) => const QrScannerScreen()),
    );
    if (result != null && result.isNotEmpty && mounted) {
      _searchController.text = result;
      _showPetSelectionSheet(context); // Automatically search after scan
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
              'Search for a pet or view the complete list.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by Name, Code, or Owner...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      _showPetSelectionSheet(context);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _showPetSelectionSheet(context);
                  },
                  tooltip: 'Search Pets',
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => _navigateToScanner(context),
                  tooltip: 'Scan a Code',
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoadingDetails)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt, size: 28),
                label: const Text('Show Full Pet List'),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _searchController.clear();
                  _showPetSelectionSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}