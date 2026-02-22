import 'package:flutter/material.dart';
import '../data/models/photo_model.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<PhotoModel> photos;
  final int initialIndex;

  const PhotoViewerPage({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
