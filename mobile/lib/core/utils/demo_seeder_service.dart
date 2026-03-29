import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/trips/data/models/trip_model.dart';
import '../../features/trips/data/models/trip_dto.dart';
import '../../features/trips/presentation/providers/trips_provider.dart';
import '../../providers/progress_provider.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import '../../features/achievements/providers/achievements_provider.dart';
import '../../features/album/data/services/album_service.dart';
import '../../core/services/local_prefs.dart';

class DemoInitializerService {
  final Ref _ref;

  DemoInitializerService(this._ref);

  /// Automatically seeds the demo account if logged in user is the demo user
  /// and seeding hasn't occurred yet, while also persisting local states.
  Future<void> initializeIfNeeded() async {
    final userEmail = _ref.read(authServiceProvider).currentUser?.email;
    if (userEmail != 'anuja.20231258@iit.ac.lk') return;

    // 1. Force Local Progress & Achievements On Every App Launch 
    // (Because these are strictly in-memory and reset on restart)
    _forceLocalProgressState();
    _forceLocalAchievements();

    // 2. Check if we've already done the heavy backend seeding (Trips, Albums)
    final isSeeded = await LocalPrefs.isDemoSeeded();
    if (isSeeded) return;

    try {
      debugPrint('🚀 Demo Initializer: Starting permanent backend seeding...');
      await _seedProfessionalTrips();
      await _seedProfessionalAlbums();

      // Mark as seeded so we don't duplicate on next launch
      await LocalPrefs.setDemoSeeded(true);
      debugPrint('✅ Demo Initializer: Seeding complete!');

      // Refresh final providers
      _ref.invalidate(tripsProvider);
      _ref.invalidate(achievementsViewProvider);
    } catch (e) {
      debugPrint('❌ Demo Initializer: Error during seeding: $e');
    }
  }

  void _forceLocalProgressState() {
    final progress = _ref.read(progressProvider.notifier);
    progress.resetProgress();
    progress.addXP(1450); // Level 15 (1450/100 + 1 => effectively level 15)

    final districts = ['Colombo', 'Galle', 'Kandy', 'Nuwara Eliya'];
    for (final d in districts) {
      progress.unlockDistrict(d);
    }
  }

  void _forceLocalAchievements() {
    final progress = _ref.read(progressProvider.notifier);
    progress.unlockAchievement('first_trip');
    progress.unlockAchievement('explorer_initiate');
    progress.unlockAchievement('photo_enthusiast');
  }

  Future<void> _seedProfessionalTrips() async {
    final tripNotifier = _ref.read(tripsProvider.notifier);
    
    // Safety check just in case DB wasn't completely wiped
    final existingTrips = _ref.read(tripsProvider).trips;
    if (existingTrips.any((t) => t.title.contains('Southern Coast'))) return;

    final trips = [
      CreateTripDto(
        title: 'Southern Coast Getaway',
        description: 'Exploring the golden sands and history of the South. Galle Fort, Hikkaduwa corals, and Matara vibes.',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().subtract(const Duration(days: 40)),
        status: 'completed',
        locations: [
          const TripLocation(name: 'Galle Dutch Fort', day: 1),
          const TripLocation(name: 'Hikkaduwa Beach', day: 2),
          const TripLocation(name: 'Matara Paravi Duwa', day: 3),
        ],
      ),
      CreateTripDto(
        title: 'Cultural Triangle',
        description: 'Uncovering the mysteries of Sigiriya and Anuradhapura. A deep dive into Sri Lankan history and wildlife.',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        locations: [
          const TripLocation(name: 'Sigiriya Rock Fortress', day: 1),
          const TripLocation(name: 'Anuradhapura Sacred City', day: 2),
          const TripLocation(name: 'Polonnaruwa Vatadage', day: 3),
        ],
      ),
      CreateTripDto(
        title: 'Hill Country Tea Trail',
        description: 'A misty journey through Nuwara Eliya and Ella. Mountains, waterfalls, and endless tea estates.',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 35)),
        status: 'planned',
        locations: [
          const TripLocation(name: 'Nine Arches Bridge', day: 1),
          const TripLocation(name: 'Little Adams Peak', day: 2),
          const TripLocation(name: 'Gregory Lake', day: 3),
        ],
      ),
    ];

    for (final trip in trips) {
      await tripNotifier.createTrip(trip);
    }
  }

  Future<void> _seedProfessionalAlbums() async {
    final albumService = AlbumService();
    
    // Album 1
    final downSouth = await albumService.createAlbum('Down South 2023', description: 'Memories from the southern beaches');
    await _uploadMockPhoto(albumService, downSouth.id, 'https://images.unsplash.com/photo-1546708973-c8a8818ad514?w=500&q=80', 'Galle Fort Sunset');
    await _uploadMockPhoto(albumService, downSouth.id, 'https://images.unsplash.com/photo-1550239241-11b3f7f0b5d0?w=500&q=80', 'Hikkaduwa Surf');

    // Album 2
    final kandyViews = await albumService.createAlbum('Kandy Views', description: 'Temple of the Tooth and surrounding hills');
    await _uploadMockPhoto(albumService, kandyViews.id, 'https://images.unsplash.com/photo-1588096344392-7104b904dfdb?w=500&q=80', 'Temple of the Tooth');
  }

  Future<void> _uploadMockPhoto(AlbumService service, String albumId, String imageUrl, String caption) async {
    try {
      final response = await Dio().get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final dir = await getTemporaryDirectory();
      final filename = 'mock_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.data);

      await service.uploadPhoto(albumId, file, caption: caption);
    } catch (e) {
      debugPrint('Failed to upload mock photo for album $albumId: $e');
    }
  }
}

final demoInitializerProvider = Provider<DemoInitializerService>((ref) {
  return DemoInitializerService(ref);
});
