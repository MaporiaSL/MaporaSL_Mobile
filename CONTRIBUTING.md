# Contributing to MAPORIA

Thanks for contributing.

## Before You Start

- Read the project overview: [docs/core/project-source-of-truth.md](docs/core/project-source-of-truth.md)
- Check implementation direction: [docs/core/implementation-strategy.md](docs/core/implementation-strategy.md)
- Use active docs index: [docs/README.md](docs/README.md)

## Local Setup

### Mobile

```bash
cd mobile
flutter pub get
```

### Backend

```bash
cd backend
npm install
```

## Workflow

1. Create a branch from your target base branch.
2. Keep commits focused and reviewable.
3. Update relevant docs under [docs/](docs/).
4. Run local checks before opening a PR.

## Pull Request Checklist

- Code builds locally.
- Tests (or relevant smoke checks) pass.
- Documentation is updated when behavior changes.
- No secrets or generated artifacts are committed.

