import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  final String photoPath;
  final VoidCallback onUpload;
  final VoidCallback onRetake;

  const PhotoPreview({
    required this.photoPath,
    required this.onUpload,
    required this.onRetake,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(photoPath), fit: BoxFit.contain),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: onRetake,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Retake',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Save to Album'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
