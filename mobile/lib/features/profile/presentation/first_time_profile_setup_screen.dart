import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/local_prefs.dart';
import '../presentation/providers/profile_providers.dart';

class FirstTimeProfileSetupScreen extends ConsumerStatefulWidget {
  const FirstTimeProfileSetupScreen({
    super.key,
    required this.requiredFields,
    required this.optionalFields,
  });

  final List<String> requiredFields;
  final List<String> optionalFields;

  @override
  ConsumerState<FirstTimeProfileSetupScreen> createState() =>
      _FirstTimeProfileSetupScreenState();
}

class _FirstTimeProfileSetupScreenState
    extends ConsumerState<FirstTimeProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _districtController = TextEditingController();
  final _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _language = 'English';
  Set<String> _interests = <String>{};
  File? _avatarFile;
  int _step = 0;
  bool _isSaving = false;
  String? _error;
  Map<String, String> _fieldErrors = <String, String>{};

  static const List<String> _languages = <String>[
    'English',
    'Sinhala',
    'Tamil',
  ];

  static const List<String> _interestOptions = <String>[
    'Nature',
    'Hiking',
    'Wildlife',
    'Food',
    'Culture',
    'History',
    'Photography',
    'Beaches',
    'Adventure',
    'City Tours',
  ];

  @override
  void initState() {
    super.initState();
    _bootstrapDraft();
    _nameController.addListener(_persistDraft);
    _districtController.addListener(_persistDraft);
    _bioController.addListener(_persistDraft);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _districtController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapDraft() async {
    final draft = await LocalPrefs.getProfileSetupDraft();
    if (draft != null) {
      setState(() {
        _nameController.text = (draft['name'] ?? '').toString();
        _districtController.text = (draft['hometownDistrict'] ?? '').toString();
        _bioController.text = (draft['bio'] ?? '').toString();
        _language = (draft['preferredLanguage'] ?? 'English').toString();
        final interests = (draft['travelInterests'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[];
        _interests = interests.toSet();
        final avatarPath = (draft['avatarPath'] ?? '').toString();
        if (avatarPath.isNotEmpty) {
          final file = File(avatarPath);
          if (file.existsSync()) _avatarFile = file;
        }
      });
      return;
    }

    final authService = ref.read(authServiceProvider);
    final district = await LocalPrefs.getHometownDistrict();
    setState(() {
      _nameController.text = authService.currentUserDisplayName?.trim() ?? '';
      _districtController.text = district ?? '';
    });
  }

  Future<void> _persistDraft() async {
    await LocalPrefs.saveProfileSetupDraft({
      'name': _nameController.text.trim(),
      'hometownDistrict': _districtController.text.trim(),
      'bio': _bioController.text.trim(),
      'preferredLanguage': _language,
      'travelInterests': _interests.toList(),
      'avatarPath': _avatarFile?.path,
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;
    setState(() {
      _avatarFile = File(picked.path);
    });
    await _persistDraft();
  }

  Future<void> _saveSetup() async {
    setState(() {
      _fieldErrors = <String, String>{};
      _error = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _step = 0;
      });
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null || userId.isEmpty) {
      setState(() {
        _error = 'Please sign in again to continue setup.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);

      if (_avatarFile != null) {
        final avatarUrl = await repository.uploadAvatar(userId, _avatarFile!.path);
        await repository.updateProfile(userId, avatarUrl: avatarUrl);
      }

      await repository.updateProfile(
        userId,
        name: _nameController.text.trim(),
        hometownDistrict: _districtController.text.trim(),
        preferredLanguage: _language,
        travelInterests: _interests.toList(),
        bio: _bioController.text.trim(),
        completeSetup: true,
      );

      await LocalPrefs.markProfileSetupCompleted(true);
      await LocalPrefs.clearProfileSetupDraft();
      await LocalPrefs.clearHometownDistrict();

      ref.invalidate(profileSetupRequirementProvider);
      ref.invalidate(profileBootstrapProvider);
      ref.invalidate(userProfileProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile setup completed.')),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final fieldErrors = data['fieldErrors'];
        if (fieldErrors is Map) {
          setState(() {
            _fieldErrors = fieldErrors.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            );
            _step = 0;
          });
        }
        setState(() {
          _error = data['error']?.toString() ?? profileActionErrorMessage(e);
        });
      } else {
        setState(() {
          _error = profileActionErrorMessage(e);
        });
      }
    } catch (e) {
      setState(() {
        _error = profileActionErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _isSaving
                ? null
                : () async {
                    final authService = ref.read(authServiceProvider);
                    await authService.signOut();
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _step,
          onStepContinue: () async {
            if (_step < 2) {
              setState(() => _step += 1);
              await _persistDraft();
              return;
            }
            await _saveSetup();
          },
          onStepCancel: () async {
            if (_step == 0) return;
            setState(() => _step -= 1);
            await _persistDraft();
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                FilledButton(
                  onPressed: _isSaving ? null : details.onStepContinue,
                  child: _isSaving && _step == 2
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_step == 2 ? 'Finish Setup' : 'Continue'),
                ),
                const SizedBox(width: 8),
                if (_step > 0)
                  TextButton(
                    onPressed: _isSaving ? null : details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Required Details'),
              isActive: _step >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required: ${widget.requiredFields.join(', ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      errorText: _fieldErrors['name'],
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Name is required';
                      if (value.length < 2) return 'Name must be at least 2 characters';
                      if (value.length > 40) return 'Name must be under 40 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _districtController,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: 'Hometown District *',
                      errorText: _fieldErrors['hometownDistrict'],
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'District is required';
                      if (value.length > 60) return 'District must be under 60 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _language,
                    decoration: InputDecoration(
                      labelText: 'Preferred Language *',
                      errorText: _fieldErrors['preferredLanguage'],
                    ),
                    items: _languages
                        .map((language) => DropdownMenuItem<String>(
                              value: language,
                              child: Text(language),
                            ))
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() => _language = value);
                      await _persistDraft();
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Travel Interests'),
              isActive: _step >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optional: ${widget.optionalFields.join(', ')}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _interestOptions.map((interest) {
                      final selected = _interests.contains(interest);
                      return FilterChip(
                        selected: selected,
                        label: Text(interest),
                        onSelected: (value) async {
                          setState(() {
                            if (value) {
                              if (_interests.length < 10) {
                                _interests.add(interest);
                              }
                            } else {
                              _interests.remove(interest);
                            }
                          });
                          await _persistDraft();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    maxLength: 200,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio (optional)',
                      errorText: _fieldErrors['bio'],
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.length > 200) return 'Bio must be under 200 characters';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Avatar and Confirm'),
              isActive: _step >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add an avatar now or skip and update later.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage:
                            _avatarFile != null ? FileImage(_avatarFile!) : null,
                        child: _avatarFile == null
                            ? const Icon(Icons.person, size: 38)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickAvatar,
                        icon: const Icon(Icons.photo),
                        label: const Text('Choose Avatar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
