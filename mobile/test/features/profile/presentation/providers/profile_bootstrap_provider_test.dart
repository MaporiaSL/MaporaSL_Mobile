import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository repository;

  final sampleProfile = UserProfile(
    id: 'u1',
    name: 'Test User',
    email: 'test@example.com',
    avatarUrl: '',
    bio: '',
    hometownDistrict: 'Colombo',
    preferredLanguage: 'English',
    travelInterests: const [],
    totalSubmitted: 0,
    approvedCount: 0,
    approvalRate: 0,
    badges: const [],
    contributedPlaces: const [],
    leaderboardRank: 0,
    impactCount: 0,
  );

  setUp(() {
    repository = MockProfileRepository();
  });

  test('does not fetch profile when bootstrap fails', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        profileRepositoryProvider.overrideWithValue(repository),
        profileBootstrapProvider.overrideWith((ref) async {
          throw const ProfileLoadException(
            ProfileLoadErrorType.server,
            'bootstrap failed',
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(userProfileProvider.future),
      throwsA(isA<ProfileLoadException>()),
    );

    verifyNever(() => repository.getUserProfile(any()));
  });

  test('retry succeeds after bootstrap invalidation', () async {
    var attempts = 0;
    when(() => repository.getUserProfile('u1')).thenAnswer((_) async => sampleProfile);

    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        profileRepositoryProvider.overrideWithValue(repository),
        profileBootstrapProvider.overrideWith((ref) async {
          attempts += 1;
          if (attempts == 1) {
            throw const ProfileLoadException(
              ProfileLoadErrorType.server,
              'first attempt failed',
            );
          }
        }),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(userProfileProvider.future),
      throwsA(isA<ProfileLoadException>()),
    );

    container.invalidate(profileBootstrapProvider);
    container.invalidate(userProfileProvider);

    final profile = await container.read(userProfileProvider.future);
    expect(profile?.id, 'u1');
    verify(() => repository.getUserProfile('u1')).called(1);
  });
}
