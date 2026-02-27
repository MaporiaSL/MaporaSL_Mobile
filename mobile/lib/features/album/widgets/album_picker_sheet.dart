import 'package:flutter/material.dart';
import 'package:gemified_travel_portfolio/features/album/data/models/album_model.dart';
import 'package:gemified_travel_portfolio/features/album/data/services/album_service.dart';

class AlbumPickerSheet extends StatefulWidget {
  final String? excludeAlbumId;
  const AlbumPickerSheet({super.key, this.excludeAlbumId});

  @override
  State<AlbumPickerSheet> createState() => _AlbumPickerSheetState();
}

class _AlbumPickerSheetState extends State<AlbumPickerSheet> {
  final AlbumService _service = AlbumService();
  List<AlbumModel>? _albums;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final albums = await _service.getAlbums();
      final filtered = widget.excludeAlbumId != null
          ? albums.where((a) => a.id != widget.excludeAlbumId).toList()
          : albums;
      if (mounted)
        setState(() {
          _albums = filtered;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              'Choose Album',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_albums == null || _albums!.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No albums found'),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _albums!.length,
                itemBuilder: (_, i) {
                  final album = _albums![i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.photo_album, color: cs.primary),
                    ),
                    title: Text(album.name),
                    subtitle: Text('${album.photoCount} photos'),
                    onTap: () => Navigator.pop(context, album.id),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
