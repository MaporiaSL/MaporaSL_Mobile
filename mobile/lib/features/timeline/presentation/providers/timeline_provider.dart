import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/models/timeline_event.dart';
import '../../data/services/timeline_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());


final timelineProvider = AsyncNotifierProvider<TimelineNotifier, List<TimelineEvent>>(() {
  return TimelineNotifier();
});

class TimelineNotifier extends AsyncNotifier<List<TimelineEvent>> {
  @override
  FutureOr<List<TimelineEvent>> build() async {
    return _fetchTimeline();
  }

  Future<List<TimelineEvent>> _fetchTimeline() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      return [];
    }
    
    final timelineService = ref.read(timelineServiceProvider);
    return await timelineService.getUserTimeline(user.uid);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTimeline());
  }
}
