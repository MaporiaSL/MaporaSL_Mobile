import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/places_repository.dart';
import '../models/place.dart';

class AddDestinationPage extends ConsumerStatefulWidget {
  const AddDestinationPage({super.key});

  @override
  ConsumerState<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends ConsumerState<AddDestinationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late PlacesRepository _repository;

  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _difficultyCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();

  String _selectedCategory = 'attraction';
  String _selectedDistrict = 'Colombo';
  double? _latitude;
  double? _longitude;
  bool _isLocationLoading = false;
  bool _isLoading = false;

  final List<String> _categories = ['attraction', 'nature', 'historic', 'beach', 'temple', 'forest', 'waterfall', 'other'];
  final List<String> _districts = [
    'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale', 'Nuwara Eliya', 
    'Galle', 'Matara', 'Hambantota', 'Jaffna', 'Kilinochchi', 'Mannar', 
    'Vavuniya', 'Mullaitivu', 'Batticaloa', 'Ampara', 'Trincomalee', 
    'Kurunegala', 'Puttalam', 'Anuradhapura', 'Polonnaruwa', 'Badulla', 
    'Moneragala', 'Ratnapura', 'Kegalle'
  ];

  @override
  void initState() {
    super.initState();
    _repository = ref.read(placesRepositoryProvider);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for GPS satellite link...')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _repository.submitPlace(
        name: _nameCtrl.text,
        description: _descriptionCtrl.text,
        category: _selectedCategory,
        district: _selectedDistrict,
        latitude: _latitude!,
        longitude: _longitude!,
        address: _addressCtrl.text,
        difficulty: _difficultyCtrl.text,
        entryFee: double.tryParse(_feeCtrl.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🚀 Hidden gem discovered and uploaded!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _difficultyCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'EXPLORATION HUB',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: theme.hintColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
            tabs: const [
              Tab(text: 'NEW DISCOVERY'),
              Tab(text: 'PLACES DATABASE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: DISCOVERY FORM
            _isLoading
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- SATELLITE SCANNER STATUS ---
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.radar_rounded,
                                  size: 80,
                                  color: (_latitude != null ? Colors.green : colorScheme.primary).withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _latitude != null
                                      ? '🛰️ SATELLITE UPLINK: ESTABLISHED'
                                      : '📡 SEARCHING FOR SIGNAL...',
                                  style: TextStyle(
                                    color: _latitude != null ? Colors.green.shade400 : colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildTextField(context: context, controller: _nameCtrl, label: 'PLACE NAME', icon: Icons.map, validator: (v) => v!.isEmpty ? 'Name required' : null),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: _inputDecoration(context, 'CATEGORY', Icons.category),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v!),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedDistrict,
                            decoration: _inputDecoration(context, 'DISTRICT', Icons.location_city),
                            items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setState(() => _selectedDistrict = v!),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(context: context, controller: _descriptionCtrl, label: 'DESCRIPTION', icon: Icons.description, maxLines: 3),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 8,
                              ),
                              child: const Text('UPLOAD TO GRID', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            // TAB 2: PLACES LIST
            _PlacesDatabaseView(repository: _repository),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, [IconData? icon]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.hintColor, fontSize: 13, fontWeight: FontWeight.bold),
      prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary, size: 20) : null,
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildTextField({required BuildContext context, required TextEditingController controller, required String label, IconData? icon, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(context, label, icon),
    );
  }
}

class _PlacesDatabaseView extends StatefulWidget {
  final PlacesRepository repository;
  const _PlacesDatabaseView({required this.repository});

  @override
  State<_PlacesDatabaseView> createState() => _PlacesDatabaseViewState();
}

class _PlacesDatabaseViewState extends State<_PlacesDatabaseView> with AutomaticKeepAliveClientMixin {
  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await widget.repository.getPlaces(limit: 100);
      if (mounted) setState(() { _places = results; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Grid Fault: $_error', textAlign: TextAlign.center),
            TextButton(onPressed: _load, child: const Text('RETRY UPLINK')),
          ],
        ),
      );
    }
    
    if (_places.isEmpty) return const Center(child: Text('NO HIDDEN GEMS IN DATABASE'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        final place = _places[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (place.photos != null && place.photos!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: place.photos![0],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: theme.cardColor),
                    errorWidget: (context, url, error) => Container(color: theme.cardColor, child: const Icon(Icons.broken_image)),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(place.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text((place.category ?? 'OTHER').toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 9)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(place.district ?? 'Sri Lanka', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
