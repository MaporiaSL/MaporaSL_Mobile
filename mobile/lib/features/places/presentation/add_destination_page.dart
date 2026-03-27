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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'DISCOVERY MISSION',
          style: textTheme.labelLarge?.copyWith(
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
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
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
                                        colorScheme.primary,
                                      ),
                                      size: const Size(120, 120),
                                    );
                                  },
                                ),
                                Icon(
                                  _latitude != null ? Icons.gps_fixed : Icons.satellite_alt,
                                  color: _latitude != null ? Colors.green.shade400 : colorScheme.primary,
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
                              color: _latitude != null ? Colors.green.shade400 : colorScheme.primary,
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
                                style: textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
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
                    _buildSectionHeader(context, 'VISUAL INTEL (OPTIONAL)'),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                          border: Border.all(
                            color: _selectedImage != null ? colorScheme.primary : theme.dividerColor.withOpacity(0.1),
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
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'UPLOAD PHOTO',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
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

                    _buildSectionHeader(context, 'MISSION ASSET DETAILS'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      controller: _nameCtrl,
                      label: 'Place Name',
                      icon: Icons.landscape,
                      validator: (v) => v!.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      dropdownColor: theme.cardColor,
                      style: textTheme.bodyMedium,
                      decoration: _inputDecoration(context, 'Category', Icons.category),
                      items: _categories
                          .map((cat) => DropdownMenuItem(
                              value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      controller: _locationCtrl,
                      label: 'District',
                      icon: Icons.pin_drop,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      context: context,
                      controller: _descriptionCtrl,
                      label: 'Discovery intel & tips',
                      maxLines: 4,
                      validator: (v) => v!.length < 10 ? 'Add more intel' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader(context, 'ADDITIONAL ANALYTICS'),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _buildTextField(context: context, controller: _difficultyCtrl, label: 'Difficulty')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(context: context, controller: _feeCtrl, label: 'Fee', keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // --- SUBMIT BUTTON ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
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
                            Text(
                              'TRANSMIT DISCOVERY',
                              style: textTheme.labelLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            Text(
                              '+50 XP DISCOVERY BONUS',
                              style: textTheme.labelSmall?.copyWith(
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
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Opacity(
                      opacity: 0.6,
                      child: Text(
                        'Your submission will be analyzed by the Grid review team before publication.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, [IconData? icon]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: theme.hintColor,
        fontSize: 13,
      ),
      prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary, size: 20) : null,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyMedium,
      decoration: _inputDecoration(context, label, icon),
    );
  }
}

class _SatelliteScanner extends CustomPainter {
  final double progress;
  final bool isFixed;
  final Color primaryColor;

  _SatelliteScanner(this.progress, this.isFixed, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Rings
    for (int i = 1; i <= 3; i++) {
      paint.color = (isFixed ? Colors.green : primaryColor).withOpacity(0.1 + (i * 0.1));
      canvas.drawCircle(center, (size.width / 3) * (i / 1.5), paint);
    }

    // Scanning sweep
    if (!isFixed) {
      final sweepPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..shader = SweepGradient(
          colors: [
            primaryColor.withOpacity(0),
            primaryColor,
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
