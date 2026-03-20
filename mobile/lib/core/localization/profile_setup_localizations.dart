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
    return result ?? ProfileSetupLocalizations(const Locale('en'));
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
      'unableLoadProfileMessage': 'An unexpected error occurred. Please retry.',
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
      'loadMoreContributions': 'Load More Contributions',
      'loadMoreLeaderboard': 'Load More Leaderboard',
      'editProfileTitle': 'Edit Profile',
      'save': 'Save',
      'saving': 'Saving...',
      'changePhoto': 'Change photo',
      'takePhoto': 'Take a photo',
      'chooseFromGallery': 'Choose from gallery',
      'fieldsInvalid': 'Please correct the highlighted fields.',
      'avatarUploadConnectionFailed':
          'Avatar upload failed. Check your connection and try again.',
      'avatarUploadRetryFailed':
          'Avatar upload failed. Tap retry to try again.',
      'saveFailed': 'Save failed. Please try again.',
      'profileUpdated': 'Profile updated!',
      'displayName': 'Display name',
      'displayNameHint': 'Enter your name',
      'displayNameHelper': 'This is visible on leaderboards and profile',
      'nameCannotBeEmpty': 'Name cannot be empty',
      'bioHint': 'Tell others what kind of traveler you are',
      'hometownDistrict': 'Hometown district',
      'hometownDistrictHint': 'e.g. Colombo',
      'hometownDistrictHelper': 'Used to personalize local suggestions',
      'districtCannotBeEmpty': 'District cannot be empty',
      'preferredLanguage': 'Preferred language',
      'travelInterestsPrefix': 'Travel interests',
      'email': 'Email',
      'emailReadOnlyHelper': 'Email cannot be changed here',
      'saveChanges': 'Save Changes',
      'discardChangesTitle': 'Discard changes?',
      'discardChangesMessage':
          'You have unsaved profile changes. Leave without saving?',
      'keepEditing': 'Keep Editing',
      'discard': 'Discard',
      'cropAvatarTitle': 'Crop Avatar',
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
      'myProfile': 'මගේ පැතිකඩ',
      'moderationQueue': 'සමාලෝචන පෝලිම',
      'retry': 'නැවත උත්සාහ කරන්න',
      'signInAgain': 'නැවත පිවිසෙන්න',
      'profileNotFound': 'පැතිකඩ හමු නොවීය',
      'profileNotFoundBody':
          'මෙම ගිණුම සඳහා පරිශීලක පැතිකඩක් තවම නොමැත. ගිණුම සකස් කිරීමට නැවත උත්සාහ කරන්න.',
      'tryAgain': 'නැවත උත්සාහ කරන්න',
      'badgesEarned': 'ලැබූ බැජ්',
      'contributedPlaces': 'ඔබ දායක කළ ස්ථාන',
      'topContributors': 'ඉහළම දායකයෝ',
      'editProfile': 'පැතිකඩ සංස්කරණය',
      'submitPlace': 'ස්ථානයක් ඉදිරිපත් කරන්න',
      'all': 'සියල්ල',
      'pending': 'පොරොත්තුවේ',
      'approved': 'අනුමතයි',
      'rejected': 'ප්‍රතික්ෂේපිතයි',
      'newest': 'නවතම',
      'oldest': 'පැරණිතම',
      'status': 'තත්ත්වය',
      'languagePrefix': 'භාෂාව:',
      'submitted': 'ඉදිරිපත් කළ',
      'approvalRate': 'අනුමත අනුපාතය',
      'districtsUnlocked': 'විවෘත කළ දිස්ත්‍රික්ක',
      'provincesUnlocked': 'විවෘත කළ පළාත්',
      'placesVisited': 'නැරඹූ ස්ථාන',
      'contributionsLoadError': 'දායකත්ව දත්ත දැන් ලබාගත නොහැක.',
      'retryContributions': 'දායකත්ව නැවත ලබාගන්න',
      'noSubmissionsInView': 'මෙම දෘශ්‍යයේ තවම දායකත්ව නොමැත.',
      'submittedPrefix': 'ඉදිරිපත් කළ දිනය:',
      'reasonPrefix': 'හේතුව:',
      'viewDetails': 'විස්තර බලන්න',
      'pendingReview': 'සමාලෝචනයට බලාපොරොත්තුවෙන්',
      'globalRankPrefix': 'ගෝලීය ශ්‍රේණිය:',
      'impactPrefix': 'බලපෑම:',
      'impactSuffix': 'පරිශීලකයින් ඔබේ ස්ථාන නැරඹීය',
      'leaderboardLoadError': 'ශ්‍රේණිගත පුවරුව ලබාගත නොහැක.',
      'retryLeaderboard': 'ශ්‍රේණිගත පුවරුව නැවත ලබාගන්න',
      'noLeaderboardDataYet': 'ශ්‍රේණිගත දත්ත තවම නොමැත.',
      'unknown': 'නොදන්නා',
      'approvedSuffix': 'අනුමත',
      'preparingSessionTitle': 'ඔබේ සැසිය සකස් කරමින්',
      'preparingSessionMessage':
          'ඔබගේ පිවිසුම් ටෝකනය සකස් කරමින් පවතී. කරුණාකර නැවත උත්සාහ කරන්න.',
      'signInRequiredTitle': 'පිවිසුම අවශ්‍යයි',
      'signInRequiredMessage': 'ඔබේ පැතිකඩට පිවිසීමට කරුණාකර පිවිසෙන්න.',
      'sessionExpiredTitle': 'සැසිය කල් ඉකුත් වී ඇත',
      'sessionExpiredMessage':
          'ඔබගේ පිවිසුම් සැසිය කල් ඉකුත් වී ඇත. ඉදිරියට යාමට නැවත පිවිසෙන්න.',
      'creatingProfileTitle': 'ඔබේ පැතිකඩ සාදමින්',
      'creatingProfileMessage':
          'ඔබේ ගිණුම තවම සමමුහුර්ත කළ නොහැකි විය. සකස් කිරීම සම්පූර්ණ කිරීමට නැවත උත්සාහ කරන්න.',
      'noInternetTitle': 'අන්තර්ජාල සම්බන්ධතාවයක් නැත',
      'noInternetMessage': 'අන්තර්ජාලයට සම්බන්ධ වී පැතිකඩ නැවත පූරණය කරන්න.',
      'accessDeniedTitle': 'ප්‍රවේශය ප්‍රතික්ෂේපිතයි',
      'accessDeniedMessage':
          'දැනට මෙම පැතිකඩ ඉල්ලීමට අවසර නොමැත. නැවත පිවිසී බලන්න.',
      'serverErrorTitle': 'සේවාදායක දෝෂයක්',
      'serverErrorMessage':
          'සේවාදායකය දැනට ලබාගත නොහැක. ටික වේලාවකින් නැවත උත්සාහ කරන්න.',
      'unableLoadProfileTitle': 'පැතිකඩ පූරණය කළ නොහැක',
      'unableLoadProfileMessage':
          'අනපේක්ෂිත දෝෂයක් සිදු විය. නැවත උත්සාහ කරන්න.',
      'errorLoadingProfileTitle': 'පැතිකඩ පූරණය දෝෂයකි',
      'errorLoadingProfileMessage':
          'පැතිකඩ දත්ත පූරණයේදී අනපේක්ෂිත දෝෂයක් සිදු විය.',
      'logoutConfirmTitle': 'ඉවත් වීම',
      'logoutConfirmMessage': 'ඔබට සැබවින්ම ඉවත් වීමට අවශ්‍යද?',
      'cancel': 'අවලංගු කරන්න',
      'errorPrefix': 'දෝෂය:',
      'submitNewPlaceTitle': 'නව ස්ථානයක් ඉදිරිපත් කරන්න',
      'placeName': 'ස්ථානයේ නම',
      'min3Characters': 'අක්ෂර 3ක් හෝ වැඩි ප්‍රමාණයක් ඇතුළත් කරන්න',
      'description': 'විස්තරය',
      'atLeast50Characters': 'අවම වශයෙන් අක්ෂර 50ක්',
      'descriptionMin50': 'විස්තරය අවම වශයෙන් අක්ෂර 50ක් විය යුතුය',
      'category': 'වර්ගය',
      'province': 'පළාත',
      'provinceRequired': 'පළාත අවශ්‍යයි',
      'district': 'දිස්ත්‍රික්කය',
      'pickPhotosMin2': 'ඡායාරූප තෝරන්න (අවම 2)',
      'photosSelectedSuffix': 'ඡායාරූප තෝරා ඇත',
      'selectAtLeast2Photos': 'කරුණාකර අවම වශයෙන් ඡායාරූප 2ක් තෝරන්න',
      'autoLocationFailed':
          'ස්ථානය ස්වයංක්‍රීයව හඳුනාගත නොහැකි විය. නම/පළාත/දිස්ත්‍රික්කය නිවැරදි කර නැවත උත්සාහ කරන්න.',
      'submissionFailedPrefix': 'ඉදිරිපත් කිරීම අසාර්ථකයි:',
      'placeSubmittedSuccess': 'සමාලෝචනය සඳහා ස්ථානය සාර්ථකව ඉදිරිපත් කරන ලදී!',
      'submitForReview': 'සමාලෝචනයට ඉදිරිපත් කරන්න',
      'submissionReviewNote':
          'ඔබේ ඉදිරිපත් කිරීම ප්‍රසිද්ධ කිරීමට පෙර පරිපාලකයින් විසින් සමාලෝචනය කරනු ඇත.',
      'loadMoreContributions': 'තවත් දායකත්ව පූරණය',
      'loadMoreLeaderboard': 'තවත් ශ්‍රේණිගත දත්ත පූරණය',
      'editProfileTitle': 'පැතිකඩ සංස්කරණය',
      'save': 'සුරකින්න',
      'saving': 'සුරකිනවා...',
      'changePhoto': 'ඡායාරූපය වෙනස් කරන්න',
      'takePhoto': 'ඡායාරූපයක් ගන්න',
      'chooseFromGallery': 'ගැලරියෙන් තෝරන්න',
      'fieldsInvalid': 'කරුණාකර දක්වා ඇති ක්ෂේත්‍ර නිවැරදි කරන්න.',
      'avatarUploadConnectionFailed':
          'ඡායාරූප උඩුගත කිරීම අසාර්ථකයි. සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.',
      'avatarUploadRetryFailed':
          'ඡායාරූප උඩුගත කිරීම අසාර්ථකයි. නැවත උත්සාහ කිරීමට බොත්තම ඔබන්න.',
      'saveFailed': 'සුරැකීම අසාර්ථකයි. කරුණාකර නැවත උත්සාහ කරන්න.',
      'profileUpdated': 'පැතිකඩ යාවත්කාලීන කළා!',
      'displayName': 'ප්‍රදර්ශන නම',
      'displayNameHint': 'ඔබගේ නම ඇතුළත් කරන්න',
      'displayNameHelper': 'මෙය ශ්‍රේණිගත ලැයිස්තුවේ සහ පැතිකඩේ පෙන්වයි',
      'nameCannotBeEmpty': 'නම හිස් විය නොහැක',
      'bioHint': 'ඔබ කුමන වර්ගයේ සංචාරකයෙක්ද කියා සඳහන් කරන්න',
      'hometownDistrict': 'උපන් ගම් දිස්ත්‍රික්කය',
      'hometownDistrictHint': 'උදා: කොළඹ',
      'hometownDistrictHelper': 'දේශීය යෝජනා පුද්ගලීකරණයට භාවිතා වේ',
      'districtCannotBeEmpty': 'දිස්ත්‍රික්කය හිස් විය නොහැක',
      'preferredLanguage': 'වඩාත් කැමති භාෂාව',
      'travelInterestsPrefix': 'සංචාරක රුචිකත්ව',
      'email': 'විද්‍යුත් තැපෑල',
      'emailReadOnlyHelper': 'විද්‍යුත් තැපෑල මෙහි වෙනස් කළ නොහැක',
      'saveChanges': 'වෙනස්කම් සුරකින්න',
      'discardChangesTitle': 'වෙනස්කම් අත්හරින්නද?',
      'discardChangesMessage':
          'ඔබට සුරකින නොලද පැතිකඩ වෙනස්කම් ඇත. සුරැකීමකින් තොරව පිටවෙන්නද?',
      'keepEditing': 'සංස්කරණය కొనసాగන්න',
      'discard': 'අත්හරින්න',
      'cropAvatarTitle': 'පැතිකඩ ඡායාරූපය කපන්න',
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
      'myProfile': 'என் சுயவிவரம்',
      'moderationQueue': 'மதிப்பாய்வு வரிசை',
      'retry': 'மீண்டும் முயற்சி',
      'signInAgain': 'மீண்டும் உள்நுழைக',
      'profileNotFound': 'சுயவிவரம் கிடைக்கவில்லை',
      'profileNotFoundBody':
          'இந்த கணக்கிற்கு இன்னும் சுயவிவரம் இல்லை. கணக்கை அமைக்க மீண்டும் முயற்சிக்கவும்.',
      'tryAgain': 'மீண்டும் முயற்சி',
      'badgesEarned': 'பெற்ற பதக்கங்கள்',
      'contributedPlaces': 'நீங்கள் வழங்கிய இடங்கள்',
      'topContributors': 'சிறந்த பங்களிப்பாளர்கள்',
      'editProfile': 'சுயவிவரம் திருத்து',
      'submitPlace': 'இடம் சமர்ப்பிக்க',
      'all': 'அனைத்தும்',
      'pending': 'நிலுவையில்',
      'approved': 'அங்கீகரிக்கப்பட்டது',
      'rejected': 'நிராகரிக்கப்பட்டது',
      'newest': 'புதியது',
      'oldest': 'பழையது',
      'status': 'நிலை',
      'languagePrefix': 'மொழி:',
      'submitted': 'சமர்ப்பிக்கப்பட்டது',
      'approvalRate': 'அங்கீகார விகிதம்',
      'districtsUnlocked': 'திறக்கப்பட்ட மாவட்டங்கள்',
      'provincesUnlocked': 'திறக்கப்பட்ட மாகாணங்கள்',
      'placesVisited': 'பார்வையிட்ட இடங்கள்',
      'contributionsLoadError': 'பங்களிப்புகளை இப்போது ஏற்ற முடியவில்லை.',
      'retryContributions': 'பங்களிப்புகளை மீண்டும் ஏற்று',
      'noSubmissionsInView': 'இந்த பார்வையில் இன்னும் சமர்ப்பிப்புகள் இல்லை.',
      'submittedPrefix': 'சமர்ப்பித்த தேதி:',
      'reasonPrefix': 'காரணம்:',
      'viewDetails': 'விவரங்கள் காண்க',
      'pendingReview': 'மதிப்பாய்வுக்காக நிலுவையில்',
      'globalRankPrefix': 'உலக தரவரிசை:',
      'impactPrefix': 'பாதிப்பு:',
      'impactSuffix': 'பயனர்கள் உங்கள் இடங்களை பார்வையிட்டனர்',
      'leaderboardLoadError': 'தரவரிசைப் பட்டியலை ஏற்ற முடியவில்லை.',
      'retryLeaderboard': 'தரவரிசையை மீண்டும் ஏற்று',
      'noLeaderboardDataYet': 'தரவரிசை தரவு இன்னும் இல்லை.',
      'unknown': 'தெரியாது',
      'approvedSuffix': 'அங்கீகரிக்கப்பட்டது',
      'preparingSessionTitle': 'உங்கள் அமர்வு தயாராகிறது',
      'preparingSessionMessage':
          'உங்கள் உள்நுழைவு டோக்கன் இன்னும் தயாராகிறது. மீண்டும் முயற்சிக்கவும்.',
      'signInRequiredTitle': 'உள்நுழைவு தேவை',
      'signInRequiredMessage': 'உங்கள் சுயவிவரத்தை அணுக உள்நுழைக.',
      'sessionExpiredTitle': 'அமர்வு காலாவதியானது',
      'sessionExpiredMessage':
          'உங்கள் உள்நுழைவு அமர்வு காலாவதியானது. தொடர மீண்டும் உள்நுழைக.',
      'creatingProfileTitle': 'உங்கள் சுயவிவரம் உருவாகிறது',
      'creatingProfileMessage':
          'உங்கள் கணக்கை இன்னும் ஒத்திசைக்க முடியவில்லை. அமைப்பை முடிக்க மீண்டும் முயற்சிக்கவும்.',
      'noInternetTitle': 'இணைய இணைப்பு இல்லை',
      'noInternetMessage':
          'இணையத்துடன் இணைந்து உங்கள் சுயவிவரத்தை மீண்டும் ஏற்றவும்.',
      'accessDeniedTitle': 'அணுகல் மறுக்கப்பட்டது',
      'accessDeniedMessage':
          'இந்த சுயவிவர கோரிக்கை தற்போது அனுமதிக்கப்படவில்லை. மீண்டும் உள்நுழைந்து முயற்சிக்கவும்.',
      'serverErrorTitle': 'சேவையக பிழை',
      'serverErrorMessage':
          'சேவையகம் தற்போது கிடைக்கவில்லை. சிறிது நேரம் கழித்து முயற்சிக்கவும்.',
      'unableLoadProfileTitle': 'சுயவிவரத்தை ஏற்ற முடியவில்லை',
      'unableLoadProfileMessage':
          'எதிர்பாராத பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.',
      'errorLoadingProfileTitle': 'சுயவிவரம் ஏற்றும் பிழை',
      'errorLoadingProfileMessage':
          'சுயவிவரத் தரவை ஏற்றும் போது எதிர்பாராத பிழை ஏற்பட்டது.',
      'logoutConfirmTitle': 'வெளியேறு',
      'logoutConfirmMessage': 'உண்மையிலேயே வெளியேற வேண்டுமா?',
      'cancel': 'ரத்து செய்',
      'errorPrefix': 'பிழை:',
      'submitNewPlaceTitle': 'புதிய இடம் சமர்ப்பிக்க',
      'placeName': 'இடத்தின் பெயர்',
      'min3Characters': 'குறைந்தது 3 எழுத்துகள் உள்ளிடுக',
      'description': 'விவரம்',
      'atLeast50Characters': 'குறைந்தது 50 எழுத்துகள்',
      'descriptionMin50': 'விவரம் குறைந்தது 50 எழுத்துகள் இருக்க வேண்டும்',
      'category': 'வகை',
      'province': 'மாகாணம்',
      'provinceRequired': 'மாகாணம் அவசியம்',
      'district': 'மாவட்டம்',
      'pickPhotosMin2': 'புகைப்படங்கள் தேர்வு (குறைந்தது 2)',
      'photosSelectedSuffix': 'புகைப்படங்கள் தேர்ந்தெடுக்கப்பட்டது',
      'selectAtLeast2Photos': 'குறைந்தது 2 புகைப்படங்கள் தேர்வு செய்யவும்',
      'autoLocationFailed':
          'இடத்தை தானாக கண்டறிய முடியவில்லை. பெயர்/மாகாணம்/மாவட்டம் திருத்தி மீண்டும் முயற்சிக்கவும்.',
      'submissionFailedPrefix': 'சமர்ப்பிப்பு தோல்வி:',
      'placeSubmittedSuccess':
          'மதிப்பாய்விற்காக இடம் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது!',
      'submitForReview': 'மதிப்பாய்விற்காக சமர்ப்பிக்க',
      'submissionReviewNote':
          'உங்கள் சமர்ப்பிப்பு பொதுமக்களுக்கு முன் நிர்வாகிகளால் மதிப்பாய்வு செய்யப்படும்.',
      'loadMoreContributions': 'மேலும் பங்களிப்புகளை ஏற்று',
      'loadMoreLeaderboard': 'மேலும் தரவரிசையை ஏற்று',
      'editProfileTitle': 'சுயவிவரம் திருத்து',
      'save': 'சேமி',
      'saving': 'சேமிக்கப்படுகிறது...',
      'changePhoto': 'புகைப்படம் மாற்று',
      'takePhoto': 'புகைப்படம் எடு',
      'chooseFromGallery': 'கேலரியிலிருந்து தேர்வு செய்',
      'fieldsInvalid': 'தயவு செய்து குறிக்கப்பட்ட புலங்களை சரிசெய்யவும்.',
      'avatarUploadConnectionFailed':
          'அவதார் பதிவேற்றம் தோல்வி. இணைப்பை சரிபார்த்து மீண்டும் முயற்சிக்கவும்.',
      'avatarUploadRetryFailed':
          'அவதார் பதிவேற்றம் தோல்வி. மீண்டும் முயற்சிக்க பொத்தானை அழுத்தவும்.',
      'saveFailed': 'சேமிப்பு தோல்வி. மீண்டும் முயற்சிக்கவும்.',
      'profileUpdated': 'சுயவிவரம் புதுப்பிக்கப்பட்டது!',
      'displayName': 'காட்சிப் பெயர்',
      'displayNameHint': 'உங்கள் பெயரை உள்ளிடுக',
      'displayNameHelper': 'இது தரவரிசை மற்றும் சுயவிவரத்தில் தெரியும்',
      'nameCannotBeEmpty': 'பெயர் காலியாக இருக்க முடியாது',
      'bioHint': 'நீங்கள் எந்த வகை பயணி என்பதை பகிரவும்',
      'hometownDistrict': 'சொந்த ஊர் மாவட்டம்',
      'hometownDistrictHint': 'எ.கா. கொழும்பு',
      'hometownDistrictHelper': 'உள்ளூர் பரிந்துரைகளை தனிப்பயனாக்க பயன்படும்',
      'districtCannotBeEmpty': 'மாவட்டம் காலியாக இருக்க முடியாது',
      'preferredLanguage': 'விரும்பிய மொழி',
      'travelInterestsPrefix': 'பயண விருப்பங்கள்',
      'email': 'மின்னஞ்சல்',
      'emailReadOnlyHelper': 'மின்னஞ்சலை இங்கு மாற்ற முடியாது',
      'saveChanges': 'மாற்றங்களை சேமி',
      'discardChangesTitle': 'மாற்றங்களை நிராகரிக்கவா?',
      'discardChangesMessage':
          'சேமிக்காத சுயவிவர மாற்றங்கள் உள்ளன. சேமிக்காமல் வெளியேறவா?',
      'keepEditing': 'திருத்தத்தை தொடர்க',
      'discard': 'நிராகரி',
      'cropAvatarTitle': 'அவதார் வெட்டு',
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
  String get loadMoreContributions => _value('loadMoreContributions');
  String get loadMoreLeaderboard => _value('loadMoreLeaderboard');
  String get editProfileTitle => _value('editProfileTitle');
  String get save => _value('save');
  String get saving => _value('saving');
  String get changePhoto => _value('changePhoto');
  String get takePhoto => _value('takePhoto');
  String get chooseFromGallery => _value('chooseFromGallery');
  String get fieldsInvalid => _value('fieldsInvalid');
  String get avatarUploadConnectionFailed =>
      _value('avatarUploadConnectionFailed');
  String get avatarUploadRetryFailed => _value('avatarUploadRetryFailed');
  String get saveFailed => _value('saveFailed');
  String get profileUpdated => _value('profileUpdated');
  String get displayName => _value('displayName');
  String get displayNameHint => _value('displayNameHint');
  String get displayNameHelper => _value('displayNameHelper');
  String get nameCannotBeEmpty => _value('nameCannotBeEmpty');
  String get bioHint => _value('bioHint');
  String get hometownDistrict => _value('hometownDistrict');
  String get hometownDistrictHint => _value('hometownDistrictHint');
  String get hometownDistrictHelper => _value('hometownDistrictHelper');
  String get districtCannotBeEmpty => _value('districtCannotBeEmpty');
  String get preferredLanguage => _value('preferredLanguage');
  String get travelInterestsPrefix => _value('travelInterestsPrefix');
  String get email => _value('email');
  String get emailReadOnlyHelper => _value('emailReadOnlyHelper');
  String get saveChanges => _value('saveChanges');
  String get discardChangesTitle => _value('discardChangesTitle');
  String get discardChangesMessage => _value('discardChangesMessage');
  String get keepEditing => _value('keepEditing');
  String get discard => _value('discard');
  String get cropAvatarTitle => _value('cropAvatarTitle');

  String travelInterestsCount(int selected, int max) {
    return '${_value('travelInterestsPrefix')} ($selected/$max)';
  }
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
