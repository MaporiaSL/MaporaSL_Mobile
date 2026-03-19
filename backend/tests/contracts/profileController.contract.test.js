const test = require('node:test');
const assert = require('node:assert/strict');

const User = require('../../src/models/User');
const { updateUserProfile } = require('../../src/controllers/profileController');

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
  const originalFindOneAndUpdate = User.findOneAndUpdate;

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
    User.findOneAndUpdate = originalFindOneAndUpdate;
  }
});
