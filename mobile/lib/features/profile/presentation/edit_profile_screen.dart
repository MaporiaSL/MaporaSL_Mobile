import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/user_profile.dart';
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

  /// Locally picked image (not yet uploaded)
  File? _pickedImage;
  bool _isUploadingAvatar = false;
  String? _inlineError;
  String? _lastFailedUploadPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Avatar',
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Avatar',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    setState(() {
      _pickedImage = File(cropped.path);
      _inlineError = null;
      _lastFailedUploadPath = null;
    });
  }

  Future<void> _retryAvatarUpload() async {
    if (_lastFailedUploadPath == null) return;
    final editNotifier = ref.read(profileEditProvider.notifier);

    setState(() {
      _isUploadingAvatar = true;
      _inlineError = null;
    });

    await editNotifier.uploadAvatar(_lastFailedUploadPath!);

    if (!mounted) return;

    final uploadState = ref.read(profileEditProvider);
    setState(() {
      _isUploadingAvatar = false;
      _inlineError = uploadState.error != null
          ? 'Avatar upload failed. Check your connection and try again.'
          : null;
      if (uploadState.error == null) {
        _lastFailedUploadPath = null;
      }
    });
    editNotifier.clearError();
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
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
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
        _inlineError = 'Please correct the highlighted fields.';
      });
      return;
    }

    final editNotifier = ref.read(profileEditProvider.notifier);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    // Upload avatar first if a new image was picked
    if (_pickedImage != null) {
      setState(() => _isUploadingAvatar = true);
      await editNotifier.uploadAvatar(_pickedImage!.path);
      setState(() => _isUploadingAvatar = false);

      final uploadState = ref.read(profileEditProvider);
      if (uploadState.error != null) {
        setState(() {
          _inlineError = 'Avatar upload failed. Tap retry to try again.';
          _lastFailedUploadPath = _pickedImage!.path;
        });
        editNotifier.clearError();
        return;
      }
      _lastFailedUploadPath = null;
    }

    // Save name if it changed
    final newName = _nameController.text.trim();
    if (newName != widget.initialProfile.name) {
      await editNotifier.updateProfile(name: newName);
    }

    if (!mounted) return;

    final finalState = ref.read(profileEditProvider);
    if (finalState.error != null) {
      setState(() {
        _inlineError = 'Save failed. Please try again.';
      });
      editNotifier.clearError();
      return;
    }

    // Invalidate the profile cache so ProfileScreen refreshes
    ref.invalidate(userProfileProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(profileEditProvider);
    final isBusy = editState.isLoading || _isUploadingAvatar;

    // Determine which avatar to display (priority: newly picked > existing URL > initials)
    Widget avatarWidget;
    if (_pickedImage != null) {
      avatarWidget = CircleAvatar(
        radius: 52,
        backgroundImage: FileImage(_pickedImage!),
      );
    } else if (widget.initialProfile.avatarUrl.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: 52,
        backgroundImage: NetworkImage(widget.initialProfile.avatarUrl),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!isBusy)
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: isBusy
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving…'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                                color: Theme.of(context).scaffoldBackgroundColor,
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
                    TextButton(
                      onPressed: _showAvatarSourceSheet,
                      child: const Text('Change photo'),
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        hintText: 'Enter your name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        if (value.trim().length > 40) {
                          return 'Name must be under 40 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (read-only)
                    TextFormField(
                      initialValue: widget.initialProfile.email,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                        helperText: 'Email cannot be changed here',
                      ),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text('Save Changes', style: TextStyle(fontSize: 16)),
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
                          label: const Text('Retry Avatar Upload'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
