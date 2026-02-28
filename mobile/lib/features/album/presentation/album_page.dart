import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemified_travel_portfolio/features/album/widgets/album_card.dart';
import 'package:gemified_travel_portfolio/features/album/widgets/create_album_dialog.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/album_service.dart';
import '../data/models/album_model.dart';
import 'camera_page.dart';
import 'album_detail_page.dart';

/// Main Album page - shows all albums with camera button
class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final AlbumService _service = AlbumService();
  final ImagePicker _picker = ImagePicker();

  List<AlbumModel> _albums = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final albums = await _service.getAlbums();
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (result == true) {
      _loadAlbums();
    }
  }

  Future<void> _pickFromGallery() async {
    bool isLoadingShown = false;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading
      _showLoading('Uploading photo...');
      isLoadingShown = true;

      final result = await _service.uploadPhotoToLocationAlbum(
        File(image.path),
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        isLoadingShown = false;
        _loadAlbums();
        _showMessage('Photo saved to "${result.album.name}"');
      }
    } catch (e) {
      if (mounted) {
        if (isLoadingShown) {
          Navigator.pop(context); // Close loading
        }
        _showMessage('Failed: $e');
      }
    }
  }

  void _showLoading(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createAlbum() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateAlbumDialog(),
    );

    if (name != null && name.isNotEmpty) {
      // Check for duplicate name locally first (case-insensitive)
      final duplicate = _albums.any(
        (a) => a.name.toLowerCase() == name.toLowerCase(),
      );
      if (duplicate) {
        _showMessage('An album named "$name" already exists');
        return;
      }

      try {
        await _service.createAlbum(name);
        _loadAlbums();
        _showMessage('Album "$name" created');
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('409') ||
            msg.toLowerCase().contains('already exists')) {
          _showMessage('An album with this name already exists');
        } else {
          _showMessage('Failed to create album: $e');
        }
      }
    }
  }

  Future<void> _deleteAlbum(AlbumModel album) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Album?'),
        content: Text('Delete "${album.name}" and all its photos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteAlbum(album.id);
        _loadAlbums();
        _showMessage('Album deleted');
      } catch (e) {
        _showMessage('Failed to delete: $e');
      }
    }
  }

  void _openAlbum(AlbumModel album) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AlbumDetailPage(album: album)),
    ).then((_) => _loadAlbums());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Albums'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          // Reserve space for overlay profile icon
          const SizedBox(width: 56),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create album button
          FloatingActionButton.small(
            heroTag: 'create',
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            onPressed: _createAlbum,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          // Gallery picker
          FloatingActionButton.small(
            heroTag: 'gallery',
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            onPressed: _pickFromGallery,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 10),
          // Camera button
          FloatingActionButton.small(
            heroTag: 'camera',
            onPressed: _openCamera,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('Failed to load albums'),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _loadAlbums,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_album_outlined, size: 72, color: Colors.grey[350]),
            const SizedBox(height: 16),
            Text(
              'No albums yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo or create an album',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _albums.length,
        itemBuilder: (_, index) {
          final album = _albums[index];
          return AlbumCard(
            album: album,
            onTap: () => _openAlbum(album),
            onLongPress: () => _deleteAlbum(album),
          );
        },
      ),
    );
  }
}
