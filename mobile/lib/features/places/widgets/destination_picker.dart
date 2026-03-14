import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DestinationPicker extends StatefulWidget {
  final Function(String) onDestinationSelected;

  const DestinationPicker({super.key, required this.onDestinationSelected});

  @override
  State<DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  final SearchController _searchController = SearchController();
  String _currentQuery = '';

  // DIRECT API CALL TO OPENSTREETMAP
  Future<List<Map<String, dynamic>>> _fetchLivePlaces(String input) async {
    if (input.isEmpty) return [];

    // Force search to look inside Sri Lanka
    final query = Uri.encodeComponent('$input Sri Lanka');
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=8',
    );

    try {
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'MaporaSL_Mobile_App/1.0', // Required by OSM
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('Live Map Error: $e');
    }
    return [];
  }

  Future<Iterable<Widget>> _searchPlaces(
    BuildContext context,
    String query,
  ) async {
    if (query.isEmpty) return const Iterable<Widget>.empty();

    _currentQuery = query;
    // Wait half a second before asking the server so we don't spam it
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentQuery != query) return const Iterable<Widget>.empty();

    try {
      final livePlaces = await _fetchLivePlaces(query);
      final List<Widget> items = [];

      if (livePlaces.isNotEmpty) {
        items.add(
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.public, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'LIVE OPENSTREETMAP RESULTS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        );

        items.addAll(
          livePlaces.map((placeData) {
            final String name = placeData['name'] ?? 'Unknown Location';
            final address = placeData['address'] as Map<String, dynamic>?;

            // Try to build a nice subtitle (e.g. "City, State")
            String subtitle = '';
            if (address != null) {
              final parts = [
                address['city'] ?? address['county'] ?? '',
                address['state'] ?? '',
              ].where((e) => e.toString().isNotEmpty && e != name).toList();
              subtitle = parts.join(', ');
            }

            return ListTile(
              leading: const Icon(Icons.place, color: Colors.green),
              title: Text(name),
              subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
              onTap: () {
                widget.onDestinationSelected(name);
                _searchController.closeView(name);
              },
            );
          }),
        );
      }

      if (items.isEmpty) {
        items.add(
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.satellite_alt, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No matching map data found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return items;
    } catch (e) {
      return [
        const ListTile(
          leading: Icon(Icons.wifi_off, color: Colors.red),
          title: Text('Network Error'),
          subtitle: Text('Please check your internet connection'),
        ),
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
            hintText: 'Search the live map...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          readOnly: true,
        );
      },
      suggestionsBuilder: (context, controller) {
        return _searchPlaces(context, controller.text);
      },
      viewHintText: 'Type any location in Sri Lanka...',
      viewLeading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _searchController.closeView(null),
      ),
    );
  }
}
