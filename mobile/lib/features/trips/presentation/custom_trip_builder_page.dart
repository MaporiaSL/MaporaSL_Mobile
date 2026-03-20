import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

enum _PartyType { solo, duo, fellowship }

class CustomTripBuilderPage extends StatefulWidget {
  const CustomTripBuilderPage({super.key});

  @override
  State<CustomTripBuilderPage> createState() => _CustomTripBuilderPageState();
}

class _CustomTripBuilderPageState extends State<CustomTripBuilderPage> {
  // Form key and controllers for user-entered fields.
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startingPointController =
      TextEditingController();
  final TextEditingController _locationSearchController =
      TextEditingController();

  // Core interactive state used by each quest setup section.
  int _selectedDays = 7;
  _PartyType _selectedParty = _PartyType.solo;

  String _selectedCategory = 'Historical';
  String? _selectedLocationName;
  bool _isCategoryLoading = true;
  String? _categoryLoadError;
  Map<String, List<_CategoryLocation>> _locationsByCategory =
      <String, List<_CategoryLocation>>{};

  static const Color _bgColor = Color(0xFFFDF8EE);

  final List<String> _categoryOptions = const [
    'Historical',
    'Beaches',
    'Adventure',
    'Urban',
    'Religious',
    'Other',
  ];

  @override
  void dispose() {
    _startingPointController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategorizedLocations();
  }

