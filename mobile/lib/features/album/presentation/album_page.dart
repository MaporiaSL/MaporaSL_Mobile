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
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show loading
      _showLoading('Uploading photo...');

      final result = await _service.uploadPhotoToLocationAlbum(File(image.path));

      if (mounted) {
        Navigator.pop(context); // Close loading
        _loadAlbums();
        _showMessage('Photo saved to "${result.album.name}"');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createAlbum() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateAlbumDialog(),
    );

    if (name != null && name.isNotEmpty) {
      try {
        await _service.createAlbum(name);
        _loadAlbums();
        _showMessage('Album "$name" created');
      } catch (e) {
        _showMessage('Failed to create album: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Albums'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createAlbum,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: _pickFromGallery,
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.large(
            heroTag: 'camera',
            onPressed: _openCamera,
            child: const Icon(Icons.camera_alt, size: 36),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Failed to load albums'),
            ElevatedButton(onPressed: _loadAlbums, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_album, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No albums yet', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            const Text('Take a photo to get started!'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
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
