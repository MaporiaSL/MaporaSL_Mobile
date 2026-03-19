import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  setUp(() {
    repository = MockProfileRepository();
  });

  test('moderationActionProvider sends approve review and succeeds', () async {
    when(
      () => repository.reviewSubmission(
        submissionId: 's1',
        approve: true,
        rejectionReason: any(named: 'rejectionReason'),
      ),
    ).thenAnswer((_) async => {'message': 'ok'});

    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(moderationActionProvider.notifier).review(
          submissionId: 's1',
          approve: true,
        );

    final state = container.read(moderationActionProvider);
    expect(state.success, isTrue);
    expect(state.error, isNull);
    verify(
      () => repository.reviewSubmission(
        submissionId: 's1',
        approve: true,
        rejectionReason: any(named: 'rejectionReason'),
      ),
    ).called(1);
  });

  test('resubmitProvider forwards payload and sets success', () async {
    when(
      () => repository.resubmitRejectedContribution(
        submissionId: 'sub-1',
        placeName: 'Place',
        description: 'A valid description that is long enough for backend validation.',
        category: 'other',
        province: 'Western',
        district: 'Colombo',
        latitude: 6.9,
        longitude: 79.8,
        photoPaths: any(named: 'photoPaths'),
      ),
    ).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(resubmitProvider.notifier).resubmit(
          submissionId: 'sub-1',
          placeName: 'Place',
          description: 'A valid description that is long enough for backend validation.',
          category: 'other',
          province: 'Western',
          district: 'Colombo',
          latitude: 6.9,
          longitude: 79.8,
        );

    final state = container.read(resubmitProvider);
    expect(state.success, isTrue);
    expect(state.error, isNull);
    verify(
      () => repository.resubmitRejectedContribution(
        submissionId: 'sub-1',
        placeName: 'Place',
        description: 'A valid description that is long enough for backend validation.',
        category: 'other',
        province: 'Western',
        district: 'Colombo',
        latitude: 6.9,
        longitude: 79.8,
        photoPaths: any(named: 'photoPaths'),
      ),
    ).called(1);
  });
}
