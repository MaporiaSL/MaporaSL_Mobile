import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/timeline_event.dart';
import '../../data/services/timeline_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final timelineProvider = AsyncNotifierProvider<TimelineNotifier, List<TimelineEvent>>(() {
  return TimelineNotifier();
});

/// 5 hardcoded completed trips injected at the top of the timeline
List<TimelineEvent> _completedTripEvents() {
  return [
    TimelineEvent(
      id: 'completed_trip_1',
      type: TimelineEventType.completedTrip,
      timestamp: DateTime(2025, 12, 14),
      title: 'Sigiriya',
      description:
          'A full day at the iconic Sigiriya Rock Fortress — climb the ancient citadel, explore the water gardens, and marvel at the stunning views from the top.',
      metadata: {},
      completionPercentage: 100,
      destinationCount: 3,
      visitedCount: 3,
      tripId: 'trip_1',
    ),
    TimelineEvent(
      id: 'completed_trip_2',
      type: TimelineEventType.completedTrip,
      timestamp: DateTime(2025, 11, 23),
      title: 'Mirissa',
      description:
          'Two relaxing days on the stunning Mirissa coast — whale watching at sunrise, surfing at Parrot Rock, and fresh seafood by the beach at sunset.',
      metadata: {},
      completionPercentage: 100,
      destinationCount: 3,
      visitedCount: 3,
      tripId: 'trip_2',
    ),
    TimelineEvent(
      id: 'completed_trip_3',
      type: TimelineEventType.completedTrip,
      timestamp: DateTime(2025, 9, 7),
      title: 'Nuwara Eliya',
      description:
          'Two days in the misty hill country — visit Gregory Lake, tour a tea factory in the highlands, and stroll through the famous Hakgala Botanical Gardens.',
      metadata: {},
      completionPercentage: 100,
      destinationCount: 3,
      visitedCount: 3,
      tripId: 'trip_3',
    ),
    TimelineEvent(
      id: 'completed_trip_4',
      type: TimelineEventType.completedTrip,
      timestamp: DateTime(2025, 7, 19),
      title: 'Ella',
      description:
          'An exhilarating day hike to the summit of Ella Rock with sweeping views of the valley, followed by a stroll across the iconic Nine Arches Bridge.',
      metadata: {},
      completionPercentage: 100,
      destinationCount: 2,
      visitedCount: 2,
      tripId: 'trip_4',
    ),
    TimelineEvent(
      id: 'completed_trip_5',
      type: TimelineEventType.completedTrip,
      timestamp: DateTime(2025, 4, 20),
      title: 'Galle Fort',
      description:
          'Three days exploring historic Galle Fort — wander the cobblestone streets, visit the lighthouse, discover boutique cafes inside the old Dutch ramparts.',
      metadata: {},
      completionPercentage: 67,
      destinationCount: 3,
      visitedCount: 2,
      tripId: 'trip_5',
    ),
  ];
}

class TimelineNotifier extends AsyncNotifier<List<TimelineEvent>> {
  @override
  FutureOr<List<TimelineEvent>> build() async {
    return _fetchTimeline();
  }

  Future<List<TimelineEvent>> _fetchTimeline() async {
    final user = ref.read(authServiceProvider).currentUser;

    // Always prepend the 5 completed trip entries
    final completedTrips = _completedTripEvents();

    if (user == null) {
      return completedTrips;
    }

    final timelineService = ref.read(timelineServiceProvider);
    final remoteEvents = await timelineService.getUserTimeline(user.uid);

    // Completed trips appear first (most recent at top)
    return [...completedTrips, ...remoteEvents];
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTimeline());
  }
}
