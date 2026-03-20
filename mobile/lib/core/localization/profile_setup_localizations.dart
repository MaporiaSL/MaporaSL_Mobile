import 'package:flutter/widgets.dart';

class ProfileSetupLocalizations {
  ProfileSetupLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<ProfileSetupLocalizations> delegate =
      _ProfileSetupLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  static ProfileSetupLocalizations of(BuildContext context) {
    final result = Localizations.of<ProfileSetupLocalizations>(
      context,
      ProfileSetupLocalizations,
    );
    assert(result != null, 'ProfileSetupLocalizations not found in context');
    return result!;
  }

  static const _strings = <String, Map<String, String>>{
    'en': {
      'screenTitle': 'Complete Your Profile',
      'requiredTag': 'Required',
      'optionalTag': 'Optional',
      'requiredDetails': 'Required Details',
      'travelInterests': 'Travel Interests',
      'avatarAndConfirm': 'Avatar and Confirm',
      'logout': 'Logout',
      'continue': 'Continue',
      'finishSetup': 'Finish Setup',
      'back': 'Back',
      'nameRequiredLabel': 'Name (Required)',
      'districtRequiredLabel': 'Hometown District (Required)',
      'languageRequiredLabel': 'Preferred Language (Required)',
      'bioOptionalLabel': 'Bio (Optional)',
      'chooseAvatar': 'Choose Avatar',
      'retryAvatarUpload': 'Retry Avatar Upload',
      'retryAvatarSemantics': 'Retry failed avatar upload',
      'avatarHelper': 'Add an avatar now or skip and update later.',
      'setupCompleted': 'Profile setup completed.',
      'avatarUploaded': 'Avatar uploaded successfully.',
      'sessionExpired': 'Please sign in again to continue setup.',
      'nameRequired': 'Name is required',
      'nameMin': 'Name must be at least 2 characters',
      'nameMax': 'Name must be under 40 characters',
      'districtRequired': 'District is required',
      'districtMax': 'District must be under 60 characters',
      'bioMax': 'Bio must be under 200 characters',
        'myProfile': 'My Profile',
        'moderationQueue': 'Moderation Queue',
        'retry': 'Retry',
        'signInAgain': 'Sign In Again',
        'profileNotFound': 'Profile Not Found',
        'profileNotFoundBody':
          'No user profile exists for this account yet. Tap retry to bootstrap your account profile.',
        'tryAgain': 'Try Again',
        'badgesEarned': 'Badges Earned',
        'contributedPlaces': 'Contributed Places',
        'topContributors': 'Top Contributors',
        'editProfile': 'Edit Profile',
        'submitPlace': 'Submit Place',
        'all': 'All',
        'pending': 'Pending',
        'approved': 'Approved',
        'rejected': 'Rejected',
        'newest': 'Newest',
        'oldest': 'Oldest',
        'status': 'Status',
        'languagePrefix': 'Language:',
        'submitted': 'Submitted',
        'approvalRate': 'Approval Rate',
        'districtsUnlocked': 'Districts Unlocked',
        'provincesUnlocked': 'Provinces Unlocked',
        'placesVisited': 'Places Visited',
        'contributionsLoadError': 'Could not load submissions right now.',
        'retryContributions': 'Retry Contributions',
        'noSubmissionsInView': 'No submissions in this view yet.',
        'submittedPrefix': 'Submitted:',
        'reasonPrefix': 'Reason:',
        'viewDetails': 'View details',
        'pendingReview': 'Pending Review',
        'globalRankPrefix': 'Global Rank:',
        'impactPrefix': 'Impact:',
        'impactSuffix': 'users visited your places',
        'leaderboardLoadError': 'Could not load leaderboard.',
        'retryLeaderboard': 'Retry Leaderboard',
        'noLeaderboardDataYet': 'No leaderboard data yet.',
        'unknown': 'Unknown',
        'approvedSuffix': 'approved',
        'preparingSessionTitle': 'Preparing Your Session',
        'preparingSessionMessage':
          'We are still setting up your sign-in token. Please try again.',
        'signInRequiredTitle': 'Sign In Required',
        'signInRequiredMessage': 'Please sign in to access your profile.',
        'sessionExpiredTitle': 'Session Expired',
        'sessionExpiredMessage':
          'Your login session expired. Sign in again to continue.',
        'creatingProfileTitle': 'Creating Your Profile',
        'creatingProfileMessage':
          'We could not sync your account yet. Tap retry to complete setup.',
        'noInternetTitle': 'No Internet Connection',
        'noInternetMessage':
          'Connect to the internet and retry loading your profile.',
        'accessDeniedTitle': 'Access Denied',
        'accessDeniedMessage':
          'This profile request is not allowed right now. Try signing in again.',
        'serverErrorTitle': 'Server Error',
        'serverErrorMessage':
          'The server is currently unavailable. Please try again shortly.',
        'unableLoadProfileTitle': 'Unable To Load Profile',
        'unableLoadProfileMessage':
          'An unexpected error occurred. Please retry.',
        'errorLoadingProfileTitle': 'Error Loading Profile',
        'errorLoadingProfileMessage':
          'An unexpected error occurred while loading profile data.',
        'logoutConfirmTitle': 'Logout',
        'logoutConfirmMessage': 'Are you sure you want to logout?',
        'cancel': 'Cancel',
        'errorPrefix': 'Error:',
        'submitNewPlaceTitle': 'Submit New Place',
        'placeName': 'Place name',
        'min3Characters': 'Enter at least 3 characters',
        'description': 'Description',
        'atLeast50Characters': 'At least 50 characters',
        'descriptionMin50': 'Description must be at least 50 characters',
        'category': 'Category',
        'province': 'Province',
        'provinceRequired': 'Province required',
        'district': 'District',
        'pickPhotosMin2': 'Pick Photos (min 2)',
        'photosSelectedSuffix': 'photo(s) selected',
        'selectAtLeast2Photos': 'Please select at least 2 photos',
        'autoLocationFailed':
          'Could not determine location automatically. Refine place/province/district and try again.',
        'submissionFailedPrefix': 'Submission failed:',
        'placeSubmittedSuccess': 'Place submitted successfully for review!',
        'submitForReview': 'Submit for Review',
        'submissionReviewNote':
          'Your submission will be reviewed by admins before it appears publicly.',
    },
    'si': {
      'screenTitle': 'Complete Your Profile',
      'requiredTag': 'Required',
      'optionalTag': 'Optional',
      'requiredDetails': 'Required Details',
      'travelInterests': 'Travel Interests',
      'avatarAndConfirm': 'Avatar and Confirm',
      'logout': 'Logout',
      'continue': 'Continue',
      'finishSetup': 'Finish Setup',
      'back': 'Back',
      'nameRequiredLabel': 'Name (Required)',
      'districtRequiredLabel': 'Hometown District (Required)',
      'languageRequiredLabel': 'Preferred Language (Required)',
      'bioOptionalLabel': 'Bio (Optional)',
      'chooseAvatar': 'Choose Avatar',
      'retryAvatarUpload': 'Retry Avatar Upload',
      'retryAvatarSemantics': 'Retry failed avatar upload',
      'avatarHelper': 'Add an avatar now or skip and update later.',
      'setupCompleted': 'Profile setup completed.',
      'avatarUploaded': 'Avatar uploaded successfully.',
      'sessionExpired': 'Please sign in again to continue setup.',
      'nameRequired': 'Name is required',
      'nameMin': 'Name must be at least 2 characters',
      'nameMax': 'Name must be under 40 characters',
      'districtRequired': 'District is required',
      'districtMax': 'District must be under 60 characters',
      'bioMax': 'Bio must be under 200 characters',
    },
    'ta': {
      'screenTitle': 'Complete Your Profile',
      'requiredTag': 'Required',
      'optionalTag': 'Optional',
      'requiredDetails': 'Required Details',
      'travelInterests': 'Travel Interests',
      'avatarAndConfirm': 'Avatar and Confirm',
      'logout': 'Logout',
      'continue': 'Continue',
      'finishSetup': 'Finish Setup',
      'back': 'Back',
      'nameRequiredLabel': 'Name (Required)',
      'districtRequiredLabel': 'Hometown District (Required)',
      'languageRequiredLabel': 'Preferred Language (Required)',
      'bioOptionalLabel': 'Bio (Optional)',
      'chooseAvatar': 'Choose Avatar',
      'retryAvatarUpload': 'Retry Avatar Upload',
      'retryAvatarSemantics': 'Retry failed avatar upload',
      'avatarHelper': 'Add an avatar now or skip and update later.',
      'setupCompleted': 'Profile setup completed.',
      'avatarUploaded': 'Avatar uploaded successfully.',
      'sessionExpired': 'Please sign in again to continue setup.',
      'nameRequired': 'Name is required',
      'nameMin': 'Name must be at least 2 characters',
      'nameMax': 'Name must be under 40 characters',
      'districtRequired': 'District is required',
      'districtMax': 'District must be under 60 characters',
      'bioMax': 'Bio must be under 200 characters',
    },
  };

