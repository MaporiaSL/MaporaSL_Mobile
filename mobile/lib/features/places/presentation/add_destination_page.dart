import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../data/places_repository.dart';

class AddDestinationPage extends StatefulWidget {
  const AddDestinationPage({super.key});

  @override
  State<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends State<AddDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _difficultyCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _repository = PlacesRepository();

  File? _selectedImage;
  bool _isLoading = false;
  String? _selectedCategory;
  bool _wheelchairAccessible = false;
  double? _latitude;
  double? _longitude;

  final List<String> _categories = [
    'Historical Site',
    'Temple',
    'Mountain',
    'Park',
    'Beach',
    'Forest',
    'Waterfall',
    'Garden',
    'Museum',
    'Market',
    'Restaurant',
    'Viewpoint',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _requestLocationPermission();
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
        debugPrint('Location: $_latitude, $_longitude');
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<bool> _requestLocationPermission() async {
    final status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      return await Geolocator.requestPermission() == LocationPermission.whileInUse ||
          await Geolocator.requestPermission() == LocationPermission.always;
    }
    return status == LocationPermission.whileInUse || status == LocationPermission.always;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitDestination() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get location. Please try again.')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert category to API format
      final categoryMap = {
        'Historical Site': 'historical',
        'Temple': 'temple',
        'Mountain': 'mountain',
        'Park': 'park',
        'Beach': 'beach',
        'Forest': 'forest',
        'Waterfall': 'waterfall',
        'Garden': 'garden',
        'Museum': 'museum',
        'Market': 'market',
        'Restaurant': 'restaurant',
        'Viewpoint': 'viewpoint',
      };

      await _repository.submitPlace(
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        category: categoryMap[_selectedCategory] ?? 'other',
        district: _locationCtrl.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        address: _addressCtrl.text.isEmpty ? null : _addressCtrl.text.trim(),
        difficulty: _difficultyCtrl.text.isEmpty ? null : _difficultyCtrl.text.trim(),
        entryFee: _feeCtrl.text.isEmpty ? null : double.tryParse(_feeCtrl.text),
        wheelchairAccessible: _wheelchairAccessible ? 'Yes' : 'No',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Place submitted for review!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a Hidden Gem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IMAGE UPLOAD BOX ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.blue.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to upload a photo (Optional)',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- BASIC FIELDS ---
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Place Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.landscape),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter a place name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (v) => v == null ? 'Select a category' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'District / City *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin_drop),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter a location' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Detailed Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description & Tips *',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v!.length < 20
                          ? 'Add a longer description (min 20 chars)'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Additional Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _difficultyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Difficulty',
                              border: OutlineInputBorder(),
                              hintText: 'Easy, Medium, Hard',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _feeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Entry Fee (LKR)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Accessibility
                    CheckboxListTile(
                      value: _wheelchairAccessible,
                      onChanged: (v) {
                        setState(() => _wheelchairAccessible = v ?? false);
                      },
                      title: const Text('Wheelchair Accessible'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 32),

                    // --- SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _submitDestination,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text(
                          'Add to MaporaSL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your submission will be reviewed by our team before appearing publicly.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
