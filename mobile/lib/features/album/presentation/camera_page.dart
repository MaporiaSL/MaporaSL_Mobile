import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../data/services/album_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
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
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _error = "No cameras available");
        return;
      }
      await _setupCamera(_cameras![_cameraIndex]);
    } catch (e) {
      setState(() => _error = "Failed to initialize camera: $e");
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
      setState(() => _error = "Camera error: $e");
    }
  }

  Future<void> _takePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isUploading) return;

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/photos";
      await Directory(path).create(recursive: true);

      final filePath =
          "$path/${DateTime.now().millisecondsSinceEpoch}.jpg";

      await photo.saveTo(filePath);

      setState(() => _isCapturing = false);

      if (mounted) {
        _showPreview(filePath);
      }
    } catch (e) {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _uploadPhoto(String photoPath) async {
    setState(() => _isUploading = true);

    try {
      final result = await _service
          .uploadPhotoToLocationAlbum(File(photoPath));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to "${result.album.name}"'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isUploading = false);
    }
  }

  void _showPreview(String photoPath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => _PhotoPreview(
        photoPath: photoPath,
        onUpload: () {
          Navigator.pop(context);
          _uploadPhoto(photoPath);
        },
        onRetake: () {
          Navigator.pop(context);
          File(photoPath).delete().catchError((_) {});
        },
      ),
    );
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() {
      _cameraIndex = (_cameraIndex + 1) % _cameras!.length;
      _isInitialized = false;
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
    await _controller!.setFlashMode(next);
    setState(() => _flashMode = next);
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

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Camera")),
        body: Center(child: Text(_error!)),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),

          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(_flashIcon(), color: Colors.white),
              onPressed: _toggleFlash,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 40,
            child: IconButton(
              icon: const Icon(Icons.flip_camera_ios,
                  color: Colors.white),
              onPressed: _switchCamera,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String photoPath;
  final VoidCallback onUpload;
  final VoidCallback onRetake;

  const _PhotoPreview({
    required this.photoPath,
    required this.onUpload,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Expanded(
            child: Image.file(File(photoPath),
                fit: BoxFit.contain),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: onRetake,
                child: const Text("Retake"),
              ),
              ElevatedButton(
                onPressed: onUpload,
                child: const Text("Save to Album"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
