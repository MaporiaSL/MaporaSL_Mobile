import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gemified_travel_portfolio/features/album/presentation/camera_page.dart';
import '../data/services/album_service.dart';
import '../data/models/album_model.dart';
import '../data/models/photo_model.dart';

class AlbumDetailPage extends StatefulWidget {
  final AlbumModel album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  final AlbumService _service = AlbumService();

  List<PhotoModel> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final album = await _service.getAlbum(widget.album.id);
      setState(() {
        _photos = album.photos ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );

    if (result == true) {
      _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.album.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
              ? const Center(child: Text("No photos yet"))
              : RefreshIndicator(
                  onRefresh: _loadPhotos,
                  child: GridView.builder(
                    itemCount: _photos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (_, index) {
                      final photo = _photos[index];
                      return CachedNetworkImage(
                        imageUrl: photo.url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}