import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gemified_travel_portfolio/features/album/widgets/photo_preview.dart';
import 'package:path_provider/path_provider.dart';
import '../data/services/album_service.dart';

class CameraPage extends StatefulWidget {
  /// If provided, photos are saved directly to this album.
  final String? albumId;

  const CameraPage({super.key, this.albumId});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final AlbumService _service = AlbumService();

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isUploading = false;
  FlashMode _flashMode = FlashMode.auto;
  int _cameraIndex = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _error = 'No cameras available');
        return;
      }
      await _setupCamera(_cameras![_cameraIndex]);
    } catch (e) {
      setState(() => _error = 'Failed to initialize camera: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Camera error: $e');
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _isInitialized = false;
      _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
    });
    await _setupCamera(_cameras![_cameraIndex]);
  }

  void _toggleFlash() async {
    if (_controller == null) return;

    FlashMode next;
    switch (_flashMode) {
      case FlashMode.off:
        next = FlashMode.auto;
        break;
      case FlashMode.auto:
        next = FlashMode.always;
        break;
      default:
        next = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(next);
      setState(() => _flashMode = next);
    } catch (e) {
      // Flash not supported
    }
  }

  IconData _flashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_auto;
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();

      // Save to app directory
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/photos';
      await Directory(path).create(recursive: true);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$path/$fileName';
      await photo.saveTo(filePath);

      setState(() => _isCapturing = false);

      // Show preview
      if (mounted) {
        _showPreview(filePath);
      }
    } catch (e) {
      setState(() => _isCapturing = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to capture: $e')));
      }
    }
  }

  void _showPreview(String photoPath) {
    final hasAlbum = widget.albumId != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PhotoPreview(
        photoPath: photoPath,
        onRetake: () {
          Navigator.pop(context);
          File(photoPath).delete().catchError((_) {});
        },
        // Direct save when inside an album
        onSaveDirect: hasAlbum
            ? () {
                Navigator.pop(context);
                _uploadToAlbum(photoPath, widget.albumId!);
              }
            : null,
        // Save by location (only when NOT inside an album)
        onSaveByLocation: hasAlbum
            ? null
            : () {
                Navigator.pop(context);
                _uploadByLocation(photoPath);
              },
        // Save to chosen album (only when NOT inside an album)
        onSaveToAlbum: hasAlbum
            ? null
            : (albumId) {
                Navigator.pop(context);
                _uploadToAlbum(photoPath, albumId);
              },
      ),
    );
  }

  Future<void> _uploadByLocation(String photoPath) async {
    setState(() => _isUploading = true);

    try {
      final result = await _service.uploadPhotoToLocationAlbum(File(photoPath));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to "${result.album.name}"')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _uploadToAlbum(String photoPath, String albumId) async {
    setState(() => _isUploading = true);

    try {
      await _service.uploadPhoto(albumId, File(photoPath));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo saved')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(child: CameraPreview(_controller!)),

          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context, false),
                ),
                _circleButton(icon: _flashIcon(), onTap: _toggleFlash),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch camera
                _circleButton(
                  icon: Icons.flip_camera_ios,
                  size: 44,
                  onTap: _cameras != null && _cameras!.length > 1
                      ? _switchCamera
                      : null,
                ),
                // Capture button – 64px (was 80)
                GestureDetector(
                  onTap: _isCapturing || _isUploading ? null : _takePhoto,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_isCapturing || _isUploading)
                            ? Colors.grey
                            : Colors.white,
                      ),
                      child: (_isCapturing || _isUploading)
                          ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 44), // balance
              ],
            ),
          ),

          // Upload overlay
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Uploading...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    double size = 40,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.35),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.55),
      ),
    );
  }
}
