import 'package:my_awesome_app/utils/app_config.dart'; // We'll need this for the image URL

// --- Nested Sub-Models ---

class PetType {
  final String id;
  final String name;

  PetType({required this.id, required this.name});

  factory PetType.fromJson(Map<String, dynamic> json) {
    return PetType(id: json['id'], name: json['name']);
  }
}

class Owner {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  Owner({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  String get fullName => '$firstName $lastName';

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class HealthHistory {
  final bool isFullyVaccinated;
  final bool isRabiesVaccinated;
  final bool isRecentlyDeWormed;
  final DateTime? recentlyDeWormedDate;
  final bool hasSpecialDietaryRequirements;
  final String? specialDietaryRequirementsDescription;

  HealthHistory({
    required this.isFullyVaccinated,
    required this.isRabiesVaccinated,
    required this.isRecentlyDeWormed,
    this.recentlyDeWormedDate,
    required this.hasSpecialDietaryRequirements,
    this.specialDietaryRequirementsDescription,
  });

  factory HealthHistory.fromJson(Map<String, dynamic> json) {
    return HealthHistory(
      isFullyVaccinated: json['is_fully_vaccinated'] ?? false,
      isRabiesVaccinated: json['is_rabies_vaccinated'] ?? false,
      isRecentlyDeWormed: json['is_recently_de_wormed'] ?? false,
      recentlyDeWormedDate: json['recently_de_wormed_date'] != null
          ? DateTime.tryParse(json['recently_de_wormed_date'])
          : null,
      hasSpecialDietaryRequirements: json['is_special_dietary_requirements'] ?? false,
      specialDietaryRequirementsDescription: json['special_dietary_requirements_description'],
    );
  }
}

// --- Main Pet Model ---

class Pet {
  final String id;
  final PetType type;
  final String name;
  final String code;
  final String? weight;
  final String sex;
  final DateTime? lastHeatDate;
  final int age;
  final String? breed;
  final bool isSpayedNeutered;
  final bool isFriendly;
  final Owner owner;
  final HealthHistory? healthHistory;
  final String? imageUrl; // Relative image path from API

  Pet({
    required this.id,
    required this.type,
    required this.name,
    required this.code,
    this.weight,
    required this.sex,
    this.lastHeatDate,
    required this.age,
    required this.breed,
    required this.isSpayedNeutered,
    required this.isFriendly,
    required this.owner,
    required this.healthHistory,
    this.imageUrl,
  });

  String get initials {
    if (name.trim().isEmpty) {
      return '?'; // Fallback for empty names
    }
    // Takes the first character of the name and capitalizes it.
    return name.trim().substring(0, 2).toUpperCase();
  }

  // Helper getter to create a full, usable image URL
  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    // Assuming your .env BASE_URL is something like http://10.0.2.2:8000
    return '${AppConfig.baseUrl}/api${imageUrl!}';
  }

  String get qrData => 'pet_id:$id';


  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      type: PetType.fromJson(json['type']),
      name: json['name'],
      code: json['code'],
      weight: json['weight'],
      sex: json['sex'],
      lastHeatDate: json['last_heat_date'] != null
          ? DateTime.tryParse(json['last_heat_date'])
          : null,
      age: json['age'],
      breed: json['breed'],
      isSpayedNeutered: json['is_spayed_neutered'] ?? false,
      isFriendly: json['is_friendly'] ?? false,
      owner: Owner.fromJson(json['owner']),
      healthHistory: json['health_history'] != null
          ? HealthHistory.fromJson(json['health_history'])
          : null,
      imageUrl: json['image'],
    );
  }
}