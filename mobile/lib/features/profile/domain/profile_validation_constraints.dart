import 'dart:convert';

import 'package:flutter/services.dart';

class ProfileValidationConstraints {
  static const String _assetPath =
      'assets/config/profile_validation_constraints.json';

  static int _minNameLength = 2;
  static int _maxNameLength = 40;
  static int _maxBioLength = 200;
  static int _maxDistrictLength = 60;
  static int _maxLanguageLength = 30;
  static int _maxInterests = 10;
  static int _maxInterestLabelLength = 30;

  static List<String> _supportedLanguages = const <String>[
    'English',
    'Sinhala',
    'Tamil',
  ];

  static List<String> _suggestedInterests = const <String>[
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

  static Future<void>? _loadFuture;

  static int get minNameLength => _minNameLength;
  static int get maxNameLength => _maxNameLength;
  static int get maxBioLength => _maxBioLength;
  static int get maxDistrictLength => _maxDistrictLength;
  static int get maxLanguageLength => _maxLanguageLength;
  static int get maxInterests => _maxInterests;
  static int get maxInterestLabelLength => _maxInterestLabelLength;
  static List<String> get supportedLanguages => List.unmodifiable(_supportedLanguages);
  static List<String> get suggestedInterests => List.unmodifiable(_suggestedInterests);

  static Future<void> loadFromAssetIfNeeded() {
    _loadFuture ??= _loadFromAsset();
    return _loadFuture!;
  }

  static Future<void> _loadFromAsset() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;

      _minNameLength = _readInt(decoded, 'minNameLength', _minNameLength);
      _maxNameLength = _readInt(decoded, 'maxNameLength', _maxNameLength);
      _maxBioLength = _readInt(decoded, 'maxBioLength', _maxBioLength);
      _maxDistrictLength = _readInt(
        decoded,
        'maxDistrictLength',
        _maxDistrictLength,
      );
      _maxLanguageLength = _readInt(
        decoded,
        'maxLanguageLength',
        _maxLanguageLength,
      );
      _maxInterests = _readInt(decoded, 'maxInterests', _maxInterests);
      _maxInterestLabelLength = _readInt(
        decoded,
        'maxInterestLabelLength',
        _maxInterestLabelLength,
      );

      _supportedLanguages = _readStringList(
        decoded,
        'supportedLanguages',
        _supportedLanguages,
      );
      _suggestedInterests = _readStringList(
        decoded,
        'suggestedInterests',
        _suggestedInterests,
      );
    } catch (_) {
      // Keep safe defaults when asset is unavailable.
    }
  }

  static int _readInt(Map<String, dynamic> map, String key, int fallback) {
    final value = map[key];
    return value is num ? value.toInt() : fallback;
  }

  static List<String> _readStringList(
    Map<String, dynamic> map,
    String key,
    List<String> fallback,
  ) {
    final value = map[key];
    if (value is! List) return fallback;
    final result = value.whereType<String>().where((e) => e.isNotEmpty).toList();
    return result.isEmpty ? fallback : result;
  }
}
