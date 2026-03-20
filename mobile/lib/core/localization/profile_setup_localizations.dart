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
