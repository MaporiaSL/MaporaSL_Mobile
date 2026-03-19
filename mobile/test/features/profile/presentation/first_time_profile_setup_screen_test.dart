import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemified_travel_portfolio/core/services/auth_service.dart';
import 'package:gemified_travel_portfolio/features/profile/data/repositories/profile_repository.dart';
import 'package:gemified_travel_portfolio/features/profile/domain/user_profile.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/first_time_profile_setup_screen.dart';
import 'package:gemified_travel_portfolio/features/profile/presentation/providers/profile_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  late MockProfileRepository repository;
  late MockAuthService authService;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = MockProfileRepository();
    authService = MockAuthService();

    when(() => authService.currentUserDisplayName).thenReturn('');
    when(() => authService.currentUser).thenReturn(null);

    when(
      () => repository.updateProfile(
        any(),
        name: any(named: 'name'),
        avatarUrl: any(named: 'avatarUrl'),
        bio: any(named: 'bio'),
        hometownDistrict: any(named: 'hometownDistrict'),
        preferredLanguage: any(named: 'preferredLanguage'),
        travelInterests: any(named: 'travelInterests'),
        completeSetup: any(named: 'completeSetup'),
      ),
    ).thenAnswer(
      (_) async => UserProfile(
        id: 'u1',
        name: 'Alice',
        email: 'a@example.com',
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
      ),
    );

    when(
      () => repository.uploadAvatar(any(), any()),
    ).thenAnswer((_) async => 'http://avatar');
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        authServiceProvider.overrideWithValue(authService),
        currentUserIdProvider.overrideWithValue('u1'),
      ],
      child: const MaterialApp(
        home: FirstTimeProfileSetupScreen(
          requiredFields: ['name', 'hometownDistrict', 'preferredLanguage'],
          optionalFields: ['travelInterests', 'avatarUrl', 'bio'],
        ),
      ),
    );
  }

  testWidgets('shows required field validation when setup is submitted empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Finish Setup').hitTestable().first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('District is required'), findsOneWidget);
  });

  testWidgets(
    'shows required and optional labels with expected field markers',
    (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Name (Required)'), findsOneWidget);
      expect(find.text('Hometown District (Required)'), findsOneWidget);
      expect(find.text('Preferred Language (Required)'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('Bio (Optional)'), findsOneWidget);
    },
  );

  testWidgets('restores setup draft values from local prefs', (tester) async {
    SharedPreferences.setMockInitialValues({
      'profile_setup_draft': jsonEncode({
        'name': 'Draft User',
        'hometownDistrict': 'Galle',
        'bio': 'Saved draft bio',
        'preferredLanguage': 'Tamil',
        'travelInterests': ['Food', 'Nature'],
      }),
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Draft User'), findsOneWidget);
    expect(find.text('Galle'), findsOneWidget);
    expect(find.text('Saved draft bio'), findsOneWidget);
    expect(find.text('Tamil'), findsOneWidget);
  });

  testWidgets('submits setup successfully and marks completion', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name (Required)'),
      'Alice',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hometown District (Required)'),
      'Colombo',
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Finish Setup').hitTestable().first,
    );
    await tester.pumpAndSettle();

    verify(
      () => repository.updateProfile(
        'u1',
        name: 'Alice',
        avatarUrl: any(named: 'avatarUrl'),
        bio: any(named: 'bio'),
        hometownDistrict: 'Colombo',
        preferredLanguage: any(named: 'preferredLanguage'),
        travelInterests: any(named: 'travelInterests'),
        completeSetup: true,
      ),
    ).called(1);

    expect(find.text('Profile setup completed.'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('profile_setup_completed'), isTrue);
  });

  testWidgets('shows server field errors inline when setup submit fails', (
    tester,
  ) async {
    when(
      () => repository.updateProfile(
        any(),
        name: any(named: 'name'),
        avatarUrl: any(named: 'avatarUrl'),
        bio: any(named: 'bio'),
        hometownDistrict: any(named: 'hometownDistrict'),
        preferredLanguage: any(named: 'preferredLanguage'),
        travelInterests: any(named: 'travelInterests'),
        completeSetup: any(named: 'completeSetup'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/profile/u1'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/profile/u1'),
          statusCode: 400,
          data: {
            'error': 'Please fix the highlighted fields.',
            'fieldErrors': {
              'name': 'Name contains invalid characters.',
              'hometownDistrict': 'District is not recognized.',
              'preferredLanguage': 'Preferred language is required.',
              'travelInterests': 'Choose up to 10 interests only.',
              'bio': 'Bio contains unsupported characters.',
            },
          },
        ),
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name (Required)'),
      'Alice',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Hometown District (Required)'),
      'Colombo',
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Finish Setup').hitTestable().first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Please fix the highlighted fields.'), findsOneWidget);
    expect(find.text('Name contains invalid characters.'), findsOneWidget);
    expect(find.text('District is not recognized.'), findsOneWidget);
    expect(find.text('Preferred language is required.'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose up to 10 interests only.'), findsOneWidget);
    expect(find.text('Bio contains unsupported characters.'), findsOneWidget);
  });

  testWidgets('shows avatar retry CTA and succeeds on retry', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('avatar_test');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final avatarFile = File('${tempDir.path}/avatar.jpg');
    await avatarFile.writeAsString('avatar-bytes');

    SharedPreferences.setMockInitialValues({
      'profile_setup_draft': jsonEncode({
        'name': 'Retry User',
        'hometownDistrict': 'Kandy',
        'preferredLanguage': 'English',
        'travelInterests': const <String>[],
        'avatarPath': avatarFile.path,
      }),
    });

    var avatarUploadAttempts = 0;
    when(() => repository.uploadAvatar(any(), any())).thenAnswer((_) async {
      avatarUploadAttempts += 1;
      if (avatarUploadAttempts == 1) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/profile/u1/avatar'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/profile/u1/avatar'),
            statusCode: 500,
            data: {'error': 'Avatar upload failed.'},
          ),
        );
      }
      return 'http://avatar/retry-success';
    });
    when(
      () => repository.updateProfile(
        'u1',
        avatarUrl: any(named: 'avatarUrl'),
      ),
    ).thenAnswer(
      (_) async => UserProfile(
        id: 'u1',
        name: 'Retry User',
        email: 'retry@example.com',
        avatarUrl: 'http://avatar/retry-success',
        bio: '',
        hometownDistrict: 'Kandy',
        preferredLanguage: 'English',
        travelInterests: const [],
        totalSubmitted: 0,
        approvedCount: 0,
        approvalRate: 0,
        badges: const [],
        contributedPlaces: const [],
        leaderboardRank: 0,
        impactCount: 0,
      ),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Continue').hitTestable().first,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(FilledButton, 'Finish Setup').hitTestable().first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Avatar upload failed.'), findsWidgets);
    expect(find.text('Retry Avatar Upload'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Retry Avatar Upload').hitTestable(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    verify(
      () => repository.updateProfile(
        'u1',
        avatarUrl: 'http://avatar/retry-success',
      ),
    ).called(1);

    expect(find.text('Avatar uploaded successfully.'), findsOneWidget);
  });
}
