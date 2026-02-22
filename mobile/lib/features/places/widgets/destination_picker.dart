import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/google_places_service.dart';
import '../data/places_repository.dart';
import '../models/place.dart';

class DestinationPicker extends StatefulWidget {
  final Function(String) onDestinationSelected;

  const DestinationPicker({super.key, required this.onDestinationSelected});

  @override
  State<DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  final PlacesRepository _repository = PlacesRepository();
  final GooglePlacesService _googleService = GooglePlacesService();
  final SearchController _searchController = SearchController();
  String _currentQuery = '';

  Future<Iterable<Widget>> _searchPlaces(BuildContext context, String query) async {
    if (query.isEmpty) return const Iterable<Widget>.empty();
    
    _currentQuery = query;
    // Simple debounce: wait a bit and check if query is still the same
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentQuery != query) return const Iterable<Widget>.empty();

    try {
      print('DEBUG: [DestinationPicker] Starting search for: "$query"');
      final hasKey = _googleService.apiKey != null || 
        (dotenv.env['GOOGLE_MAPS_API_KEY'] != null && 
         dotenv.env['GOOGLE_MAPS_API_KEY'] != 'your_google_maps_api_key_here');

      print('DEBUG: [DestinationPicker] API Key Configured: $hasKey');

      // Fetch from Google and internal DB in parallel
      final results = await Future.wait([
        _googleService.getSuggestions(query).timeout(const Duration(seconds: 5), onTimeout: () {
          print('DEBUG: [DestinationPicker] Google Places request timed out');
          return <GooglePlaceSuggestion>[];
        }),
        _repository.getPlaces(search: query, limit: 3).timeout(const Duration(seconds: 3), onTimeout: () {
          print('DEBUG: [DestinationPicker] Local DB request timed out');
          return <Place>[];
        }).catchError((e) {
          print('DEBUG: [DestinationPicker] Local DB Error: $e');
          return <Place>[];
        }),
      ]);

      final googleSuggestions = results[0] as List<GooglePlaceSuggestion>;
      final internalPlaces = results[1] as List<Place>;
      
      print('DEBUG: [DestinationPicker] Results - Google: ${googleSuggestions.length}, Local: ${internalPlaces.length}');

      final List<Widget> items = [];

      if (!hasKey) {
        items.add(Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Google Maps API key not configured in .env',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        ));
      }

      // Google Results - Primary
      if (googleSuggestions.isNotEmpty) {
        items.add(const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.map, size: 16, color: Colors.blue),
              SizedBox(width: 8),
              Text('GOOGLE MAPS RESULTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: Colors.blueGrey)),
            ],
          ),
        ));
        items.addAll(googleSuggestions.map((suggestion) => ListTile(
          leading: const Icon(Icons.place, color: Colors.blue),
          title: Text(suggestion.description),
          onTap: () {
            print('DEBUG: [DestinationPicker] Selected Google suggestion: ${suggestion.description}');
            widget.onDestinationSelected(suggestion.description);
            _searchController.closeView(suggestion.description);
          },
        )));
      }

      // Curated Results - Secondary
      if (internalPlaces.isNotEmpty) {
        if (items.isNotEmpty) items.add(const Divider(height: 32));
        items.add(const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber),
              SizedBox(width: 8),
              Text('CURATED ADVENTURES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5, color: Colors.blueGrey)),
            ],
          ),
        ));
        items.addAll(internalPlaces.map((place) => ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: Text(place.name),
          subtitle: Text('${place.district ?? ""}, ${place.province ?? ""}'),
          onTap: () {
            print('DEBUG: [DestinationPicker] Selected local place: ${place.name}');
            widget.onDestinationSelected(place.name);
            _searchController.closeView(place.name);
          },
        )));
      }

      if (items.isEmpty) {
        print('DEBUG: [DestinationPicker] No results found for "$query"');
        items.add(const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No places found', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ));
      }
      
      return items;
    } catch (e) {
      print('DEBUG: [DestinationPicker] Search Critical Error: $e');
      return [
        ListTile(
          leading: const Icon(Icons.error, color: Colors.red),
          title: const Text('Error loading suggestions'),
          subtitle: Text(e.toString()),
        )
      ];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (context, controller) {
        return TextField(
          controller: controller,
          onTap: () => controller.openView(),
          onChanged: (_) => controller.openView(),
          decoration: const InputDecoration(
            hintText: 'Add destination...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          readOnly: true, // Prevent manual typing in the main field to force the search view
        );
      },
      suggestionsBuilder: (context, controller) {
        return _searchPlaces(context, controller.text);
      },
      viewHintText: 'Type a location name...',
      viewLeading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _searchController.closeView(null),
      ),
    );
  }
}
