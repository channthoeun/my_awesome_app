import 'package:my_awesome_app/api/api_client.dart';
import 'package:my_awesome_app/models/pet_model.dart';
import 'package:my_awesome_app/utils/api_endpoints.dart';

class PetService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Pet>> getPets(String token) async {
    print('PetService, getPets, ApiEndpoints.pet: $ApiEndpoints.pet');
    try {
      // 1. Await the response from the ApiClient. It will be of type 'dynamic'.
      final dynamic responseData = await _apiClient.get(
        ApiEndpoints.pet,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('PetService, getPets, response: $responseData');
      if (responseData is List) {
        // 3. Cast the 'dynamic' list to a 'List<dynamic>' and then map over it.
        //    For each item (which is a Map<String, dynamic>), call Pet.fromJson.
        //    Finally, convert the result to a List.
        return responseData.map<Pet>((json) => Pet.fromJson(json)).toList();
      } else {
        // If the API returned something other than a list, it's an error.
        throw Exception('API did not return a list of pets as expected.');
      }
    } catch (e) {
      // Re-throw the exception to be handled by the UI layer
      rethrow;
    }

    //   if (response.statusCode == 200) {
    //     // Decode the response body, which should be a JSON array (List)
    //     final List<dynamic> petData = json.decode(response.body);
    //     print('PetService, getPets, petData: $petData');
    //
    //     // Use the map() function to iterate over the list and convert
    //     // each JSON object (Map<String, dynamic>) into a Pet object
    //     // using our Pet.fromJson factory.
    //     return petData.map((json) => Pet.fromJson(json)).toList();
    //
    //   } else {
    //     // If the server did not return a 200 OK response, throw an error.
    //     throw Exception('Failed to load pets. Status code: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   // Handle network errors or other exceptions
    //   print(e.toString());
    //   throw Exception('An error occurred while fetching pets.');
    // }
  }

  // The getPetDetails method remains the same, using a mock for now.
  // You would update this similarly when you have a real /api/pet/{id} endpoint.
  Future<Pet> getPetDetails(String petId, String token) async {
    try {
      // For dynamic endpoints, call the static function
      final response = await _apiClient.get(
        ApiEndpoints.petDetail(petId), // <-- Use the function
        headers: {'Authorization': 'Bearer $token'},
      );
      return Pet.fromJson(response);
    } catch (e) { rethrow; }
  }
}