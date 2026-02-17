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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Albums'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => {

            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () => {

            },
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.large(
            heroTag: 'camera',
            onPressed: () => {

            },
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
            onTap: () => () => {

            },
            onLongPress: () => () => {

            },
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
