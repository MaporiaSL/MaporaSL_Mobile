import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemified_travel_portfolio/features/album/data/models/album_model.dart';

class AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AlbumCard({
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
