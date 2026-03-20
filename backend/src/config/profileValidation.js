const fs = require('fs');
const path = require('path');

const defaults = {
  minNameLength: 2,
  maxNameLength: 40,
  maxBioLength: 200,
  maxDistrictLength: 60,
  maxLanguageLength: 30,
  maxInterests: 10,
  maxInterestLabelLength: 30,
  supportedLanguages: ['English', 'Sinhala', 'Tamil'],
};

function loadSharedProfileValidation() {
  try {
    const sharedPath = path.resolve(
      __dirname,
      '../../../mobile/assets/config/profile_validation_constraints.json'
    );
    const raw = fs.readFileSync(sharedPath, 'utf8');
    const parsed = JSON.parse(raw);
    return {
      ...defaults,
      ...(parsed && typeof parsed === 'object' ? parsed : {}),
    };
  } catch (_) {
    return defaults;
  }
}

const shared = loadSharedProfileValidation();

module.exports = {
  MIN_NAME_LENGTH: shared.minNameLength,
  MAX_NAME_LENGTH: shared.maxNameLength,
  MAX_BIO_LENGTH: shared.maxBioLength,
  MAX_DISTRICT_LENGTH: shared.maxDistrictLength,
  MAX_LANGUAGE_LENGTH: shared.maxLanguageLength,
  MAX_INTERESTS: shared.maxInterests,
  MAX_INTEREST_LABEL_LENGTH: shared.maxInterestLabelLength,
  SUPPORTED_LANGUAGES: Array.isArray(shared.supportedLanguages)
    ? shared.supportedLanguages
    : defaults.supportedLanguages,
};
