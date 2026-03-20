import 'package:flutter/material.dart';
import '../../../places/data/places_repository.dart';
import '../../../places/models/place.dart';

class CategoryFilteredPlacePicker extends StatefulWidget {
  final Function(String) onDestinationSelected;

  const CategoryFilteredPlacePicker({super.key, required this.onDestinationSelected});

  @override
  State<CategoryFilteredPlacePicker> createState() => _CategoryFilteredPlacePickerState();
}

class _CategoryFilteredPlacePickerState extends State<CategoryFilteredPlacePicker> {
  final PlacesRepository _repository = PlacesRepository();
  String? _selectedCategory;
  String? _selectedPlace;
  List<Place> _places = [];
  bool _isLoading = false;

  List<String> _categories = ['all'];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final dbCategories = await _repository.getCategories();
      if (mounted) {
        setState(() {
          _categories = ['all', ...dbCategories];
          _selectedCategory = 'all';
        });
        await _loadPlaces();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = ['all', 'other'];
          _selectedCategory = 'all';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPlaces() async {
    final category = (_selectedCategory == 'all' || _selectedCategory == null) 
        ? null 
        : _selectedCategory;
    
    setState(() {
      _isLoading = true;
      _selectedPlace = null; // Reset selection when category changes
    });
    try {
      final results = await _repository.getPlaces(
        category: category,
        limit: 100, // Fetch up to 100 places for the dropdown
      );
      if (mounted) {
        setState(() {
          _places = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading places: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category Dropdown
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Filter by Category',
            prefixIcon: Icon(Icons.category_outlined),
            border: OutlineInputBorder(),
          ),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c == 'all' ? 'All Categories' : c[0].toUpperCase() + c.substring(1)))).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
              _places = []; // Clear current list to show loading
            });
            _loadPlaces();
          },
        ),
        const SizedBox(height: 16),
        
        // Place Dropdown
        _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : DropdownButtonFormField<String>(
              value: _selectedPlace,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Place',
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
              items: _places.map((p) => DropdownMenuItem(
                value: p.name,
                child: Text(
                  '${p.name} (${p.district ?? "Sri Lanka"})',
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPlace = val);
                  widget.onDestinationSelected(val);
                }
              },
              hint: const Text('Pick a destination...'),
            ),
      ],
    );
  }
}
