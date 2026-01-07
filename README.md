# MAPORIA - Gemified Travel Portfolio

> **A gamified travel exploration app for Sri Lanka**  
> Transform your travels into an interactive adventure with achievements, maps, and social sharing.

---

## 🎯 Project Overview

MAPORIA is a mobile-first application that gamifies real-world travel across Sri Lanka. Users unlock districts and provinces by visiting places, earn achievements, plan trips, and share their journey with others.

### Key Features
- 🗺️ **Interactive Sri Lanka Map** with fog-of-war mechanics
- 📍 **GPS-based Place Visits** with automatic verification
- 🏆 **Achievement System** for completing districts and provinces
- 🚶 **Trip Planning** with route visualization
- 📸 **Photo Documentation** with branded overlays
- 👥 **Social Sharing** of achievements and progress
- 🎨 **Gamification** with unlockables and progress tracking

---

## 📚 Documentation

**Start here**: [Documentation Index](docs/README.md)

### Quick Links
- **Project Overview**: [PROJECT_SOURCE_OF_TRUTH.md](docs/01_planning/PROJECT_SOURCE_OF_TRUTH.md)
- **Tech Stack**: [TECH_STACK.md](docs/01_planning/TECH_STACK.md)
- **Implementation Guide**: [docs/02_implementation/](docs/02_implementation/)
- **Setup Guides**: [docs/05_setup_guides/](docs/05_setup_guides/)

---

## 🛠️ Technology Stack

| Component | Technology |
|-----------|-----------|
| **Frontend** | Flutter (Dart) |
| **Backend** | Node.js + Express.js (TypeScript) |
| **Database** | MongoDB Atlas |
| **Authentication** | Auth0 |
| **File Storage** | Firebase Storage |
| **Maps** | Mapbox |
| **Notifications** | Firebase Cloud Messaging |
| **State Management** | Riverpod |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Node.js 18+
- MongoDB Atlas account (free)
- Auth0 account (free)
- Firebase account (free)
- Mapbox account (free)

### Quick Setup

#### 1. Clone the Repository
```bash
git clone https://github.com/your-username/gemified-travel-portfolio.git
cd gemified-travel-portfolio
```

#### 2. Mobile App Setup
```bash
cd mobile
flutter pub get
flutter run
```

#### 3. Backend Setup
```bash
cd backend
npm install
npm run dev
```

**For detailed setup instructions**: See [docs/05_setup_guides/](docs/05_setup_guides/)

---

## 📂 Project Structure

```
gemified-travel-portfolio/
├── mobile/                  # Flutter mobile app
│   ├── lib/
│   │   ├── core/           # Core utilities, services, theme
│   │   ├── data/           # Data models and repositories
│   │   ├── features/       # Feature modules
│   │   ├── providers/      # Riverpod providers
│   │   └── main.dart       # App entry point
│   ├── test/               # Unit and widget tests
│   └── pubspec.yaml        # Flutter dependencies
│
├── backend/                # Express.js API (TO BE SETUP)
│   ├── src/
│   │   ├── config/         # Configuration
│   │   ├── middleware/     # Auth, error handling
│   │   ├── models/         # Mongoose schemas
│   │   ├── routes/         # API routes
│   │   ├── controllers/    # Request handlers
│   │   └── services/       # Business logic
│   ├── package.json        # Node dependencies
│   └── tsconfig.json       # TypeScript config
│
├── docs/                   # Documentation
│   ├── 01_planning/        # Planning documents
│   ├── 02_implementation/  # Implementation guides
│   ├── 03_architecture/    # Architecture docs
│   ├── 04_api/             # API documentation
│   ├── 05_setup_guides/    # Setup instructions
│   ├── 06_meeting_notes/   # Team meeting notes
│   └── README.md           # Documentation index
│
├── project_resources/      # GeoJSON files, boundaries
├── .github/                # GitHub workflows, templates
├── CHANGELOG.md            # Project changelog
└── README.md               # This file
```

---

## 🏗️ Development Status

### Phase 1: Authentication & User Management (CURRENT)
- [ ] Backend project setup
- [ ] MongoDB connection
- [ ] Auth0 integration
- [ ] User registration/login
- [ ] Data isolation

### Phase 2: Map Integration (PLANNED)
- [ ] Mapbox setup
- [ ] Sri Lanka boundaries
- [ ] Place markers
- [ ] Fog/cloud system

### Phase 3-6: Future Phases
See [Implementation Strategy](docs/01_planning/IMPLEMENTATION_STRATEGY.md) for full roadmap

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### For Team Members

1. **Read the documentation**: Start with [docs/README.md](docs/README.md)
2. **Check current phase**: See `docs/02_implementation/` for active tasks
3. **Follow coding standards**: See [CONTRIBUTING.md](CONTRIBUTING.md) (to be created)
4. **Document your work**: Update relevant docs as you implement

### Workflow

1. Create a feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes with detailed commits
3. Update documentation
4. Test thoroughly
5. Submit a pull request

### Code Review Process

- All code requires review by at least one team member
- All tests must pass
- Documentation must be updated
- Follow the project's coding standards

---

## 🧪 Testing

### Mobile App
```bash
cd mobile
flutter test                  # Unit tests
flutter test integration_test # Integration tests
```

### Backend
```bash
cd backend
npm test                      # Unit tests
npm run test:e2e             # E2E tests
```

---

## 📱 Platforms

| Platform | Status | Priority |
|----------|--------|----------|
| Android | ✅ Active Development | Primary |
| iOS | 🔜 Planned | Secondary |
| Web | 🔜 Planned | Future |
| Desktop | ❌ Not Planned | - |

---

## 🔐 Security

### Important Notes
- Never commit API keys, tokens, or secrets
- Use environment variables for all sensitive data
- Follow security best practices in [docs/03_architecture/](docs/03_architecture/)

### Reporting Security Issues
Please report security vulnerabilities to [security@example.com] privately.

---

## 📜 License

[License Type] - See [LICENSE](LICENSE) file for details

---

## 👥 Team

- **Project Lead**: [Name]
- **Tech Lead**: [Name]
- **Backend Team**: [Names]
- **Frontend Team**: [Names]
- **Design**: [Names]

---

## 📞 Contact & Support

- **Documentation**: [docs/README.md](docs/README.md)
- **Issues**: [GitHub Issues](https://github.com/your-username/gemified-travel-portfolio/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/gemified-travel-portfolio/discussions)
- **Email**: [team@example.com]

---

## 🙏 Acknowledgments

- GeoJSON data from [geoBoundaries](https://www.geoboundaries.org/)
- Sri Lanka administrative boundaries from GADM
- Mapbox for mapping services
- Firebase for backend services
- The Flutter and Node.js communities

---

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/your-username/gemified-travel-portfolio)
![GitHub forks](https://img.shields.io/github/forks/your-username/gemified-travel-portfolio)
![GitHub issues](https://img.shields.io/github/issues/your-username/gemified-travel-portfolio)
![GitHub license](https://img.shields.io/github/license/your-username/gemified-travel-portfolio)

---

**Last Updated**: January 7, 2026  
**Version**: 0.2.0  
**Status**: 🚧 Active Development - Phase 1 (Authentication)
