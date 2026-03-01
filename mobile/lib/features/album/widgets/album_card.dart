import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gemified_travel_portfolio/features/album/data/models/album_model.dart';

class AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
      ),
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
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _placeholderIcon(cs),
                    )
                  : _placeholderIcon(cs),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.photoCount} photos',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(ColorScheme cs) {
    return Container(
      color: cs.primaryContainer.withValues(alpha: 0.3),
      child: Icon(
        Icons.photo_album_outlined,
        size: 40,
        color: cs.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
