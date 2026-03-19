const test = require('node:test');
const assert = require('node:assert/strict');

const User = require('../../src/models/User');
const { registerUser, getMe } = require('../../src/controllers/authController');

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

test('registerUser returns fieldErrors for invalid payload', async () => {
  const req = {
    userId: 'u-1',
    body: {
      email: '',
      name: '',
      hometownDistrict: '',
    },
  };
  const res = createMockRes();

  await registerUser(req, res);

  assert.equal(res.statusCode, 400);
  assert.equal(res.body.error, 'Invalid profile setup payload');
  assert.equal(res.body.fieldErrors.email, 'Email is required');
  assert.equal(res.body.fieldErrors.name, 'Name is required');
  assert.equal(res.body.fieldErrors.hometownDistrict, 'District is required');
});

test('getMe returns required/optional fields and setup-required=true for incomplete profile', async () => {
  const originalFindOne = User.findOne;

  User.findOne = async () => ({
    auth0Id: 'u-1',
    name: 'Alice',
    email: 'alice@example.com',
    hometownDistrict: '',
    preferredLanguage: 'English',
    profileSetupCompleted: false,
  });

  try {
    const req = { userId: 'u-1' };
    const res = createMockRes();

    await getMe(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.profileSetupRequired, true);
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
  } finally {
    User.findOne = originalFindOne;
  }
});

test('getMe returns setup-required=false for complete profile', async () => {
  const originalFindOne = User.findOne;

  User.findOne = async () => ({
    auth0Id: 'u-1',
    name: 'Alice',
    email: 'alice@example.com',
    hometownDistrict: 'Colombo',
    preferredLanguage: 'English',
    profileSetupCompleted: true,
  });

  try {
    const req = { userId: 'u-1' };
    const res = createMockRes();

    await getMe(req, res);

    assert.equal(res.statusCode, 200);
    assert.equal(res.body.profileSetupRequired, false);
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
  } finally {
    User.findOne = originalFindOne;
  }
});
