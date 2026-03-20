const test = require('node:test');
const assert = require('node:assert/strict');

const User = require('../../src/models/User');
const PlaceSubmission = require('../../src/models/PlaceSubmission');
const UserBadge = require('../../src/models/UserBadge');
const PlaceUsageTracking = require('../../src/models/PlaceUsageTracking');
const {
  updateUserProfile,
  deleteUserAccount,
} = require('../../src/controllers/profileController');

function createMockRes() {
  return {
    statusCode: 200,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
}

test('updateUserProfile returns fieldErrors for invalid payload', async () => {
  const req = {
    userId: 'u-1',
    params: { userId: 'u-1' },
    body: {
      name: 'A',
      travelInterests: 'invalid-type',
    },
  };
  const res = createMockRes();

  await updateUserProfile(req, res);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error, 'Invalid profile payload');
  assert.equal(res.body.fieldErrors.name, 'Name must be at least 2 characters');
  assert.equal(
    res.body.fieldErrors.travelInterests,
    'travelInterests must be a list of strings',
  );
});

test('updateUserProfile with completeSetup returns required contract fields when profile incomplete', async () => {
  const originalFindOne = User.findOne;
  const originalFindOneAndUpdate = User.findOneAndUpdate;

  User.findOne = async () => ({
    auth0Id: 'u-1',
    profilePicture: '',
  });

  User.findOneAndUpdate = async () => ({
    toObject: () => ({
      auth0Id: 'u-1',
      name: '',
      hometownDistrict: '',
      preferredLanguage: '',
      profileSetupCompleted: false,
    }),
    profileSetupCompleted: false,
  });

  try {
    const req = {
      userId: 'u-1',
      params: { userId: 'u-1' },
      body: { completeSetup: true },
    };
    const res = createMockRes();

    await updateUserProfile(req, res);

    assert.equal(res.statusCode, 400);
    assert.equal(res.body.error, 'Profile setup is incomplete');
    assert.deepEqual(res.body.requiredFields, [
      'name',
      'hometownDistrict',
      'preferredLanguage',
    ]);
    assert.deepEqual(res.body.optionalFields, [
      'travelInterests',
      'avatarUrl',
      'bio',
    ]);
    assert.equal(res.body.fieldErrors.name, 'Name is required');
    assert.equal(res.body.fieldErrors.hometownDistrict, 'District is required');
    assert.equal(
      res.body.fieldErrors.preferredLanguage,
      'Preferred language is required',
    );
  } finally {
    User.findOne = originalFindOne;
    User.findOneAndUpdate = originalFindOneAndUpdate;
  }
});

test('updateUserProfile response includes new profile stats fields', async () => {
  const originalFindOne = User.findOne;
  const originalFindOneAndUpdate = User.findOneAndUpdate;
  const originalCountDocuments = PlaceSubmission.countDocuments;
  const originalAggregate = PlaceSubmission.aggregate;
  const originalFind = PlaceSubmission.find;
  const originalBadgeFindOne = UserBadge.findOne;
  const originalUsageFindOne = PlaceUsageTracking.findOne;

  User.findOne = async () => ({
    auth0Id: 'u-1',
    profilePicture: '',
  });

  User.findOneAndUpdate = async () => ({
    auth0Id: 'u-1',
    email: 'a@example.com',
    name: 'Alice',
    profilePicture: '',
    bio: '',
    hometownDistrict: 'Colombo',
    preferredLanguage: 'English',
    travelInterests: [],
    unlockedDistricts: ['d1', 'd2', 'd3'],
    unlockedProvinces: ['p1'],
    totalPlacesVisited: 9,
    explorationUnlockedDistricts: ['d1', 'd2'],
    explorationUnlockedProvinces: ['p1'],
    explorationStats: { totalVisited: 7 },
    profileSetupCompleted: true,
    toObject() {
      return this;
    },
  });

  PlaceSubmission.countDocuments = async (filter) => {
    if (filter && filter.status === 'approved') return 2;
    return 5;
  };
  PlaceSubmission.aggregate = async () => [{ _id: 'u-1', approvedCount: 2 }];
  PlaceSubmission.find = async () => [{ _id: 's1' }, { _id: 's2' }];
  UserBadge.findOne = async () => ({ badges: [] });
  PlaceUsageTracking.findOne = async () => ({ totalTimesAdded: 3 });

  try {
    const req = {
      userId: 'u-1',
      params: { userId: 'u-1' },
      body: { name: 'Alice' },
    };
    const res = createMockRes();

    await updateUserProfile(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.stats.unlockedDistrictsCount, 3);
    assert.equal(res.body.stats.unlockedProvincesCount, 1);
    assert.equal(res.body.stats.totalPlacesVisited, 9);
  } finally {
    User.findOne = originalFindOne;
    User.findOneAndUpdate = originalFindOneAndUpdate;
    PlaceSubmission.countDocuments = originalCountDocuments;
    PlaceSubmission.aggregate = originalAggregate;
    PlaceSubmission.find = originalFind;
    UserBadge.findOne = originalBadgeFindOne;
    PlaceUsageTracking.findOne = originalUsageFindOne;
  }
});

test('deleteUserAccount returns 403 when deleting another user account', async () => {
  const req = {
    userId: 'u-1',
    params: { userId: 'u-2' },
  };
  const res = createMockRes();

  await deleteUserAccount(req, res);

  assert.equal(res.statusCode, 403);
  assert.match(res.body.error, /Forbidden/);
});

test('deleteUserAccount cascades cleanup and returns audit contract', async () => {
  const originalUserFindOne = User.findOne;
  const originalUserDeleteOne = User.deleteOne;
  const originalSubmissionFind = PlaceSubmission.find;
  const originalSubmissionDeleteMany = PlaceSubmission.deleteMany;
  const originalBadgeDeleteMany = UserBadge.deleteMany;
  const originalUsageDeleteMany = PlaceUsageTracking.deleteMany;
  const originalUsageUpdateMany = PlaceUsageTracking.updateMany;

  User.findOne = async () => ({
    auth0Id: 'u-1',
    profilePicture: '',
  });
  User.deleteOne = async () => ({ deletedCount: 1 });
  PlaceSubmission.find = async () => [{ _id: 's1' }, { _id: 's2' }];
  PlaceSubmission.deleteMany = async () => ({ deletedCount: 2 });
  UserBadge.deleteMany = async () => ({ deletedCount: 1 });
  PlaceUsageTracking.deleteMany = async () => ({ deletedCount: 2 });
  PlaceUsageTracking.updateMany = async () => ({ modifiedCount: 1 });

  try {
    const req = {
      userId: 'u-1',
      params: { userId: 'u-1' },
    };
    const res = createMockRes();

    await deleteUserAccount(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.cleanup.userDeleted, 1);
    assert.equal(res.body.cleanup.submissionsDeleted, 2);
    assert.equal(res.body.cleanup.badgesDeleted, 1);
    assert.equal(res.body.cleanup.usageDocsDeleted, 2);
    assert.equal(res.body.cleanup.usageLinksDetached, 1);
    assert.ok(res.body.audit.requestId);
    assert.ok(res.body.audit.timestamp);
  } finally {
    User.findOne = originalUserFindOne;
    User.deleteOne = originalUserDeleteOne;
    PlaceSubmission.find = originalSubmissionFind;
    PlaceSubmission.deleteMany = originalSubmissionDeleteMany;
    UserBadge.deleteMany = originalBadgeDeleteMany;
    PlaceUsageTracking.deleteMany = originalUsageDeleteMany;
    PlaceUsageTracking.updateMany = originalUsageUpdateMany;
  }
});
