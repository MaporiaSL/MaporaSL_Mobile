import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/localization/profile_setup_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../domain/user_profile.dart';
import '../domain/profile_validation_constraints.dart';
import 'providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile initialProfile;

  const EditProfileScreen({super.key, required this.initialProfile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _districtController;
  late String _selectedLanguage;
  late Set<String> _selectedInterests;

    List<String> get _languageOptions =>
      ProfileValidationConstraints.supportedLanguages;

    List<String> get _interestOptions =>
      ProfileValidationConstraints.suggestedInterests;

  /// Locally picked image (not yet uploaded)
  File? _pickedImage;
  bool _isUploadingAvatar = false;
  bool _isOptimisticallySaving = false;
  bool _isAccountActionBusy = false;
  String? _inlineError;
  String? _avatarActionMessage;
  String? _lastFailedUploadPath;
  int _avatarCacheBuster = 0;
  late String _currentAvatarUrl;

  ProfileSetupLocalizations get _l10n => ProfileSetupLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _bioController = TextEditingController(text: widget.initialProfile.bio);
    _districtController = TextEditingController(
      text: widget.initialProfile.hometownDistrict,
    );
    _selectedLanguage = widget.initialProfile.preferredLanguage.isNotEmpty
        ? widget.initialProfile.preferredLanguage
        : _languageOptions.first;
    _selectedInterests = widget.initialProfile.travelInterests.toSet();
    _currentAvatarUrl = widget.initialProfile.avatarUrl;

    ProfileValidationConstraints.loadFromAssetIfNeeded().then((_) {
      if (!mounted) return;
      setState(() {
        if (!_languageOptions.contains(_selectedLanguage)) {
          _selectedLanguage = _languageOptions.isNotEmpty
              ? _languageOptions.first
              : 'English';
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  // ─── Avatar Picker ────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: _l10n.cropAvatarTitle,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: _l10n.cropAvatarTitle,
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    setState(() {
      _pickedImage = File(cropped.path);
      _inlineError = null;
      _avatarActionMessage = null;
      _lastFailedUploadPath = null;
    });
  }

  Future<void> _retryAvatarUpload() async {
    if (_lastFailedUploadPath == null) return;
    final editNotifier = ref.read(profileEditProvider.notifier);

    setState(() {
      _isUploadingAvatar = true;
      _inlineError = null;
      _avatarActionMessage = null;
    });

    await editNotifier.uploadAvatar(_lastFailedUploadPath!);

    if (!mounted) return;

    final uploadState = ref.read(profileEditProvider);
    setState(() {
      _isUploadingAvatar = false;
      _inlineError = uploadState.error != null
          ? _l10n.avatarUploadConnectionFailed
          : null;
      _avatarActionMessage = uploadState.error == null
          ? _l10n.avatarUploaded
          : null;
      if (uploadState.error == null) {
        _lastFailedUploadPath = null;
      }
    });
    editNotifier.clearError();
  }

  Future<void> _removeAvatar() async {
    final editNotifier = ref.read(profileEditProvider.notifier);
    setState(() {
      _isUploadingAvatar = true;
      _inlineError = null;
      _avatarActionMessage = null;
    });

    await editNotifier.removeAvatar();
    if (!mounted) return;

    final state = ref.read(profileEditProvider);
    setState(() {
      _isUploadingAvatar = false;
      if (state.error != null) {
        _inlineError = state.error;
        return;
      }

      _pickedImage = null;
      _currentAvatarUrl = '';
      _avatarActionMessage = _l10n.avatarRemovedSuccess;
      _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch;
      _lastFailedUploadPath = null;
    });
    ref.invalidate(userProfileProvider);
    editNotifier.clearError();
  }

  Future<void> _triggerPasswordReset() async {
    final authService = ref.read(authServiceProvider);
    final email = authService.currentUserEmail ?? widget.initialProfile.email;

    if (email.trim().isEmpty) {
      setState(() => _inlineError = _l10n.noEmailForPasswordReset);
      return;
    }

    setState(() {
      _isAccountActionBusy = true;
      _inlineError = null;
    });
    try {
      await authService.sendPasswordResetEmail(email.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.passwordResetSent(email.trim()))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _inlineError = _l10n.accountActionFailed(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isAccountActionBusy = false);
    }
  }

  Future<void> _showChangeEmailDialog() async {
    final controller = TextEditingController();
    final newEmail = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.changeEmail),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: _l10n.newEmail,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(_l10n.continueLabel),
          ),
        ],
      ),
    );

    if (!mounted || newEmail == null || newEmail.isEmpty) return;

    final authService = ref.read(authServiceProvider);
    setState(() {
      _isAccountActionBusy = true;
      _inlineError = null;
    });
    try {
      await authService.requestEmailChange(newEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_l10n.emailChangeVerificationSent(newEmail))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _inlineError = _l10n.accountActionFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _isAccountActionBusy = false);
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.deleteAccount),
        content: Text(_l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_l10n.deleteAccount),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final authService = ref.read(authServiceProvider);
    final userId = ref.read(currentUserIdProvider);
    final repository = ref.read(profileRepositoryProvider);
    if (userId == null) return;

    setState(() {
      _isAccountActionBusy = true;
      _inlineError = null;
    });
    try {
      await repository.deleteAccountData(userId);
      await authService.deleteCurrentUser();
      if (!mounted) return;
      await authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      if (authService.requiresRecentLogin(e)) {
        await _showReauthRequiredDialog();
      } else {
        setState(() => _inlineError = _l10n.deleteAccountFailed);
      }
    } finally {
      if (mounted) setState(() => _isAccountActionBusy = false);
    }
  }

  Future<void> _showReauthRequiredDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.reauthRequiredTitle),
        content: Text(_l10n.reauthRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              if (!mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (_) => false);
            },
            child: Text(_l10n.signInAgain),
          ),
        ],
      ),
    );
  }

  void _showAvatarSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(_l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(_l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _inlineError = _l10n.fieldsInvalid;
      });
      return;
    }

    final editNotifier = ref.read(profileEditProvider.notifier);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final previousStateSnapshot = (
      name: _nameController.text,
      bio: _bioController.text,
      district: _districtController.text,
      language: _selectedLanguage,
      interests: Set<String>.from(_selectedInterests),
    );

    setState(() {
      _isOptimisticallySaving = true;
      _inlineError = null;
      _avatarActionMessage = null;
    });

    // Upload avatar first if a new image was picked
    if (_pickedImage != null) {
      setState(() => _isUploadingAvatar = true);
      await editNotifier.uploadAvatar(_pickedImage!.path);
      setState(() => _isUploadingAvatar = false);

      final uploadState = ref.read(profileEditProvider);
      if (uploadState.error != null) {
        setState(() {
          _isOptimisticallySaving = false;
          _inlineError = _l10n.avatarUploadRetryFailed;
          _lastFailedUploadPath = _pickedImage!.path;
        });
        editNotifier.clearError();
        return;
      }
      _avatarCacheBuster = DateTime.now().millisecondsSinceEpoch;
      _currentAvatarUrl = uploadState.avatarUrl ?? _currentAvatarUrl;
      _avatarActionMessage = _l10n.avatarUploaded;
      _lastFailedUploadPath = null;
    }

    // Save profile details
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();
    final newDistrict = _districtController.text.trim();
    final newInterests = _selectedInterests.toList()..sort();
    final currentInterests = widget.initialProfile.travelInterests.toList()
      ..sort();

    final hasProfileChanges =
        newName != widget.initialProfile.name ||
        newBio != widget.initialProfile.bio ||
        newDistrict != widget.initialProfile.hometownDistrict ||
        _selectedLanguage != widget.initialProfile.preferredLanguage ||
        newInterests.join('|') != currentInterests.join('|');

    if (hasProfileChanges) {
      await editNotifier.updateProfileDetails(
        name: newName,
        bio: newBio,
        hometownDistrict: newDistrict,
        preferredLanguage: _selectedLanguage,
        travelInterests: newInterests,
      );
    }

    if (!mounted) return;

    final finalState = ref.read(profileEditProvider);
    if (finalState.error != null) {
      setState(() {
        _isOptimisticallySaving = false;
        _nameController.text = previousStateSnapshot.name;
        _bioController.text = previousStateSnapshot.bio;
        _districtController.text = previousStateSnapshot.district;
        _selectedLanguage = previousStateSnapshot.language;
        _selectedInterests = previousStateSnapshot.interests;
        _inlineError = _l10n.saveFailed;
      });
      editNotifier.clearError();
      return;
    }

    setState(() {
      _isOptimisticallySaving = false;
    });

    // Invalidate the profile cache so ProfileScreen refreshes
    ref.invalidate(userProfileProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l10n.profileUpdated),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(profileEditProvider);
    final isBusy =
        editState.isLoading ||
        _isUploadingAvatar ||
        _isOptimisticallySaving ||
        _isAccountActionBusy;

    // Determine which avatar to display (priority: newly picked > existing URL > initials)
    Widget avatarWidget;
    if (_pickedImage != null) {
      avatarWidget = CircleAvatar(
        radius: 52,
        backgroundImage: FileImage(_pickedImage!),
      );
    } else if (_currentAvatarUrl.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: 52,
        backgroundImage: NetworkImage(
          '$_currentAvatarUrl?v=$_avatarCacheBuster',
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 52,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          widget.initialProfile.name.isNotEmpty
              ? widget.initialProfile.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 36,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return PopScope(
      canPop: !isBusy,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldDiscard = await _confirmDiscardIfNeeded();
        if (!mounted) return;
        if (shouldDiscard) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_l10n.editProfileTitle),
          actions: [
            if (!isBusy)
              TextButton(
                onPressed: _save,
                child: Text(
                  _l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        body: isBusy
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_l10n.saving),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar section
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          avatarWidget,
                          GestureDetector(
                            onTap: _showAvatarSourceSheet,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isUploadingAvatar
                                ? null
                                : _showAvatarSourceSheet,
                            child: Text(_l10n.changePhoto),
                          ),
                          if (_currentAvatarUrl.isNotEmpty ||
                              _pickedImage != null)
                            TextButton(
                              onPressed: _isUploadingAvatar
                                  ? null
                                  : _removeAvatar,
                              child: Text(_l10n.removeAvatar),
                            ),
                        ],
                      ),
                      if (_isUploadingAvatar)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_l10n.avatarUploadInProgress),
                            ],
                          ),
                        ),
                      if (_avatarActionMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _avatarActionMessage!,
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ),
                      const SizedBox(height: 32),

                      if (_inlineError != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _inlineError!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        maxLength: ProfileValidationConstraints.maxNameLength,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: _l10n.displayName,
                          hintText: _l10n.displayNameHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person_outline),
                          helperText: _l10n.displayNameHelper,
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return _l10n.nameCannotBeEmpty;
                          }
                          if (value.trim().length <
                              ProfileValidationConstraints.minNameLength) {
                            return _l10n.nameMin;
                          }
                          if (value.trim().length >
                              ProfileValidationConstraints.maxNameLength) {
                            return _l10n.nameMax;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: ProfileValidationConstraints.maxBioLength,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: _l10n.description,
                          hintText: _l10n.bioHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.short_text),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.length >
                              ProfileValidationConstraints.maxBioLength) {
                            return _l10n.bioMax;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _districtController,
                        maxLength:
                            ProfileValidationConstraints.maxDistrictLength,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                          labelText: _l10n.hometownDistrict,
                          hintText: _l10n.hometownDistrictHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          helperText: _l10n.hometownDistrictHelper,
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return _l10n.districtCannotBeEmpty;
                          }
                          if (text.length >
                              ProfileValidationConstraints.maxDistrictLength) {
                            return _l10n.districtMax;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue:
                            _languageOptions.contains(_selectedLanguage)
                            ? _selectedLanguage
                            : _languageOptions.first,
                        decoration: InputDecoration(
                          labelText: _l10n.preferredLanguage,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.language),
                        ),
                        items: _languageOptions
                            .map(
                              (language) => DropdownMenuItem<String>(
                                value: language,
                                child: Text(language),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedLanguage = value);
                        },
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _l10n.travelInterestsCount(
                            _selectedInterests.length,
                            ProfileValidationConstraints.maxInterests,
                          ),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _interestOptions.map((interest) {
                          final selected = _selectedInterests.contains(
                            interest,
                          );
                          return FilterChip(
                        if (authService.requiresRecentLogin(e)) {
                          await _showReauthRequiredDialog();
                        } else {
                          setState(() => _inlineError = _l10n.accountActionFailed(e.toString()));
                        }
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  if (_selectedInterests.length <
                                      ProfileValidationConstraints
                                          .maxInterests) {
                                    _selectedInterests.add(interest);
                                  }
                                } else {
                                  _selectedInterests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Email (read-only)
                      TextFormField(
                        initialValue: widget.initialProfile.email,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: _l10n.email,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email_outlined),
                          helperText: _l10n.emailReadOnlyHelper,
                        ),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _l10n.accountSettings,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.lock_reset_outlined),
                              title: Text(_l10n.changePassword),
                              subtitle: Text(_l10n.changePasswordHint),
                              onTap: isBusy ? null : _triggerPasswordReset,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.alternate_email_outlined,
                              ),
                              title: Text(_l10n.changeEmail),
                              subtitle: Text(_l10n.changeEmailHint),
                              onTap: isBusy ? null : _showChangeEmailDialog,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text(
                                _l10n.deleteAccount,
                                style: const TextStyle(color: Colors.red),
                              ),
                              subtitle: Text(_l10n.deleteAccountHint),
                              onTap: isBusy ? null : _confirmAndDeleteAccount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _save,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _l10n.saveChanges,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),

                      if (_lastFailedUploadPath != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _retryAvatarUpload,
                            icon: const Icon(Icons.refresh),
                            label: Text(_l10n.retryAvatarUpload),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  bool _hasUnsavedChanges() {
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();
    final newDistrict = _districtController.text.trim();
    final newInterests = _selectedInterests.toList()..sort();
    final currentInterests = widget.initialProfile.travelInterests.toList()
      ..sort();

    return _pickedImage != null ||
        newName != widget.initialProfile.name ||
        newBio != widget.initialProfile.bio ||
        newDistrict != widget.initialProfile.hometownDistrict ||
        _selectedLanguage != widget.initialProfile.preferredLanguage ||
        newInterests.join('|') != currentInterests.join('|');
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_hasUnsavedChanges()) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.discardChangesTitle),
        content: Text(_l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_l10n.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
