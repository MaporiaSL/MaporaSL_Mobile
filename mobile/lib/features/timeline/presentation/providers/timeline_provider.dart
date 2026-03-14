import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../models/timeline_event.dart';
import '../services/timeline_service.dart';

final timelineProvider = AsyncNotifierProvider<TimelineNotifier, List<TimelineEvent>>(() {
  return TimelineNotifier();
});

class TimelineNotifier extends AsyncNotifier<List<TimelineEvent>> {
  @override
  FutureOr<List<TimelineEvent>> build() async {
    return _fetchTimeline();
  }

  Future<List<TimelineEvent>> _fetchTimeline() async {
    final user = ref.read(authServiceProvider.notifier).currentUser;
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