  Future<void> _loadCategorizedLocations() async {
    try {
      final rawJson = await rootBundle.loadString(
        'assets/data/catogorizedlocations.json',
      );
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final categories = decoded['categories'] as Map<String, dynamic>?;

      if (categories == null || categories.isEmpty) {
        throw Exception('No categories found in catogorizedlocations.json');
      }

      final map = <String, List<_CategoryLocation>>{};
      for (final entry in categories.entries) {
        final list = entry.value as List<dynamic>? ?? <dynamic>[];
        map[entry.key] = list
            .whereType<Map<String, dynamic>>()
            .map(_CategoryLocation.fromJson)
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _locationsByCategory = map;
        _isCategoryLoading = false;
        _categoryLoadError = null;
        if (!_locationsByCategory.containsKey(_selectedCategory) &&
            _locationsByCategory.isNotEmpty) {
          _selectedCategory = _locationsByCategory.keys.first;
        }
        _selectedLocationName = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isCategoryLoading = false;
        _categoryLoadError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2C6DB9);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          'Forge Your Quest',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 58,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 10,
                backgroundColor: blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _onGenerateItinerary,
              icon: const Icon(Ionicons.color_wand),
              label: Text(
                'Generate Epic Itinerary',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header reward card.
              _buildBountyCard(blue),
              const SizedBox(height: 22),

              // Section 1: Base Camp.
              _buildSectionTitle('Where does your journey begin?'),
              const SizedBox(height: 10),
              _buildBaseCampField(blue),
              const SizedBox(height: 24),

              // Section 2: Quest Duration.
              _buildSectionTitle('How long is your adventure?'),
              const SizedBox(height: 10),
              _buildDurationCard(blue),
              const SizedBox(height: 24),

              // Section 3: Assemble Your Party.
              _buildSectionTitle('Who joins your party?'),
              const SizedBox(height: 10),
              _buildPartySelector(blue),
              const SizedBox(height: 24),

              // Section 4: The Vibe.
              _buildSectionTitle('What calls to you?'),
              const SizedBox(height: 10),
              _buildVibeSelector(blue),
              const SizedBox(height: 24),

              // Section 5: Pace / Difficulty.
              _buildSectionTitle('Location Search'),
              const SizedBox(height: 10),
              _buildLocationSearchField(blue),
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBountyCard(Color blue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBFD7F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8EB7E8).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDCEBFF),
            ),
            child: const Icon(Ionicons.sparkles, color: Color(0xFF2C6DB9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bounty: +500 XP',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF184C91),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan smart and earn your quest setup reward.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF184C91),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBaseCampField(Color blue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _startingPointController,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'e.g., Colombo, Kandy, Airport',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          prefixIcon: Icon(Ionicons.location, color: blue),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: blue, width: 1.5),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a starting point.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDurationCard(Color blue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFD7F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedDays Days',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Slider(
            value: _selectedDays.toDouble(),
            min: 1,
            max: 14,
            divisions: 13,
            activeColor: blue,
            inactiveColor: const Color(0xFFDCEBFF),
            label: '$_selectedDays',
            onChanged: (value) {
              setState(() => _selectedDays = value.round());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartySelector(Color blue) {
    return Row(
      children: [
        Expanded(
          child: _buildPartyCard(
            title: 'Solo Ranger',
            icon: Ionicons.person,
            selected: _selectedParty == _PartyType.solo,
            onTap: () => setState(() => _selectedParty = _PartyType.solo),
            blue: blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildPartyCard(
            title: 'Dynamic Duo',
            icon: Ionicons.people,
            selected: _selectedParty == _PartyType.duo,
            onTap: () => setState(() => _selectedParty = _PartyType.duo),
            blue: blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildPartyCard(
            title: 'Fellowship',
            icon: Ionicons.people_circle,
            selected: _selectedParty == _PartyType.fellowship,
            onTap: () => setState(() => _selectedParty = _PartyType.fellowship),
            blue: blue,
          ),
        ),
      ],
    );
  }

  Widget _buildPartyCard({
    required String title,
    required IoniconsData icon,
    required bool selected,
    required VoidCallback onTap,
    required Color blue,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: blue),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: blue.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : blue, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibeSelector(Color blue) {
    final activeLocations =
        _locationsByCategory[_selectedCategory] ?? const <_CategoryLocation>[];
    final query = _locationSearchController.text.trim().toLowerCase();
    final filteredLocations = activeLocations.where((item) {
      if (query.isEmpty) return true;
      return item.name.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
    }).toList();

    if (_selectedLocationName != null &&
        !filteredLocations.any((item) => item.name == _selectedLocationName)) {
      _selectedLocationName = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _categoryOptions.contains(_selectedCategory)
              ? _selectedCategory
              : null,
          icon: const Icon(Ionicons.chevron_down_outline),
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: blue, width: 1.5),
            ),
          ),
          items: _categoryOptions
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedCategory = value;
              _selectedLocationName = null;
            });
          },
        ),
        const SizedBox(height: 14),
        if (_isCategoryLoading)
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(blue),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Loading location filters...',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1D4E89),
                ),
              ),
            ],
          )
        else if (_categoryLoadError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8B7B7)),
            ),
            child: Text(
              'Failed to load category locations.',
              style: GoogleFonts.poppins(
                color: const Color(0xFF8A1F1F),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else ...[
          Text(
            'Locations in $_selectedCategory',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D4E89),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLocationName,
            isExpanded: true,
            icon: const Icon(Ionicons.chevron_down_outline),
            decoration: InputDecoration(
              labelText: filteredLocations.isEmpty
                  ? 'No locations found'
                  : 'Select a location',
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: blue, width: 1.5),
              ),
            ),
            items: filteredLocations
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.name,
                    child: Text(
                      '${item.name} (${item.location})',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                )
                .toList(),
            onChanged: filteredLocations.isEmpty
                ? null
                : (value) {
                    setState(() {
                      _selectedLocationName = value;
                    });
                  },
          ),
          if (_selectedLocationName != null) ...[
            const SizedBox(height: 10),
            Text(
              filteredLocations
                      .where((item) => item.name == _selectedLocationName)
                      .map((item) => item.description)
                      .firstOrNull ??
                  '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildLocationSearchField(Color blue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _locationSearchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search location by name or district',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
          prefixIcon: Icon(Ionicons.search_outline, color: blue),
          suffixIcon: _locationSearchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Ionicons.close_circle_outline),
                  onPressed: () {
                    _locationSearchController.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFBFD7F5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _onGenerateItinerary() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startingPoint = _startingPointController.text.trim();
    final selectedLocation = _selectedLocationName ?? 'No location selected';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Quest prepared from $startingPoint for $_selectedDays days. Category: $_selectedCategory. Location: $selectedLocation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _CategoryLocation {
  final String name;
  final String location;
  final String description;

  const _CategoryLocation({
    required this.name,
    required this.location,
    required this.description,
  });

  factory _CategoryLocation.fromJson(Map<String, dynamic> json) {
    return _CategoryLocation(
      name: json['name']?.toString() ?? 'Unknown',
      location: json['location']?.toString() ?? 'Unknown',
      description: json['description']?.toString() ?? '',
    );
  }
}
