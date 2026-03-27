import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../data/places_repository.dart';

class AddDestinationPage extends StatefulWidget {
  const AddDestinationPage({super.key});

  @override
  State<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends State<AddDestinationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _difficultyCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();

  File? _selectedImage;
  String? _selectedCategory;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  final _repository = PlacesRepository();

  final List<String> _categories = [
    'Nature',
    'Historical',
    'Cultural',
    'Adventure',
    'Religious',
    'Beach',
    'Hidden Gem',
    'Waterfall',
    'Hiking',
    'Park',
    'Museum',
    'Restaurant',
    'Viewpoint',
  ];

  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..repeat();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitDestination() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for GPS signal...')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.submitPlace(
        name: _nameCtrl.text,
        category: _selectedCategory ?? 'Other',
        district: _locationCtrl.text,
        description: _descriptionCtrl.text,
        latitude: _latitude!,
        longitude: _longitude!,
        address: _addressCtrl.text,
        difficulty: _difficultyCtrl.text,
        entryFee: double.tryParse(_feeCtrl.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Place submitted for review!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _difficultyCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        title: const Text(
          'DISCOVERY MISSION',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SATELLITE SCANNER / LOCATION STATUS ---
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _scanController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: _SatelliteScanner(
                                        _scanController.value,
                                        _latitude != null,
                                      ),
                                      size: const Size(120, 120),
                                    );
                                  },
                                ),
                                Icon(
                                  _latitude != null ? Icons.gps_fixed : Icons.satellite_alt,
                                  color: _latitude != null ? Colors.green.shade400 : Colors.blue.shade400,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _latitude != null
                                ? '🛰️ SATELLITE UPLINK: ESTABLISHED'
                                : '📡 SEARCHING FOR SIGNAL...',
                            style: TextStyle(
                              color: _latitude != null ? Colors.green.shade400 : Colors.blue.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (_latitude != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- IMAGE UPLOAD BOX ---
                    _buildSectionHeader('VISUAL INTEL (OPTIONAL)'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(
                            color: _selectedImage != null ? Colors.blue.shade400 : Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 32,
                                    color: Colors.blue.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'UPLOAD PHOTO',
                                    style: TextStyle(
                                      color: Colors.blue.shade200,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionHeader('MISSION ASSET DETAILS'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'Place Name',
                      icon: Icons.landscape,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Category', Icons.category),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                              value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _locationCtrl,
                      label: 'District',
                      icon: Icons.pin_drop,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionCtrl,
                      label: 'Discovery intel & tips',
                      maxLines: 4,
                      validator: (v) => v!.length < 10 ? 'Add more intel' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('ADDITIONAL ANALYTICS'),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _buildTextField(controller: _difficultyCtrl, label: 'Difficulty')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(controller: _feeCtrl, label: 'Fee', keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // --- SUBMIT BUTTON ---
                    Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.indigo.shade900],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submitDestination,
                        icon: const Icon(Icons.rocket_launch, size: 20),
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'TRANSMIT DISCOVERY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              '+50 XP DISCOVERY BONUS',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.amber.shade400,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Your submission will be analyzed by the Grid review team before publication.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.blue.shade400,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade400, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
    );
  }
}

class _SatelliteScanner extends CustomPainter {
  final double progress;
  final bool isFixed;

  _SatelliteScanner(this.progress, this.isFixed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Rings
    for (int i = 1; i <= 3; i++) {
      paint.color = (isFixed ? Colors.green : Colors.blue).withOpacity(0.1 + (i * 0.1));
      canvas.drawCircle(center, (size.width / 3) * (i / 1.5), paint);
    }

    // Scanning sweep
    if (!isFixed) {
      final sweepPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..shader = SweepGradient(
          colors: [
            Colors.blue.withOpacity(0),
            Colors.blue.shade400,
          ],
          stops: const [0.7, 1.0],
          transform: GradientRotation(progress * 2 * 3.1415),
        ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

      canvas.drawCircle(center, size.width / 2, sweepPaint);
    } else {
      paint.color = Colors.green.shade400;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SatelliteScanner oldDelegate) => true;
}
