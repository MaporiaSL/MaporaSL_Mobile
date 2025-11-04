import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationProvider = StateProvider<Position?>((ref) => null);
final trackingProvider = StateProvider<bool>((ref) => false);
