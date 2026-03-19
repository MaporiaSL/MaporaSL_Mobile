import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_profile.dart';
import 'providers/profile_providers.dart';

class ResubmitContributionScreen extends ConsumerStatefulWidget {
  const ResubmitContributionScreen({super.key, required this.contribution});

  final ContributedPlace contribution;

  @override
  ConsumerState<ResubmitContributionScreen> createState() =>
      _ResubmitContributionScreenState();
}

class _ResubmitContributionScreenState
    extends ConsumerState<ResubmitContributionScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _provinceController;
  late final TextEditingController _districtController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contribution.name);
    _descriptionController = TextEditingController(
      text: widget.contribution.description,
    );
    _categoryController = TextEditingController(
      text: widget.contribution.category,
    );
    _provinceController = TextEditingController(
      text: widget.contribution.province,
    );
    _districtController = TextEditingController(
      text: widget.contribution.district,
    );
    _latitudeController = TextEditingController(
      text: (widget.contribution.latitude ?? 0).toString(),
    );
    _longitudeController = TextEditingController(
      text: (widget.contribution.longitude ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resubmitProvider);

    ref.listen(resubmitProvider, (prev, next) {
      if (!mounted) return;
      if (next.success == true && prev?.success != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution resubmitted for review.')),
        );
        Navigator.pop(context, true);
      }
      if ((next.error ?? '').isNotEmpty && next.error != prev?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Resubmit Contribution')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((widget.contribution.rejectionReason ?? '').isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Rejection reason: ${widget.contribution.rejectionReason}',
                ),
              ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Place name'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Place name is required'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Description is required';
                if (v.trim().length < 50)
                  return 'Description must be at least 50 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Category is required'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _provinceController,
              decoration: const InputDecoration(labelText: 'Province'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Province is required'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _districtController,
              decoration: const InputDecoration(labelText: 'District'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'District is required'
                  : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Invalid latitude'
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    validator: (v) => double.tryParse(v ?? '') == null
                        ? 'Invalid longitude'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: state.isSubmitting ? null : _resubmit,
              icon: state.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_outlined),
              label: Text(state.isSubmitting ? 'Submitting...' : 'Resubmit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resubmit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(resubmitProvider.notifier)
        .resubmit(
          submissionId: widget.contribution.id,
          placeName: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          province: _provinceController.text.trim(),
          district: _districtController.text.trim(),
          latitude: double.parse(_latitudeController.text.trim()),
          longitude: double.parse(_longitudeController.text.trim()),
        );

    ref.invalidate(userContributionsProvider);
    ref.invalidate(userProfileProvider);
  }
}
