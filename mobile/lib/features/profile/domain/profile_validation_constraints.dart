class ProfileValidationConstraints {
  static const int minNameLength = 2;
  static const int maxNameLength = 40;
  static const int maxBioLength = 200;
  static const int maxDistrictLength = 60;
  static const int maxInterests = 10;

  static const List<String> supportedLanguages = <String>[
    'English',
    'Sinhala',
    'Tamil',
  ];

  static const List<String> suggestedInterests = <String>[
    'Nature',
    'Hiking',
    'Wildlife',
    'Food',
    'Culture',
    'History',
    'Photography',
    'Beaches',
    'Adventure',
    'City Tours',
  ];
}
