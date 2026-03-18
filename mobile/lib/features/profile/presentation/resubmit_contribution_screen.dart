import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/user_profile.dart';
import 'providers/profile_providers.dart';

class ResubmitContributionScreen extends ConsumerStatefulWidget {
  const ResubmitContributionScreen({super.key, required this.contribution});

  final ContributedPlace contribution;

  @override
  ConsumerState<ResubmitContributionScreen> createState() => _ResubmitContributionScreenState();
}

class _ResubmitContributionScreenState extends ConsumerState<ResubmitContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _placeNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  String _category = 'other';
  List<XFile> _newPhotos = const [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _placeNameController = TextEditingController(text: widget.contribution.name);
    _descriptionController = TextEditingController(text: widget.contribution.description);
    _provinceController = TextEditingController(text: widget.contribution.province ?? 'Western');
    _districtController = TextEditingController(text: widget.contribution.district ?? 'Colombo');
    _latitudeController = TextEditingController(
      text: widget.contribution.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.contribution.longitude?.toString() ?? '',
    );
    _category = widget.contribution.category ?? 'other';
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final selected = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
    if (selected.isEmpty) return;
    setState(() {
      _newPhotos = selected.take(6).toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude and longitude are required')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.resubmitContribution(
        widget.contribution.id,
        placeName: _placeNameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        province: _provinceController.text.trim(),
        district: _districtController.text.trim(),
        latitude: lat,
        longitude: lng,
        photoPaths: _newPhotos.map((x) => x.path).toList(),
      );

      ref.invalidate(userContributionsProvider);
      ref.invalidate(userProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission resubmitted for review')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resubmit failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resubmit Contribution')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _placeNameController,
              decoration: const InputDecoration(labelText: 'Place name', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().length < 3) ? 'Minimum 3 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              maxLength: 400,
              decoration: const InputDecoration(
                labelText: 'Description',
                helperText: 'At least 50 characters',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().length < 50) ? 'Minimum 50 characters' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _provinceController,
              decoration: const InputDecoration(labelText: 'Province', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickPhotos,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_newPhotos.isEmpty
                  ? 'Add new photos (optional)'
                  : '${_newPhotos.length} new photo(s) selected'),
            ),
            if (_newPhotos.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newPhotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_newPhotos[i].path),
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Resubmit'),
            ),
          ],
        ),
      ),
    );
  }
}
