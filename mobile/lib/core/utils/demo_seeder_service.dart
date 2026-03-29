import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/trips/data/models/trip_model.dart';
import '../../features/trips/data/models/trip_dto.dart';
import '../../features/trips/presentation/providers/trips_provider.dart';
import '../../providers/progress_provider.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';
import '../../features/achievements/providers/achievements_provider.dart';

class DemoSeederService {
  final Ref _ref;

  DemoSeederService(this._ref);

  Future<void> seedHeroAccount() async {
    final userEmail = _ref.read(authServiceProvider).currentUser?.email;
    if (userEmail != 'anuja.20231258@iit.ac.lk') return;

    // 1. Reset Progress & Set XP
    final progress = _ref.read(progressProvider.notifier);
    progress.resetProgress();
    progress.addXP(2500); // Level 26 (2500/100 + 1)

    // 2. Unlock Districts (Colombo is usually default, but we unlock others)
    final districts = ['Colombo', 'Galle', 'Kandy', 'Nuwara Eliya', 'Matara', 'Ampara'];
    for (final d in districts) {
      progress.unlockDistrict(d);
    }

    // 3. Inject Elite Trips
    final tripNotifier = _ref.read(tripsProvider.notifier);
    
    // Check if we already have these trips to avoid duplicates
    final existingTrips = _ref.read(tripsProvider).trips;
    if (existingTrips.any((t) => t.title.contains('Southern Coast'))) return;

    final trips = [
      CreateTripDto(
        title: 'Epic Southern Coast Expedition',
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
        title: 'Hill Country Tea Trail',
        description: 'A misty journey through Nuwara Eliya and Ella. Mountains, waterfalls, and endless tea estates.',
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        endDate: DateTime.now().subtract(const Duration(days: 15)),
        status: 'completed',
        locations: [
          const TripLocation(name: 'Nine Arches Bridge', day: 1),
          const TripLocation(name: 'Little Adams Peak', day: 2),
          const TripLocation(name: 'Gregory Lake', day: 3),
        ],
      ),
      CreateTripDto(
        title: 'Ancient Cities Heritage Tour',
        description: 'Uncovering the mysteries of Sigiriya and Anuradhapura. A deep dive into Sri Lankan history and wildlife.',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        locations: [
          const TripLocation(name: 'Sigiriya Rock Fortress', day: 1),
          const TripLocation(name: 'Anuradhapura Sacred City', day: 2),
          const TripLocation(name: 'Minneriya National Park', day: 3),
        ],
      ),
      CreateTripDto(
        title: 'Jaffna Cultural Awakening',
        description: 'Discovering the unique culture, temples, and food of the Northern Province.',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 35)),
        status: 'planned',
        locations: [
          const TripLocation(name: 'Nallur Kandaswamy Kovil', day: 1),
          const TripLocation(name: 'Jaffna Fort', day: 2),
          const TripLocation(name: 'Casuarina Beach', day: 3),
        ],
      ),
    ];

    for (final trip in trips) {
      await tripNotifier.createTrip(trip);
    }
    
    // Refresh stats and achievements
    _ref.refresh(achievementsViewProvider);
  }
}

final demoSeederProvider = Provider<DemoSeederService>((ref) {
  return DemoSeederService(ref);
});
