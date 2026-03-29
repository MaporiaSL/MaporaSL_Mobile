import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';

import '../data/models/trip_model.dart';
import '../data/models/trip_dto.dart';
import 'providers/trips_provider.dart';
import '../../places/data/places_repository.dart';

class CreateTripPage extends ConsumerStatefulWidget {
  final TripModel? trip; 
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
  List<String> _categories = ['all', 'nature', 'historic', 'beach', 'temple', 'forest', 'waterfall', 'other'];
  List<String> _availablePlaces = [];
  bool _isFetchingPlaces = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.trip?.title ?? '');
    _descriptionCtrl = TextEditingController(text: widget.trip?.description ?? '');
    _startingLocationCtrl = TextEditingController(
      text: widget.trip?.startingPoint ?? '',
    );
    _startDate = widget.trip?.startDate ?? DateTime.now();
    _endDate = widget.trip?.endDate ?? DateTime.now().add(const Duration(days: 1));
    _places = List.from(widget.initialDestinations);
    if (widget.trip?.locations != null) {
      for (final loc in widget.trip!.locations!) {
        if (!_places.contains(loc.name)) _places.add(loc.name);
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
          final Set<String> merged = {'all', 'nature', 'historic', 'beach', 'temple', 'forest', 'waterfall', 'other'};
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

  Future<void> _saveTrip() async {
    if (_titleCtrl.text.isEmpty) {
      _showError('Trip Title is required');
      return;
    }
    if (_places.isEmpty) {
      _showError('Add at least one place to your trip');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final locations = _places.map((p) => TripLocation(name: p, day: 1)).toList();
      // If trip has an empty ID, it's a "Create" flow from a template or a new trip
      if (widget.trip == null || widget.trip!.id.isEmpty) {
        final dto = CreateTripDto(
          title: _titleCtrl.text,
          description: _descriptionCtrl.text,
          startDate: _startDate,
          endDate: _endDate,
          locations: locations,
          startingPoint: _startingLocationCtrl.text,
          status: 'planned', // Default status for new trips
        );
        await ref.read(tripsProvider.notifier).createTrip(dto);
      } else {
        final dto = UpdateTripDto(
          title: _titleCtrl.text,
          description: _descriptionCtrl.text,
          startDate: _startDate,
          endDate: _endDate,
          locations: locations,
        );
        await ref.read(tripsProvider.notifier).updateTrip(widget.trip!.id, dto);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip Saved Successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showError('Could not save trip: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.shade900));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isNew = widget.trip == null || widget.trip!.id.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isNew ? 'PLAN NEW TRIP' : 'EDIT TRIP DETAILS',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13),
        ),
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionHeader('BASIC INFO'),
          const SizedBox(height: 16),
          _buildThemedField(controller: _titleCtrl, label: 'TRIP NAME', icon: Ionicons.trail_sign_outline),
          const SizedBox(height: 16),
          _buildThemedField(controller: _descriptionCtrl, label: 'DESCRIPTION', icon: Ionicons.document_text_outline, maxLines: 2),
          const SizedBox(height: 16),
          _buildThemedField(controller: _startingLocationCtrl, label: 'STARTING POINT', icon: Ionicons.navigate_outline),
          
          const SizedBox(height: 32),
          _buildSectionHeader('SELECT DATES'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateTile('START DATE', _startDate, () async {
                final picked = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (picked != null) setState(() => _startDate = picked);
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildDateTile('END DATE', _endDate, () async {
                final picked = await showDatePicker(context: context, initialDate: _endDate, firstDate: _startDate, lastDate: DateTime.now().add(const Duration(days: 365)));
                if (picked != null) setState(() => _endDate = picked);
              })),
            ],
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('ADD PLACES'),
          const SizedBox(height: 16),
          _buildPlacePicker(),

          const SizedBox(height: 32),
          _buildSectionHeader('YOUR ROUTE'),
          const SizedBox(height: 16),
          _buildItineraryList(),

          const SizedBox(height: 48),
          SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                shadowColor: colorScheme.primary.withOpacity(0.5),
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SAVE TRIP TO TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }

  Widget _buildThemedField({required TextEditingController controller, required String label, IconData? icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white24, size: 18) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(DateFormat('MMM dd').format(date), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  onSelected: (s) {
                    setState(() => _selectedCategory = cat);
                    _loadPlacesBySelectedCategory();
                  },
                  backgroundColor: Colors.white.withOpacity(0.05),
                  selectedColor: colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: colorScheme.primary,
                  labelStyle: TextStyle(color: isSelected ? colorScheme.primary : Colors.white60),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPlace,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A1A),
              hint: _isFetchingPlaces ? const Text('SEARCHING...', style: TextStyle(color: Colors.white38, fontSize: 13)) : const Text('SELECT PLACE', style: TextStyle(color: Colors.white38, fontSize: 13)),
              items: _availablePlaces.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: Colors.white, fontSize: 14)))).toList(),
              onChanged: (val) {
                setState(() => _selectedPlace = val);
                if (val != null && !_places.contains(val)) {
                  setState(() { _places.add(val); _selectedPlace = null; });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItineraryList() {
    if (_places.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05), style: BorderStyle.solid)),
        child: const Center(child: Text('NO PLACES ADDED', style: TextStyle(color: Colors.white12, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
      );
    }
    return Column(
      children: _places.asMap().entries.map((entry) {
        final i = entry.key;
        final p = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Column(
                children: [
                  Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)), child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white60, fontSize: 10)))),
                  if (i < _places.length - 1) Container(width: 1, height: 30, color: Colors.white12),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Expanded(child: Text(p, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      IconButton(icon: const Icon(Ionicons.close_circle_outline, color: Colors.white24, size: 18), onPressed: () => setState(() => _places.removeAt(i))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
