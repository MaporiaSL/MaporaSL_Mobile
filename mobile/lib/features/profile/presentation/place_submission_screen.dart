import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'providers/profile_providers.dart';

class PlaceSubmissionScreen extends ConsumerStatefulWidget {
  const PlaceSubmissionScreen({super.key});

  @override
  ConsumerState<PlaceSubmissionScreen> createState() =>
      _PlaceSubmissionScreenState();
}

class _PlaceSubmissionScreenState extends ConsumerState<PlaceSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _provinceController = TextEditingController(text: 'Western');
  final _districtController = TextEditingController(text: 'Colombo');

  final ImagePicker _picker = ImagePicker();

  String _category = 'other';
  List<XFile> _photos = const [];

  static const List<String> _categories = <String>[
    'temple',
    'beach',
    'mountain',
    'historical',
    'wildlife',
    'city',
    'food',
    'waterfall',
    'garden',
    'cultural',
    'adventure',
    'other',
  ];

  bool get _canSubmit => _photos.length >= 2;

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<({double latitude, double longitude})?> _resolveCoordinates() async {
    final parts = <String>[
      _placeNameController.text.trim(),
      _districtController.text.trim(),
      _provinceController.text.trim(),
      'Sri Lanka',
    ].where((p) => p.isNotEmpty).toList();

    final query = parts.join(', ');
    if (query.isEmpty) return null;

    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;
      final first = locations.first;
      return (latitude: first.latitude, longitude: first.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickPhotos() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (images.isEmpty) return;
    setState(() {
      _photos = images.take(6).toList();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 photos')),
      );
      return;
    }

    final coordinates = await _resolveCoordinates();
    if (coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not determine location automatically. Refine place/province/district and try again.',
          ),
        ),
      );
      return;
    }

    await ref
        .read(placeSubmissionProvider.notifier)
        .submit(
          placeName: _placeNameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          province: _provinceController.text.trim(),
          district: _districtController.text.trim(),
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          photoPaths: _photos.map((p) => p.path).toList(),
        );

    final state = ref.read(placeSubmissionProvider);
    if (!mounted) return;

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${state.error}')),
      );
      return;
    }

    ref.invalidate(userProfileProvider);
    ref.invalidate(userContributionsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Place submitted successfully for review!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(placeSubmissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit New Place')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _placeNameController,
                decoration: const InputDecoration(
                  labelText: 'Place name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 3) return 'Enter at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                minLines: 3,
                maxLength: 400,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  helperText: 'At least 50 characters',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 50)
                    return 'Description must be at least 50 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _provinceController,
                decoration: const InputDecoration(
                  labelText: 'Province',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Province required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'District required'
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: submitState.isSubmitting ? null : _pickPhotos,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _photos.isEmpty
                      ? 'Pick Photos (min 2)'
                      : '${_photos.length} photo(s) selected',
                ),
              ),
              const SizedBox(height: 8),
              if (_photos.isNotEmpty)
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_photos[index].path),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: submitState.isSubmitting ? null : _submit,
                child: submitState.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit for Review'),
              ),
              const SizedBox(height: 8),
              Text(
                'Your submission will be reviewed by admins before it appears publicly.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
