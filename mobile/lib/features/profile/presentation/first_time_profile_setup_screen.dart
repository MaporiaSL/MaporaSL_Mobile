import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/profile_setup_localizations.dart';
import '../../../core/services/local_prefs.dart';
import 'providers/profile_providers.dart';

class FirstTimeProfileSetupScreen extends ConsumerStatefulWidget {
  const FirstTimeProfileSetupScreen({
    super.key,
    required this.requiredFields,
    required this.optionalFields,
    this.showAvatarPreview = true,
  });

  final List<String> requiredFields;
  final List<String> optionalFields;
  final bool showAvatarPreview;

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
  String? _avatarUploadError;
  bool _avatarUploadFailed = false;
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

  ProfileSetupLocalizations get _l10n => ProfileSetupLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    logProfileTelemetry('setup_started');
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
        final interests =
            (draft['travelInterests'] as List?)
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
      _avatarUploadFailed = false;
      _avatarUploadError = null;
      _fieldErrors.remove('avatarUrl');
    });
    await _persistDraft();
  }

  void _clearFieldError(String key) {
    if (!_fieldErrors.containsKey(key)) return;
    setState(() {
      _fieldErrors.remove(key);
    });
  }

  Widget _fieldTypeChip({required bool required}) {
    final background = required ? Colors.red.shade50 : Colors.blueGrey.shade50;
    final foreground = required
        ? Colors.red.shade700
        : Colors.blueGrey.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withOpacity(0.25)),
      ),
      child: Text(
        required ? _l10n.requiredTag : _l10n.optionalTag,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inlineServerFieldError(String fieldName) {
    final message = _fieldErrors[fieldName];
    if (message == null || message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _retryAvatarUpload() async {
    if (_avatarFile == null || _isSaving) return;

    logProfileTelemetry(
      'avatar_upload_retried',
      details: {'hasLocalAvatar': _avatarFile != null},
    );

    final userId = ref.read(currentUserIdProvider);
    if (userId == null || userId.isEmpty) {
      setState(() {
        _error = _l10n.sessionExpired;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
      _avatarUploadError = null;
      _fieldErrors.remove('avatarUrl');
    });

    try {
      final repository = ref.read(profileRepositoryProvider);
      final avatarUrl = await repository.uploadAvatar(
        userId,
        _avatarFile!.path,
      );
      await repository.updateProfile(userId, avatarUrl: avatarUrl);

      if (!mounted) return;
      setState(() {
        _avatarUploadFailed = false;
        _avatarUploadError = null;
        _avatarFile = null;
      });
      await _persistDraft();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l10n.avatarUploaded)));
      logProfileTelemetry('avatar_upload_retry_succeeded');
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = profileActionErrorMessage(e);
      if (data is Map<String, dynamic>) {
        message = data['error']?.toString() ?? message;
      }
      if (!mounted) return;
      setState(() {
        _avatarUploadFailed = true;
        _avatarUploadError = message;
        _fieldErrors['avatarUrl'] = message;
        _error = message;
      });
      logProfileTelemetry(
        'avatar_upload_retry_failed',
        details: {'statusCode': e.response?.statusCode},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _avatarUploadFailed = true;
        _avatarUploadError = profileActionErrorMessage(e);
        _fieldErrors['avatarUrl'] = _avatarUploadError!;
        _error = _avatarUploadError;
      });
      logProfileTelemetry('avatar_upload_retry_failed_unknown');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _saveSetup() async {
    setState(() {
      _fieldErrors = <String, String>{};
      _error = null;
      _avatarUploadError = null;
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
        _error = _l10n.sessionExpired;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);

      if (_avatarFile != null) {
        try {
          final avatarUrl = await repository.uploadAvatar(
            userId,
            _avatarFile!.path,
          );
          await repository.updateProfile(userId, avatarUrl: avatarUrl);
          if (mounted) {
            setState(() {
              _avatarUploadFailed = false;
              _avatarUploadError = null;
              _fieldErrors.remove('avatarUrl');
              _avatarFile = null;
            });
          }
          await _persistDraft();
        } on DioException catch (e) {
          final data = e.response?.data;
          String message = profileActionErrorMessage(e);
          if (data is Map<String, dynamic>) {
            message = data['error']?.toString() ?? message;
          }
          setState(() {
            _avatarUploadFailed = true;
            _avatarUploadError = message;
            _fieldErrors['avatarUrl'] = message;
            _error = message;
            _step = 2;
          });
          logProfileTelemetry(
            'avatar_upload_failed',
            details: {'statusCode': e.response?.statusCode},
          );
          return;
        }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_l10n.setupCompleted)));
      logProfileTelemetry(
        'setup_completed',
        details: {'selectedInterestsCount': _interests.length},
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
        title: Text(_l10n.screenTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: _l10n.logout,
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
                      : Text(
                          _step == 2 ? _l10n.finishSetup : _l10n.continueLabel,
                        ),
                ),
                const SizedBox(width: 8),
                if (_step > 0)
                  TextButton(
                    onPressed: _isSaving ? null : details.onStepCancel,
                    child: Text(_l10n.back),
                  ),
              ],
            );
          },
          steps: [
            Step(
              title: Text(_l10n.requiredDetails),
              isActive: _step >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _fieldTypeChip(required: true),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.requiredFields.join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: _l10n.nameRequiredLabel,
                      errorText: _fieldErrors['name'],
                    ),
                    onChanged: (_) => _clearFieldError('name'),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return _l10n.nameRequired;
                      if (value.length < 2) return _l10n.nameMin;
                      if (value.length > 40) return _l10n.nameMax;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _districtController,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: _l10n.districtRequiredLabel,
                      errorText: _fieldErrors['hometownDistrict'],
                    ),
                    onChanged: (_) => _clearFieldError('hometownDistrict'),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return _l10n.districtRequired;
                      if (value.length > 60) return _l10n.districtMax;
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _language,
                    decoration: InputDecoration(
                      labelText: _l10n.languageRequiredLabel,
                      errorText: _fieldErrors['preferredLanguage'],
                    ),
                    items: _languages
                        .map(
                          (language) => DropdownMenuItem<String>(
                            value: language,
                            child: Text(language),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      setState(() {
                        _language = value;
                        _fieldErrors.remove('preferredLanguage');
                      });
                      await _persistDraft();
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: Text(_l10n.travelInterests),
              isActive: _step >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _fieldTypeChip(required: false),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.optionalFields.join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _fieldErrors.containsKey('travelInterests')
                            ? Colors.red.shade300
                            : Colors.transparent,
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _interestOptions.map((interest) {
                        final selected = _interests.contains(interest);
                        return FilterChip(
                          selected: selected,
                          label: Text(interest),
                          onSelected: (value) async {
                            setState(() {
                              _fieldErrors.remove('travelInterests');
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
                  ),
                  _inlineServerFieldError('travelInterests'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    maxLength: 200,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: _l10n.bioOptionalLabel,
                      errorText: _fieldErrors['bio'],
                    ),
                    onChanged: (_) => _clearFieldError('bio'),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.length > 200) return _l10n.bioMax;
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Step(
              title: Text(_l10n.avatarAndConfirm),
              isActive: _step >= 2,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _fieldTypeChip(required: false),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_l10n.avatarHelper)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundImage:
                            widget.showAvatarPreview && _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : null,
                        child: _avatarFile == null
                            ? const Icon(Icons.person, size: 38)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickAvatar,
                        icon: const Icon(Icons.photo),
                        label: Text(_l10n.chooseAvatar),
                      ),
                    ],
                  ),
                  _inlineServerFieldError('avatarUrl'),
                  if (_avatarUploadFailed) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      button: true,
                      label: _l10n.retryAvatarSemantics,
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _retryAvatarUpload,
                        icon: const Icon(Icons.refresh),
                        label: Text(_l10n.retryAvatarUpload),
                      ),
                    ),
                  ],
                  if (_avatarUploadError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _avatarUploadError!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_error != null)
                    Semantics(
                      liveRegion: true,
                      label: _error,
                      child: Container(
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
