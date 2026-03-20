import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/profile_setup_localizations.dart';
import 'providers/profile_providers.dart';

class PlaceSubmissionScreen extends ConsumerStatefulWidget {
  const PlaceSubmissionScreen({
    super.key,
    this.initialPhotoPathsForTesting,
    this.coordinateResolverForTesting,
  });

  @visibleForTesting
  final List<String>? initialPhotoPathsForTesting;

  @visibleForTesting
  final Future<({double latitude, double longitude})?> Function(String query)?
  coordinateResolverForTesting;

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

  ProfileSetupLocalizations get _l10n => ProfileSetupLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPhotoPathsForTesting;
    if (initial != null && initial.isNotEmpty) {
      _photos = initial.map((p) => XFile(p)).take(6).toList();
    }
  }

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l10n.selectAtLeast2Photos)));
      return;
    }

    final coordinates = widget.coordinateResolverForTesting != null
        ? await widget.coordinateResolverForTesting!(
            [
              _placeNameController.text.trim(),
              _districtController.text.trim(),
              _provinceController.text.trim(),
              'Sri Lanka',
            ].where((p) => p.isNotEmpty).join(', '),
          )
        : await _resolveCoordinates();
    if (coordinates == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l10n.autoLocationFailed)));
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
        SnackBar(
          content: Text('${_l10n.submissionFailedPrefix} ${state.error}'),
        ),
      );
      return;
    }

    ref.invalidate(userProfileProvider);
    ref.invalidate(userContributionsProvider);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_l10n.placeSubmittedSuccess)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(placeSubmissionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_l10n.submitNewPlaceTitle)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _placeNameController,
                decoration: InputDecoration(
                  labelText: _l10n.placeName,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 3) return _l10n.min3Characters;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                minLines: 3,
                maxLength: 400,
                decoration: InputDecoration(
                  labelText: _l10n.description,
                  helperText: _l10n.atLeast50Characters,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 50) return _l10n.descriptionMin50;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: _l10n.category,
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
                decoration: InputDecoration(
                  labelText: _l10n.province,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? _l10n.provinceRequired
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: _l10n.district,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? _l10n.districtRequired
                    : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: submitState.isSubmitting ? null : _pickPhotos,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _photos.isEmpty
                      ? _l10n.pickPhotosMin2
                      : '${_photos.length} ${_l10n.photosSelectedSuffix}',
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
                    : Text(_l10n.submitForReview),
              ),
              const SizedBox(height: 8),
              Text(
                _l10n.submissionReviewNote,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
