import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemified_travel_portfolio/features/album/widgets/album_picker_sheet.dart';
import '../data/models/album_model.dart';
import '../data/services/album_service.dart';

class PhotoPreview extends StatelessWidget {
  final String photoPath;
  final VoidCallback onRetake;

  final VoidCallback? onSaveByLocation;
  final void Function(String albumId)? onSaveToAlbum;
  final VoidCallback? onSaveDirect;
  final VoidCallback? onUpload;

  const PhotoPreview({
    super.key,
    required this.photoPath,
    required this.onRetake,
    this.onSaveByLocation,
    this.onSaveToAlbum,
    this.onSaveDirect,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Photo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(photoPath), fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Actions
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: onSaveDirect != null
                  ? _directActions(context, colorScheme)
                  : _fullActions(context, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  /// When opened from inside an album – just Retake & Save
  Widget _directActions(BuildContext context, ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetake,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retake'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: onSaveDirect,
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// When opened from the main camera (no album context) – 3 options
  Widget _fullActions(BuildContext context, ColorScheme cs) {
    final effectiveSaveByLocation = onSaveByLocation ?? onUpload;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: effectiveSaveByLocation,
                icon: const Icon(Icons.location_on, size: 20),
                label: const Text('By Location'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onSaveToAlbum != null ? () => _pickAlbum(context) : null,
            icon: const Icon(Icons.photo_album, size: 20),
            label: const Text('Save to Album'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _pickAlbum(BuildContext context) async {
    final albumId = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AlbumPickerSheet(),
    );

    if (albumId != null && onSaveToAlbum != null) {
      onSaveToAlbum!(albumId);
    }
  }
}
