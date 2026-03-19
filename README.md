# MAPORIA - Gemified Travel Portfolio

A gamified travel exploration app for Sri Lanka, with a Flutter mobile client and Node.js backend.

## Project Overview

MAPORIA turns real-world travel into progression: users explore districts, verify visits, unlock regions, and track travel achievements.

## Primary Documentation

- Documentation hub: [docs/README.md](docs/README.md)
- Common docs: [docs/common/README.md](docs/common/README.md)
- Backend docs: [docs/backend/README.md](docs/backend/README.md)
- Frontend docs: [docs/frontend/README.md](docs/frontend/README.md)

## Tech Stack (Current)

- Frontend: Flutter (Dart)
- Backend: Node.js + Express.js (JavaScript)
- Database: MongoDB
- Auth: Firebase Auth (with local bypass support for development)
- Maps: Mapbox + GeoJSON boundaries
- State Management: Riverpod

## Getting Started

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

### Backend

```bash
cd backend
npm install
npm run dev
```

## Repository Layout

```text
gemified-travel-portfolio/
|-- mobile/                # Flutter mobile app (Android/iOS targets)
|-- backend/               # Express API and scripts
|-- docs/                  # Documentation hub and implementation guides
|-- project_resources/     # GeoJSON and seed data resources
|-- scripts/               # Utility scripts for local workflows
|-- README.md
```

## Development Notes

- Current Flutter targets in-repo are mobile-focused.
- Historical status/planning docs are archived under [docs/_archive/](docs/_archive/).
- Project onboarding entry: [START_HERE.md](START_HERE.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

