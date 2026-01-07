# Contributing to MAPORIA

> **Thank you for contributing to MAPORIA!**  
> This guide will help you get started and maintain consistency across the project.

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Documentation Standards](#documentation-standards)
6. [Testing Requirements](#testing-requirements)
7. [Commit Guidelines](#commit-guidelines)
8. [Pull Request Process](#pull-request-process)

---

## 🤝 Code of Conduct

- Be respectful and professional
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

---

## 🚀 Getting Started

### Prerequisites

Ensure you have:
- [ ] Read [PROJECT_SOURCE_OF_TRUTH.md](docs/01_planning/PROJECT_SOURCE_OF_TRUTH.md)
- [ ] Setup your local environment (see [Setup Guides](docs/05_setup_guides/))
- [ ] Reviewed the current development phase in [docs/02_implementation/](docs/02_implementation/)

### First Time Setup

1. **Fork and clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/gemified-travel-portfolio.git
cd gemified-travel-portfolio
```

2. **Setup Flutter environment**
```bash
cd mobile
flutter pub get
flutter doctor  # Ensure no issues
```

3. **Setup backend environment** (when ready)
```bash
cd backend
npm install
cp .env.example .env  # Configure environment variables
```

4. **Create a feature branch**
```bash
git checkout -b feature/your-feature-name
```

---

## 💻 Development Workflow

### Branch Naming Convention

```
feature/description   # New features
bugfix/description    # Bug fixes
hotfix/description    # Critical production fixes
docs/description      # Documentation only
refactor/description  # Code refactoring
test/description      # Adding tests

Examples:
feature/auth-login
bugfix/map-marker-crash
docs/api-endpoints
```

### Working on a Feature

1. **Create a branch from `develop`**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature
   ```

2. **Make changes and commit frequently**
   - Small, focused commits
   - Follow commit guidelines (see below)

3. **Keep your branch updated**
   ```bash
   git fetch origin
   git rebase origin/develop
   ```

4. **Push and create PR**
   ```bash
   git push origin feature/your-feature
   ```

---

## 📐 Coding Standards

### Flutter/Dart Standards

#### File Organization
```dart
// 1. Package imports
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 2. Relative imports
import '../../core/theme/app_theme.dart';
import '../models/user.dart';

// 3. Constants
const kDefaultPadding = 16.0;

// 4. Class definition
class MyWidget extends StatelessWidget {
  // Fields
  final String title;
  
  // Constructor
  const MyWidget({Key? key, required this.title}) : super(key: key);
  
  // Methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

#### Naming Conventions
```dart
// Classes: PascalCase
class UserProfile {}

// Variables, functions: camelCase
String userName = '';
void fetchData() {}

// Constants: lowerCamelCase with 'k' prefix
const kPrimaryColor = Colors.blue;

// Private members: underscore prefix
String _privateField = '';
void _privateMethod() {}

// Files: snake_case
// user_profile.dart
// auth_service.dart
```

#### Documentation
```dart
/// Fetches user profile data from the backend.
///
/// [userId] is the unique identifier for the user.
/// 
/// Returns a [User] object if successful, throws [ApiException] otherwise.
/// 
/// Example:
/// ```dart
/// final user = await fetchUserProfile('user123');
/// ```
Future<User> fetchUserProfile(String userId) async {
  // Implementation
}
```

### TypeScript/Node.js Standards

#### File Organization
```typescript
// 1. Third-party imports
import express from 'express';
import { Schema, model } from 'mongoose';

// 2. Local imports
import { requireAuth } from '../middleware/auth';
import { User } from '../models/User';

// 3. Types/Interfaces
interface UserRequest extends Request {
  userId?: string;
}

// 4. Implementation
export class UserController {
  async getProfile(req: UserRequest, res: Response) {
    // Implementation
  }
}
```

#### Naming Conventions
```typescript
// Classes: PascalCase
class UserService {}

// Interfaces: PascalCase with 'I' prefix (optional)
interface IUser {}

// Variables, functions: camelCase
const userName = '';
function fetchData() {}

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'https://api.example.com';

// Files: kebab-case or camelCase
// user-service.ts or userService.ts
// auth-middleware.ts or authMiddleware.ts
```

#### Documentation
```typescript
/**
 * Fetches user profile from database
 * @param userId - The unique user identifier
 * @returns Promise resolving to User object
 * @throws {NotFoundError} When user doesn't exist
 * @example
 * ```typescript
 * const user = await getUserProfile('user123');
 * ```
 */
async function getUserProfile(userId: string): Promise<User> {
  // Implementation
}
```

### Code Quality Rules

✅ **DO**:
- Write self-documenting code
- Keep functions small and focused (< 50 lines)
- Use meaningful variable names
- Handle errors gracefully
- Add comments for complex logic
- Use const/final where possible
- Follow DRY (Don't Repeat Yourself)

❌ **DON'T**:
- Leave commented-out code
- Use magic numbers (use named constants)
- Ignore compiler warnings
- Commit console.log/print statements
- Write deeply nested code (max 3 levels)
- Use abbreviations in names (except common ones)

---

## 📝 Documentation Standards

### When to Document

**Always document**:
- Public APIs and functions
- Complex algorithms
- Non-obvious business logic
- Configuration options
- Breaking changes

**Implementation Documentation**:
Every feature implementation must have a document in `docs/02_implementation/` following this structure:

```markdown
# [Phase X] - [Feature Name] Implementation

> **Phase**: X  
> **Status**: In Progress  
> **Assigned To**: Your Name  
> **Last Updated**: YYYY-MM-DD

## Overview
What this feature does and why it's needed.

## Prerequisites
- [ ] Prerequisite 1
- [ ] Prerequisite 2

## Implementation Steps

### Step 1: Setup
Detailed instructions...

### Step 2: Code
Code examples with explanations...

### Step 3: Testing
How to test...

## Common Issues
- Issue: Solution

## Next Steps
What comes after this feature
```

---

## 🧪 Testing Requirements

### Mobile App Tests

**Required**:
- Unit tests for all business logic
- Widget tests for complex UI
- Integration tests for critical flows

```dart
// Example unit test
test('User model serialization works correctly', () {
  final user = User(id: '1', name: 'Test');
  final json = user.toJson();
  
  expect(json['id'], '1');
  expect(json['name'], 'Test');
});

// Example widget test
testWidgets('Login button submits form', (tester) async {
  await tester.pumpWidget(LoginScreen());
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  verify(mockAuthService.login(any, any)).called(1);
});
```

### Backend Tests

**Required**:
- Unit tests for services and utilities
- Integration tests for API endpoints
- E2E tests for critical user flows

```typescript
// Example unit test
describe('UserService', () => {
  it('should create user successfully', async () => {
    const user = await userService.createUser({
      email: 'test@example.com',
      name: 'Test User'
    });
    
    expect(user.email).toBe('test@example.com');
  });
});

// Example API test
describe('POST /api/auth/register', () => {
  it('should return 201 and user data', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({ email: 'test@example.com', password: 'pass123' });
    
    expect(response.status).toBe(201);
    expect(response.body.user).toBeDefined();
  });
});
```

### Test Coverage Goals

- **Unit Tests**: 70% coverage
- **Integration Tests**: Critical paths covered
- **E2E Tests**: Main user flows

---

## 💬 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks
- **perf**: Performance improvements

### Examples

```bash
# Good commits
feat(auth): add email validation on registration
fix(map): resolve marker positioning issue
docs(api): update authentication endpoints documentation
test(auth): add unit tests for login flow

# Bad commits (avoid these)
fixed stuff
updates
WIP
changes
```

### Commit Best Practices

✅ **DO**:
- Write clear, concise commit messages
- Explain WHAT and WHY, not HOW
- Reference issues: `fixes #123`
- Commit frequently with logical chunks

❌ **DON'T**:
- Commit directly to `main` or `develop`
- Make massive commits with many changes
- Use vague messages like "fix" or "update"
- Commit broken code

---

## 🔄 Pull Request Process

### Before Creating a PR

- [ ] All tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] Commits are clean and well-formatted
- [ ] Branch is up to date with `develop`

### PR Title Format

```
[TYPE] Brief description

Examples:
[FEAT] Add user authentication with Auth0
[FIX] Resolve map marker crash on Android
[DOCS] Update API endpoint documentation
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Related Issues
Fixes #123

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
How did you test this?

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No console errors
```

### Review Process

1. **Create PR** targeting `develop` branch
2. **Automated checks** must pass (CI/CD)
3. **Code review** by at least 1 team member
4. **Address feedback** and update PR
5. **Approval** from reviewer(s)
6. **Merge** using squash or rebase

### PR Review Guidelines

**For Reviewers**:
- Be constructive and respectful
- Test the changes locally
- Check for edge cases
- Verify documentation
- Suggest improvements, don't demand perfection

**For Authors**:
- Respond to all comments
- Be open to feedback
- Explain your decisions
- Update PR based on feedback

---

## 🐛 Bug Reports

### Before Reporting

- [ ] Search existing issues
- [ ] Verify it's actually a bug
- [ ] Test on latest version
- [ ] Gather reproduction steps

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to...
2. Click on...
3. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Screenshots
If applicable

## Environment
- OS: [e.g., Android 13]
- App Version: [e.g., 0.2.0]
- Device: [e.g., Pixel 6]

## Additional Context
Any other relevant information
```

---

## ✨ Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the feature

## Problem It Solves
What user problem does this address?

## Proposed Solution
How should this work?

## Alternatives Considered
Other ways to solve this

## Additional Context
Mockups, examples, etc.
```

---

## 📞 Getting Help

- **Documentation**: Check [docs/README.md](docs/README.md)
- **Team Chat**: [Slack/Discord channel]
- **Issues**: [GitHub Issues](https://github.com/your-repo/issues)
- **Meetings**: Weekly team sync

---

## 🎓 Resources for New Contributors

### Learning Materials
- [Flutter Documentation](https://flutter.dev/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [MongoDB University](https://university.mongodb.com/)
- [Auth0 Quickstarts](https://auth0.com/docs/quickstarts)

### Project-Specific
- [Architecture Docs](docs/03_architecture/)
- [API Documentation](docs/04_api/)
- [Setup Guides](docs/05_setup_guides/)

---

**Thank you for contributing to MAPORIA! 🚀**
