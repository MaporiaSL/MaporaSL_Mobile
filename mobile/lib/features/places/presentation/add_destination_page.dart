import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddDestinationPage extends StatefulWidget {
  const AddDestinationPage({super.key});

  @override
  State<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends State<AddDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  // Function to open the phone's gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to save to your database
  Future<void> _submitDestination() async {
    if (!_formKey.currentState!.validate()) return;

    // Image is optional for testing purposes
    // if (_selectedImage == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please upload a photo of the place!')),
    //   );
    //   return;
    // }

    setState(() => _isLoading = true);

    try {
      // ==========================================
      // DATABASE CONNECTION GOES HERE
      // You will use http.MultipartRequest to send the text AND the image
      // to your Node.js backend.
      // ==========================================

      // Simulating a network delay for now
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Destination sent for review!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context); // Go back to Home Page
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a Hidden Gem',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IMAGE UPLOAD BOX ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
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
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.blue.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to upload a photo (Optional)',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- TEXT FIELDS ---
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Place Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.landscape),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'District / City',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pin_drop),
                      ),
                      validator: (v) => v!.isEmpty ? 'Enter a location' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description & Tips',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v!.length < 10
                          ? 'Add a short description (min 10 chars)'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // --- SUBMIT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _submitDestination,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text(
                          'Add to MaporaSL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
