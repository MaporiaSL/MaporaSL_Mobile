import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: const Center(
        child: Text('Album Detail Page'),
      ),
    );
  }
}