import 'package:flutter/material.dart';
import 'package:my_awesome_app/models/pet_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image and QR Code Section ---
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      pet.fullImageUrl ?? 'https://via.placeholder.com/250',
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.pets, size: 250, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(pet.name, style: Theme.of(context).textTheme.headlineSmall),
                  Text('Code: ${pet.code}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  QrImageView(data: pet.qrData, version: QrVersions.auto, size: 150),
                  const SizedBox(height: 8),
                  Text('ID: ${pet.id}', style: Theme.of(context).textTheme.bodySmall),
                  const Divider(height: 40),
                ],
              ),
            ),

            // --- Basic Info Section ---
            _buildSectionHeader('Basic Information'),
            _buildInfoTile('Breed', pet.breed ?? ''),
            _buildInfoTile('Age', '${pet.age} year(s)'),
            _buildInfoTile('Sex', pet.sex == 'F' ? 'Female' : 'Male'),
            _buildBooleanTile('Friendly?', pet.isFriendly),
            _buildBooleanTile('Spayed/Neutered?', pet.isSpayedNeutered),
            const Divider(height: 40),

            // --- Owner Info Section ---
            _buildSectionHeader('Owner Details'),
            _buildInfoTile('Name', pet.owner.fullName),
            _buildInfoTile('Phone', pet.owner.phone),
            _buildInfoTile('Email', pet.owner.email),
            const Divider(height: 40),

            // --- Health History Section ---
            _buildSectionHeader('Health History'),
            _buildBooleanTile('Fully Vaccinated?', pet.healthHistory!.isFullyVaccinated),
            _buildBooleanTile('Rabies Vaccinated?', pet.healthHistory!.isRabiesVaccinated),
            _buildBooleanTile('Recently De-wormed?', pet.healthHistory!.isRecentlyDeWormed),

            const SizedBox(height: 40),
            // --- Check-in/Check-out Buttons ---
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.login), label: const Text('Check-In'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.logout), label: const Text('Check-Out'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange))),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper widgets to reduce code duplication
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildBooleanTile(String label, bool value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}