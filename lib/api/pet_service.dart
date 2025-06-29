import 'dart:convert';
import 'package:my_awesome_app/models/pet_model.dart';
import 'package:http/http.dart' as http;
import 'package:my_awesome_app/utils/app_config.dart';

class PetService {
  final String _baseUrl = AppConfig.baseUrl;
  // --- THIS METHOD IS NOW UPDATED ---
  Future<List<Pet>> getPets(String token) async {
    // Construct the full URL to the endpoint
    final url = Uri.parse('$_baseUrl/api/pet');
    print('PetService, getPets, url: $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Decode the response body, which should be a JSON array (List)
        final List<dynamic> petData = json.decode(response.body);
        print('PetService, getPets, petData: $petData');

        // Use the map() function to iterate over the list and convert
        // each JSON object (Map<String, dynamic>) into a Pet object
        // using our Pet.fromJson factory.
        return petData.map((json) => Pet.fromJson(json)).toList();

      } else {
        // If the server did not return a 200 OK response, throw an error.
        throw Exception('Failed to load pets. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print(e.toString());
      throw Exception('An error occurred while fetching pets.');
    }
  }

  // The getPetDetails method remains the same, using a mock for now.
  // You would update this similarly when you have a real /api/pet/{id} endpoint.
  Future<Pet> getPetDetails(String petId, String token) async {
    // ... (This method remains unchanged for now)
    await Future.delayed(const Duration(seconds: 1));
    const mockJsonResponse = '''{ "id": "2f02e12d-5027-4c28-9740-b5504a501ca7", "type": { "id": "46177e1a-95c0-4589-a748-cea9910a6766", "index": 0, "name": "Dog", "description": "" }, "name": "Jacky", "code": "000001", "weight": null, "sex": "F", "last_heat_date": "2025-02-01", "age": 1, "breed": "Breed Test", "is_spayed_neutered": false, "is_friendly": true, "is_sensitive_body_or_physical_restriction": true, "sensitive_body_or_physical_restriction_details": "If yes, please explain", "is_allowed_photo_video_usage": true, "owner": { "id": "baa2c0de-f342-4ad3-8ad9-073707f1a69f", "first_name": "Channthoeun", "last_name": "Ken", "phone": "012 123 456", "email": "channthoeun@gmail.com", "address": "Phnom Penh", "nationality": "Cambodian", "emergency_contact": "012 123 456", "vet_details": "My vet", "how_did_you_hear_about_good_dog": "Others", "how_did_you_hear_about_good_dog_other": "TVC", "type": { "id": "4393b099-37ba-4f83-b7ea-43fb463e2c44", "name": "Premium", "note": "Premium" } }, "vaccines": [], "diseases": [], "health_history": { "id": "a2a3013f-3d8f-425a-ae21-9905a5aeb6c8", "is_fully_vaccinated": true, "vaccination_proof": null, "is_rabies_vaccinated": true, "is_skin_problems": false, "is_ticks_flees_treated": null, "ticks_flees_treated_date": null, "ticks_flees_treated_how_to": null, "is_recently_de_wormed": true, "recently_de_wormed_date": "2025-02-01", "is_special_dietary_requirements": true, "special_dietary_requirements_description": "If so what?", "is_ill_last_30_days": true, "ill_last_30_days_explanation": "If yes, please explain", "is_displaying_symptoms_coughing_sneezing_upset_stomach": true, "is_medical_conditions_injuries_illnesses": true, "medical_conditions_injuries_illnesses_details": "If yes, please provide details including any medication, quantity & administration where required", "is_allergies_food_sensitivities": true, "allergies_food_sensitivities_details": "If yes ,please provide details" }, "image": "/media/pet_images/angkor-wat-main_c2896504_20250611074128.jpg", "image_filename": "angkor-wat-main.jpg" }''';
    return Pet.fromJson(json.decode(mockJsonResponse));
  }
}