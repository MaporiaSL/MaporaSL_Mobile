/// Sri Lanka regions/districts data for cartoonish map
///
/// Contains all 9 provinces with their metadata, colors, and landmark locations

import 'package:flutter/material.dart';

class SriLankaRegion {
  final String id;
  final String name;
  final String displayName;
  final HexColor color;
  final double latitude;
  final double longitude;
  final List<String> landmarks;
  final String description;

  const SriLankaRegion({
    required this.id,
    required this.name,
    required this.displayName,
    required this.color,
    required this.latitude,
    required this.longitude,
    required this.landmarks,
    required this.description,
  });
}

// Hex color helper
class HexColor {
  final int value;
  const HexColor(this.value);

  static HexColor fromHex(String hex) {
    return HexColor(int.parse(hex.replaceFirst('#', '0xff')));
  }

  // Convert to Flutter Color
  Color toFlutterColor() => Color(value);
}

/// All Sri Lanka regions/provinces
final sriLankaRegions = <SriLankaRegion>[
  SriLankaRegion(
    id: 'western',
    name: 'Western Province',
    displayName: 'Western',
    color: HexColor.fromHex('#FF4444'),
    latitude: 6.9271,
    longitude: 80.6900,
    landmarks: ['Colombo', 'Galle Face Green', 'Colombo Port'],
    description: 'The commercial and cultural heart of Sri Lanka',
  ),
  SriLankaRegion(
    id: 'central',
    name: 'Central Province',
    displayName: 'Central',
    color: HexColor.fromHex('#4ECDC4'),
    latitude: 6.9271,
    longitude: 80.7744,
    landmarks: ['Kandy', 'Temple of the Tooth', 'Peradeniya Botanical Gardens'],
    description: 'Home of the sacred Temple of the Tooth',
  ),
  SriLankaRegion(
    id: 'northern',
    name: 'Northern Province',
    displayName: 'Northern',
    color: HexColor.fromHex('#FFE66D'),
    latitude: 8.5241,
    longitude: 80.7965,
    landmarks: ['Jaffna', 'Jaffna Fort', 'Nallur Kandasamy Temple'],
    description: 'The historic peninsula with vibrant culture',
  ),
  SriLankaRegion(
    id: 'eastern',
    name: 'Eastern Province',
    displayName: 'Eastern',
    color: HexColor.fromHex('#95E1D3'),
    latitude: 7.7409,
    longitude: 81.6869,
    landmarks: ['Trincomalee', 'Nilaveli Beach', 'Pigeon Island'],
    description: 'Beaches and marine treasures',
  ),
  SriLankaRegion(
    id: 'southern',
    name: 'Southern Province',
    displayName: 'Southern',
    color: HexColor.fromHex('#A8E6CF'),
    latitude: 6.0535,
    longitude: 80.7891,
    landmarks: ['Galle', 'Galle Fort', 'Unawatuna Beach'],
    description: 'Famous for historic fort and pristine beaches',
  ),
  SriLankaRegion(
    id: 'north_central',
    name: 'North Central Province',
    displayName: 'North Central',
    color: HexColor.fromHex('#FFB6B9'),
    latitude: 7.9456,
    longitude: 80.7669,
    landmarks: ['Anuradhapura', 'Sacred Bo Tree', 'Abhayagiri Dagoba'],
    description: 'Ancient capital with sacred Buddhist sites',
  ),
  SriLankaRegion(
    id: 'north_western',
    name: 'North Western Province',
    displayName: 'North Western',
    color: HexColor.fromHex('#FEC8D8'),
    latitude: 7.1905,
    longitude: 80.3244,
    landmarks: ['Kurunegala', 'Ambuluwawa Tower', 'Ibbagamuwa Temple'],
    description: 'Ancient kingdom with historic temples',
  ),
  SriLankaRegion(
    id: 'sabaragamuwa',
    name: 'Sabaragamuwa Province',
    displayName: 'Sabaragamuwa',
    color: HexColor.fromHex('#FFDDC1'),
    latitude: 6.6271,
    longitude: 80.7744,
    landmarks: ['Ratnapura', 'Sinharaja Forest', 'Gem Mines'],
    description: 'Gem mines and rainforests',
  ),
  SriLankaRegion(
    id: 'uva',
    name: 'Uva Province',
    displayName: 'Uva',
    color: HexColor.fromHex('#FFFFB5'),
    latitude: 6.8521,
    longitude: 81.1269,
    landmarks: ['Badulla', 'Dunhinda Falls', 'Ravana Caves'],
    description: 'Misty mountains and hidden waterfalls',
  ),
];

/// Get region by ID
SriLankaRegion? getRegionById(String id) {
  try {
    return sriLankaRegions.firstWhere((r) => r.id == id);
  } catch (e) {
    return null;
  }
}

/// Get all region IDs
List<String> getAllRegionIds() {
  return sriLankaRegions.map((r) => r.id).toList();
}

/// Center point of Sri Lanka
const sriLankaCenter = (latitude: 7.8731, longitude: 80.7718);

/// Sri Lanka bounding box
const sriLankaBounds = (
  minLat: 5.88,
  maxLat: 9.83,
  minLng: 79.65,
  maxLng: 81.87,
);
