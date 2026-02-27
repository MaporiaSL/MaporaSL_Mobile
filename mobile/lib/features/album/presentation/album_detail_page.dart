import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemified_travel_portfolio/features/album/presentation/camera_page.dart';
import 'package:gemified_travel_portfolio/features/album/presentation/photo_viewer_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final ImagePicker _picker = ImagePicker();

  List<PhotoModel> _photos = [];
  bool _isLoading = true;
  bool _isUploading = false;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load photos: $e')),
        );
      }
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

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      await _service.uploadPhoto(widget.album.id, File(image.path));
      _loadPhotos();

      setState(() => _isUploading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded')),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<void> _deletePhoto(PhotoModel photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This cannot be undone.'),
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
        await _service.deletePhoto(widget.album.id, photo.id);
        _loadPhotos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  void _openPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewerPage(
          photos: _photos,
          initialIndex: index,
          onDelete: (photo) async {
            await _service.deletePhoto(widget.album.id, photo.id);
            _loadPhotos();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'camera') _openCamera();
              if (value == 'gallery') _pickFromGallery();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'camera', child: Text('Take photo')),
              const PopupMenuItem(value: 'gallery', child: Text('From gallery')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No photos yet', style: TextStyle(fontSize: 20)),
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

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadPhotos,
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _photos.length,
            itemBuilder: (_, index) {
              final photo = _photos[index];
              return GestureDetector(
                onTap: () => _openPhoto(index),
                onLongPress: () => _deletePhoto(photo),
                child: CachedNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isUploading)
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 16),
                      Text('Uploading...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}