import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/trip_model.dart';
import '../data/models/trip_dto.dart';
import 'providers/trips_provider.dart';
import '../../places/data/places_repository.dart';
import 'widgets/category_filtered_place_picker.dart';

/// Create/Edit custom trip page
class CreateTripPage extends ConsumerStatefulWidget {
  final TripModel? trip; // null = create, non-null = edit
  final List<String> initialDestinations;

  const CreateTripPage({
    super.key,
    this.trip,
    this.initialDestinations = const [],
  });

  @override
  ConsumerState<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends ConsumerState<CreateTripPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _startingLocationCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<String> _places;
  String? _selectedCategory;
  String? _selectedPlace;
  String? _tripType = 'Adventure'; // Default trip type
  List<String> _categories = ['all', 'historical', 'beach', 'adventure', 'nature', 'temple', 'cultural', 'city', 'other'];
  List<String> _availablePlaces = [];
  bool _isFetchingPlaces = false;


  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.trip?.title ?? '');
    _descriptionCtrl = TextEditingController(
      text: widget.trip?.description ?? '',
    );
    _startingLocationCtrl = TextEditingController(
      text:
          (widget.trip?.locations != null &&
              (widget.trip!.locations?.isNotEmpty ?? false))
          ? widget.trip!.locations!.first.name
          : '',
    );
    _startDate = widget.trip?.startDate ?? DateTime.now();
    _endDate =
        widget.trip?.endDate ?? DateTime.now().add(const Duration(days: 1));
    _places = widget.trip?.locations?.map((l) => l.name).toList() ?? [];
    for (final place in widget.initialDestinations) {
      if (!_places.contains(place)) {
        _places.add(place);
      }
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final placesRepo = ref.read(placesRepositoryProvider);
      final categories = await placesRepo.getCategories();
      if (mounted) {
        setState(() {
          // Merge dynamic categories with our core display list to keep UI rich
          final Set<String> merged = {'all', 'historical', 'beach', 'adventure', 'nature', 'temple', 'cultural', 'city', 'other'};
          merged.addAll(categories.map((c) => c.toLowerCase()));
          _categories = merged.toList();
          _selectedCategory = 'all';
        });
        _loadPlacesBySelectedCategory();
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadPlacesBySelectedCategory() async {
    setState(() => _isFetchingPlaces = true);
    try {
      final placesRepo = ref.read(placesRepositoryProvider);
      final list = await placesRepo.getPlaces(
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        limit: 100,
      );
      if (mounted) {
        setState(() {
          _availablePlaces = list.map((p) => p.name).toList();
          _isFetchingPlaces = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading places: $e');
      if (mounted) setState(() => _isFetchingPlaces = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _startingLocationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _saveTrip() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trip title is required')));
      return;
    }

    if (_places.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one destination')),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    final locations = _places
        .map((p) => TripLocation(name: p, day: 1))
        .toList();

    try {
      if (widget.trip == null) {
        final dto = CreateTripDto(
          title: _titleCtrl.text,
          description: _descriptionCtrl.text.isEmpty
              ? null
              : _descriptionCtrl.text,
          startDate: _startDate,
          endDate: _endDate,
          locations: locations,
          tripType: _tripType,
          startingPoint: _startingLocationCtrl.text.isEmpty ? null : _startingLocationCtrl.text,
        );
        await ref.read(tripsProvider.notifier).createTrip(dto);
      } else {
        final dto = UpdateTripDto(
          title: _titleCtrl.text,
          description: _descriptionCtrl.text.isEmpty
              ? null
              : _descriptionCtrl.text,
          startDate: _startDate,
          endDate: _endDate,
          locations: locations,
        );
        await ref.read(tripsProvider.notifier).updateTrip(widget.trip!.id, dto);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.trip == null ? 'Trip created!' : 'Trip updated!',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip == null ? 'Create Trip' : 'Edit Trip'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Basic Info Section
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Trip Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Journal Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _startingLocationCtrl,
            decoration: const InputDecoration(
              labelText: 'Starting Point',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Dates Section
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('From', style: TextStyle(fontSize: 12)),
                  subtitle: Text(DateFormat('MMM dd').format(_startDate)),
                  onTap: _pickStartDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  title: const Text('To', style: TextStyle(fontSize: 12)),
                  subtitle: Text(DateFormat('MMM dd').format(_endDate)),
                  onTap: _pickEndDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          
          // ==========================================
          // CATEGORY SELECTION (CHIPS)
          // ==========================================
          const Text(
            'Explore Places from Database',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category == 'all' ? 'All' : category[0].toUpperCase() + category.substring(1)),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                        _selectedPlace = null;
                      });
                      _loadPlacesBySelectedCategory();
                    },
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Place Dropdown
          DropdownButtonFormField<String>(
            value: _selectedPlace,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Place',
              border: const OutlineInputBorder(),
              suffixIcon: _isFetchingPlaces 
                ? const SizedBox(width: 20, height: 20, child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
                : null,
            ),
            items: _availablePlaces.map((name) => DropdownMenuItem(
              value: name,
              child: Text(name, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (val) => setState(() => _selectedPlace = val),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: _selectedPlace == null ? null : () {
              setState(() {
                if (!_places.contains(_selectedPlace)) {
                  _places.add(_selectedPlace!);
                  _selectedPlace = null;
                }
              });
            },
            icon: const Icon(Icons.add_location_alt),
            label: const Text('Add to Itinerary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade900,
            ),
          ),
          
          const Divider(height: 48),

          // ==========================================
          // ITINERARY LIST
          // ==========================================
          Text(
            'Your Itinerary (${_places.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_places.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Add places above to see them here', style: TextStyle(color: Colors.grey))),
            )
          else
            ..._places.asMap().entries.map((entry) {
              final index = entry.key;
              final place = entry.value;
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(place),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _places.removeAt(index)),
                ),
              );
            }),

          const SizedBox(height: 40),
          
          // Final Submit
          ElevatedButton(
            onPressed: _saveTrip,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(widget.trip == null ? 'Confirm Trip' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
