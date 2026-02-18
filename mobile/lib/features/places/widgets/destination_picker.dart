import 'dart:async';
import 'package:flutter/material.dart';
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
  final SearchController _searchController = SearchController();
  Timer? _debounce;

  Future<Iterable<Widget>> _searchPlaces(BuildContext context, String query) async {
    if (query.isEmpty) return const Iterable<Widget>.empty();

    // Debounce to avoid too many API calls
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    final completer = Completer<Iterable<Widget>>();
    
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final places = await _repository.getPlaces(search: query, limit: 10);
        
        final suggestions = places.map((place) => ListTile(
          leading: const Icon(Icons.place, color: Colors.blue),
          title: Text(place.name),
          subtitle: Text('${place.district ?? ""}, ${place.province ?? ""}'),
          onTap: () {
            widget.onDestinationSelected(place.name);
            _searchController.closeView(place.name);
          },
        ));
        
        completer.complete(suggestions);
      } catch (e) {
        completer.complete([
          ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: const Text('Error loading suggestions'),
            subtitle: Text(e.toString()),
            isThreeLine: true,
          )
        ]);
      }
    });

    return await completer.future;
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
