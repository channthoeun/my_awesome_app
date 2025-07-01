import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
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
  final _log = Logger('DashboardTab'); // <-- Create logger
  final PetService _petService = PetService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// The main, unified search function.
  /// Fetches the pet list and filters it based on the search term.
  /// Decides whether to navigate directly to details or show a list.
  Future<void> _performSearch(String searchTerm) async {
    _log.info('Performing search for term: "$searchTerm"');
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    // A simple check to see if the search term is likely an ID.
    // In a real app, a more robust regex might be better.
    bool isSearchById = searchTerm.length > 20 && searchTerm.contains('-');

    setState(() { _isLoading = true; });

    try {
      final List<Pet> allPets = await _petService.getPets(token);
      List<Pet> filteredPets = [];

      if (isSearchById) {
        // --- EXACT MATCH LOGIC for ID ---
        filteredPets = allPets.where((pet) => pet.id == searchTerm).toList();
      } else {
        // --- FUZZY SEARCH LOGIC for text ---
        final lowerCaseSearchTerm = searchTerm.toLowerCase();
        if (lowerCaseSearchTerm.isNotEmpty) {
          filteredPets = allPets.where((pet) {
            return pet.name.toLowerCase().contains(lowerCaseSearchTerm) ||
                pet.code.toLowerCase().contains(lowerCaseSearchTerm) ||
                pet.owner.fullName.toLowerCase().contains(lowerCaseSearchTerm);
          }).toList();
        } else {
          // If search term is empty, the result is the full list.
          filteredPets = allPets;
        }
      }

      if (!mounted) return;

      if (filteredPets.length == 1) {
        // If exactly one match, go straight to details. This also handles the ID search case.
        // We set _isLoading to false inside _fetchDetailsAndNavigate
        _fetchDetailsAndNavigate(filteredPets.first.id, token);
      } else if (filteredPets.isNotEmpty) {
        // If multiple matches, show the list.
        setState(() { _isLoading = false; });
        _showFilteredPetList(filteredPets, token);
      } else {
        // If no matches, show a snackbar.
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No pet found for "$searchTerm"')),
        );
      }
    } on UnauthorizedException catch (e) {
      _handleApiError(e);
    } catch (e) {
      _handleApiError(e);
    } finally {
      // Final check to ensure loading indicator is turned off if an
      // unexpected path is taken.
      if (mounted && _isLoading) {
        setState(() { _isLoading = false; });
      }
    }
  }

  /// Fetches full details for a single pet and navigates to its screen.
  Future<void> _fetchDetailsAndNavigate(String petId, String token) async {
    // The loading state is already true from _performSearch.
    try {
      final detailedPet = await _petService.getPetDetails(petId, token);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PetDetailScreen(pet: detailedPet)),
        );
      }
    } on UnauthorizedException catch (e) {
      _handleApiError(e);
    } catch (e) {
      _handleApiError(e);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  /// Displays a pre-filtered list of pets in a modal bottom sheet.
  void _showFilteredPetList(List<Pet> pets, String token) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    backgroundImage: (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
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
  }

  /// Navigates to the QR scanner and processes the result.
  Future<void> _navigateToScanner(BuildContext context) async {
    _log.info('Navigating to QR scanner.');
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (ctx) => const QrScannerScreen()),
    );
    if (result != null && result.isNotEmpty && mounted) {
      if (result.startsWith('pet_id:')) {
        final petId = result.substring('pet_id:'.length);
        _performSearch(petId);
      } else {
        _searchController.text = result;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned: "$result". Press search to find.')),
        );
      }
    }
  }

  /// Centralized handler for API errors.
  void _handleApiError(Object e, [StackTrace? stackTrace]) {
    _log.severe('API Error encountered on dashboard', e, stackTrace);
    if (!mounted) return;
    if (e is UnauthorizedException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.amber.shade800),
      );
      Provider.of<AuthProvider>(context, listen: false).logout();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
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
              'Search for a pet or view the complete list.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: CircularProgressIndicator(),
              ))
            else
              Column(
                children: [
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
                            _performSearch(_searchController.text.trim());
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _performSearch(_searchController.text.trim());
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt, size: 28),
                    label: const Text('Show Full Pet List'),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _searchController.clear();
                      _performSearch('');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}