const PROFILE_VALIDATION = {
  MIN_NAME_LENGTH: 2,
  MAX_NAME_LENGTH: 40,
  MAX_BIO_LENGTH: 200,
  MAX_DISTRICT_LENGTH: 60,
  MAX_LANGUAGE_LENGTH: 30,
  MAX_INTERESTS: 10,
  SUPPORTED_LANGUAGES: ['English', 'Sinhala', 'Tamil'],
  MAX_INTEREST_LABEL_LENGTH: 30,
};

/**
 * Account Deletion Data Retention Policy
 * 
 * When a user requests account deletion, the following data is handled:
 * 
 * 1. HARD DELETE (removed immediately):
 *    - User account record and all authN/authZ metadata
 *    - User preferences (language, interests, hometown)
 *    - All draft/rejected contributions (never published)
 *    - Profile avatar and associated storage files
 *    - User badges and achievement metadata
 *    - Direct references in usage tracking (usersWhoAdded links)
 * 
 * 2. HARD DELETE (submission records):
 *    - All PlaceSubmission records (approved, pending, rejected)
 *    - Rationale: While contributions are public-facing, retaining them after
 *      account deletion creates orphaned user references and compliance issues.
 *      Product must decide: full history import/export before deletion, or
 *      accept loss of submission history per user request.
 * 
 * 3. DETACH ONLY (preserved):
 *    - Approved places themselves (remain in Places collection)
 *    - Leaderboard/ranking stats (aggregated, not identifiable post-deletion)
 *    - System metrics and place usage counts (not tied to deleted user after detachment)
 * 
 * Future Policy Options:
 * - ANONYMIZE: Replace user name with "Deleted User" and clear sensitive fields
 *   instead of hard-delete (preserves contribution history, reduces compliance friction).
 * - EXPORT: Offer data export before deletion (24h grace period).
 * - HYBRID: Anonymize approved public contributions, hard-delete user account.
 */
const ACCOUNT_DELETION_POLICY = {
  // Controls whether to hard-delete all submissions or anonymize approved ones
  HARD_DELETE_SUBMISSIONS: true, // Set to false to anonymize instead
};

module.exports = { PROFILE_VALIDATION, ACCOUNT_DELETION_POLICY };
