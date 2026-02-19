import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/services/album_service.dart';
import '../data/models/album_model.dart';

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

      final result = await _service.uploadPhotoToLocationAlbum(
        File(image.path),
      );

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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _createAlbum() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateAlbumDialog(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Albums'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => {})],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => {},
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.large(
            heroTag: 'camera',
            onPressed: () => {},
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
              onPressed: () {},
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
          return _AlbumCard(
            album: album,
            onTap: () =>
                () => {},
            onLongPress: () =>
                () => {},
          );
        },
      ),
    );
  }
}

/// Album card widget
class _AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AlbumCard({
    required this.album,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: album.coverPhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: album.coverPhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => _placeholderIcon(),
                    )
                  : _placeholderIcon(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${album.photoCount} photos',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.photo_album, size: 48, color: Colors.grey),
    );
  }
}
