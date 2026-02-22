import 'package:flutter/material.dart';
import '../data/places_repository.dart';
import '../models/place.dart';
import '../widgets/place_card.dart';

class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({super.key});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  final PlacesRepository _repository = PlacesRepository();
  List<Place> _places = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'historical', 'temple', 'mountain', 'park', 'beach', 'forest', 'waterfall', 'garden'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final places = await _repository.getPlaces(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory,
      );
      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Lanka Places'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? _buildErrorWidget()
                : _places.isEmpty
                  ? _buildEmptyWidget()
                  : RefreshIndicator(
                      onRefresh: _fetchPlaces,
                      child: ListView.builder(
                        itemCount: _places.length,
                        itemBuilder: (context, index) {
                          return PlaceCard(
                            place: _places[index],
                            onTap: () {
                              // Navigate to details (to be implemented)
                            },
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _fetchPlaces();
        },
        decoration: InputDecoration(
          hintText: 'Search attractions...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('All', null);
          }
          final cat = _categories[index - 1];
          return _buildCategoryChip(
            cat[0].toUpperCase() + cat.substring(1), 
            cat
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    bool isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? value : null;
          });
          _fetchPlaces();
        },
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade800 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'An unknown error occurred'),
          ElevatedButton(
            onPressed: _fetchPlaces,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Text('No places found matching your search.'),
    );
  }
}