  String _value(String key) {
    final lang = _strings[locale.languageCode] ?? _strings['en']!;
    return lang[key] ?? _strings['en']![key]!;
  }

  String get screenTitle => _value('screenTitle');
  String get requiredTag => _value('requiredTag');
  String get optionalTag => _value('optionalTag');
  String get requiredDetails => _value('requiredDetails');
  String get travelInterests => _value('travelInterests');
  String get avatarAndConfirm => _value('avatarAndConfirm');
  String get logout => _value('logout');
  String get continueLabel => _value('continue');
  String get finishSetup => _value('finishSetup');
  String get back => _value('back');
  String get nameRequiredLabel => _value('nameRequiredLabel');
  String get districtRequiredLabel => _value('districtRequiredLabel');
  String get languageRequiredLabel => _value('languageRequiredLabel');
  String get bioOptionalLabel => _value('bioOptionalLabel');
  String get chooseAvatar => _value('chooseAvatar');
  String get retryAvatarUpload => _value('retryAvatarUpload');
  String get retryAvatarSemantics => _value('retryAvatarSemantics');
  String get avatarHelper => _value('avatarHelper');
  String get setupCompleted => _value('setupCompleted');
  String get avatarUploaded => _value('avatarUploaded');
  String get sessionExpired => _value('sessionExpired');
  String get nameRequired => _value('nameRequired');
  String get nameMin => _value('nameMin');
  String get nameMax => _value('nameMax');
  String get districtRequired => _value('districtRequired');
  String get districtMax => _value('districtMax');
  String get bioMax => _value('bioMax');
  String get myProfile => _value('myProfile');
  String get moderationQueue => _value('moderationQueue');
  String get retry => _value('retry');
  String get signInAgain => _value('signInAgain');
  String get profileNotFound => _value('profileNotFound');
  String get profileNotFoundBody => _value('profileNotFoundBody');
  String get tryAgain => _value('tryAgain');
  String get badgesEarned => _value('badgesEarned');
  String get contributedPlaces => _value('contributedPlaces');
  String get topContributors => _value('topContributors');
  String get editProfile => _value('editProfile');
  String get submitPlace => _value('submitPlace');
  String get all => _value('all');
  String get pending => _value('pending');
  String get approved => _value('approved');
  String get rejected => _value('rejected');
  String get newest => _value('newest');
  String get oldest => _value('oldest');
  String get status => _value('status');
  String get languagePrefix => _value('languagePrefix');
  String get submitted => _value('submitted');
  String get approvalRate => _value('approvalRate');
  String get districtsUnlocked => _value('districtsUnlocked');
  String get provincesUnlocked => _value('provincesUnlocked');
  String get placesVisited => _value('placesVisited');
  String get contributionsLoadError => _value('contributionsLoadError');
  String get retryContributions => _value('retryContributions');
  String get noSubmissionsInView => _value('noSubmissionsInView');
  String get submittedPrefix => _value('submittedPrefix');
  String get reasonPrefix => _value('reasonPrefix');
  String get viewDetails => _value('viewDetails');
  String get pendingReview => _value('pendingReview');
  String get globalRankPrefix => _value('globalRankPrefix');
  String get impactPrefix => _value('impactPrefix');
  String get impactSuffix => _value('impactSuffix');
  String get leaderboardLoadError => _value('leaderboardLoadError');
  String get retryLeaderboard => _value('retryLeaderboard');
  String get noLeaderboardDataYet => _value('noLeaderboardDataYet');
  String get unknown => _value('unknown');
  String get approvedSuffix => _value('approvedSuffix');
  String get preparingSessionTitle => _value('preparingSessionTitle');
  String get preparingSessionMessage => _value('preparingSessionMessage');
  String get signInRequiredTitle => _value('signInRequiredTitle');
  String get signInRequiredMessage => _value('signInRequiredMessage');
  String get sessionExpiredTitle => _value('sessionExpiredTitle');
  String get sessionExpiredMessage => _value('sessionExpiredMessage');
  String get creatingProfileTitle => _value('creatingProfileTitle');
  String get creatingProfileMessage => _value('creatingProfileMessage');
  String get noInternetTitle => _value('noInternetTitle');
  String get noInternetMessage => _value('noInternetMessage');
  String get accessDeniedTitle => _value('accessDeniedTitle');
  String get accessDeniedMessage => _value('accessDeniedMessage');
  String get serverErrorTitle => _value('serverErrorTitle');
  String get serverErrorMessage => _value('serverErrorMessage');
  String get unableLoadProfileTitle => _value('unableLoadProfileTitle');
  String get unableLoadProfileMessage => _value('unableLoadProfileMessage');
  String get errorLoadingProfileTitle => _value('errorLoadingProfileTitle');
  String get errorLoadingProfileMessage => _value('errorLoadingProfileMessage');
  String get logoutConfirmTitle => _value('logoutConfirmTitle');
  String get logoutConfirmMessage => _value('logoutConfirmMessage');
  String get cancel => _value('cancel');
  String get errorPrefix => _value('errorPrefix');
  String get submitNewPlaceTitle => _value('submitNewPlaceTitle');
  String get placeName => _value('placeName');
  String get min3Characters => _value('min3Characters');
  String get description => _value('description');
  String get atLeast50Characters => _value('atLeast50Characters');
  String get descriptionMin50 => _value('descriptionMin50');
  String get category => _value('category');
  String get province => _value('province');
  String get provinceRequired => _value('provinceRequired');
  String get district => _value('district');
  String get pickPhotosMin2 => _value('pickPhotosMin2');
  String get photosSelectedSuffix => _value('photosSelectedSuffix');
  String get selectAtLeast2Photos => _value('selectAtLeast2Photos');
  String get autoLocationFailed => _value('autoLocationFailed');
  String get submissionFailedPrefix => _value('submissionFailedPrefix');
  String get placeSubmittedSuccess => _value('placeSubmittedSuccess');
  String get submitForReview => _value('submitForReview');
  String get submissionReviewNote => _value('submissionReviewNote');
}

class _ProfileSetupLocalizationsDelegate
    extends LocalizationsDelegate<ProfileSetupLocalizations> {
  const _ProfileSetupLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ProfileSetupLocalizations.supportedLocales
      .map((l) => l.languageCode)
      .contains(locale.languageCode);

  @override
  Future<ProfileSetupLocalizations> load(Locale locale) async {
    return ProfileSetupLocalizations(locale);
  }

  @override
  bool shouldReload(_ProfileSetupLocalizationsDelegate old) => false;
}
