import 'dart:convert';
import 'package:http/http.dart' as http;

class FreePlacesService {
  Future<List<FreePlaceSuggestion>> getSuggestions(String input) async {
    if (input.isEmpty) return [];
    final searchQuery = '$input Sri Lanka';
    final uri = Uri.parse('https://photon.komoot.io/api/?q=${Uri.encodeComponent(searchQuery)}&limit=8');
    
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        final filteredFeatures = features.where((f) {
           final country = f['properties']['country']?.toString().toLowerCase() ?? '';
           return country.contains('sri lanka');
        }).toList();
        return filteredFeatures.map((f) => FreePlaceSuggestion.fromJson(f['properties'])).toList();
      }
      return [];
    } catch (e) {
      print('Free Places Exception: $e');
      return [];
    }
  }
}

class FreePlaceSuggestion {
  final String name;
  final String state; 
  final String city;

  FreePlaceSuggestion({required this.name, required this.state, required this.city});

  factory FreePlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return FreePlaceSuggestion(
      name: json['name'] ?? 'Unknown Location',
      state: json['state'] ?? '',
      city: json['city'] ?? json['county'] ?? '', 
    );
  }

  String get subtitle {
    final parts = [city, state].where((e) => e.isNotEmpty && e != name).toList();
    return parts.join(', ');
  }
}