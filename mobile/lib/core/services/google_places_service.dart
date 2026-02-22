import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GooglePlacesService {
  final String? apiKey;

  GooglePlacesService({this.apiKey});

  String get _key => apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<GooglePlaceSuggestion>> getSuggestions(String input) async {
    if (input.isEmpty) return [];
    if (_key.isEmpty || _key == 'your_google_maps_api_key_here') {
      print('Google Places Error: API Key is not configured in .env');
      return [];
    }

    final queryParameters = {
      'input': input,
      'key': _key,
      'components': 'country:lk',
    };

    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', queryParameters);
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((p) => GooglePlaceSuggestion.fromJson(p)).toList();
        } else if (data['status'] == 'REQUEST_DENIED') {
          print('Google Places Error: Request Denied - ${data['error_message']}');
        } else {
          print('Google Places Status: ${data['status']}');
        }
      }
      return [];
    } catch (e) {
      print('Google Places Error: $e');
      return [];
    }
  }
}

class GooglePlaceSuggestion {
  final String description;
  final String placeId;

  GooglePlaceSuggestion({required this.description, required this.placeId});

  factory GooglePlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return GooglePlaceSuggestion(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}
