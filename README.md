# MAPORIA - Gemified Travel Portfolio

> **A gamified travel exploration app for Sri Lanka**  
> Transform your travels into an interactive adventure with achievements, maps, and social sharing.

---

## 🎯 Project Overview

MAPORIA is a mobile-first application that gamifies real-world travel across Sri Lanka. Users unlock districts and provinces by visiting places, earn achievements, plan trips, and share their journey with others.

### Key Features
- 🗺️ **Interactive Sri Lanka Map** with fog-of-war mechanics and cloud reveal system
- 🏙️ **Places Discovery** - 50+ curated attractions + community contributions with verification
- 📍 **GPS-based Place Visits** with automatic verification and navigation to Google Maps pins
- 🏆 **Achievement System** for completing districts and provinces
- 🚶 **Trip Planning** (pre-planned + custom) with route visualization and estimated duration
- 📸 **Photo Documentation** with geotagging and branded overlays
- 👥 **Social Sharing** of achievements, progress, and contributed places
- 🎨 **Gamification** with badges, leaderboard, and contributor recognition

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
git clone https://github.com/maporiasl/gemified-travel-portfolio.git
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

### Phase 1: Authentication & User Management ✅ COMPLETE
- [x] Backend project setup
- [x] MongoDB connection
- [x] Auth0 integration
- [x] User registration/login
- [x] Data isolation

### Phase 2: Map Integration ✅ COMPLETE
- [x] Mapbox setup
- [x] Sri Lanka boundaries
- [x] Place markers
- [x] Fog/cloud system

### Phase 3: Trip Planning & Memory Lane ✅ COMPLETE
- [x] Pre-planned trips database
- [x] Custom trip creation
- [x] Memory lane timeline
- [x] Trip-place associations

### Phase 4: Places System 🚀 IN PROGRESS
- [x] Feature specification & planning (42 curated attractions)
- [x] Google Maps integration with deep links
- [ ] Backend API implementation
- [ ] User submission & verification workflow
- [ ] Admin dashboard
- [ ] Gamification badges & leaderboard

See [Implementation Strategy](docs/01_planning/IMPLEMENTATION_STRATEGY.md) and [Places Planning](docs/06_implementation/PLACES_FEATURE_SPEC.md) for full roadmap

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
Please report security vulnerabilities to [info@maporiasl.com] privately.

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 👥 Team

<div align="center">

<table>
	<tr>
		<td align="center" width="180">
			<a href="https://github.com/anucr" title="Anuk Ranasinghe">
				<img src="https://avatars.githubusercontent.com/anucr?s=100" width="100" alt="Anuk Ranasinghe" />
			</a>
			<br/><b>Anuk Ranasinghe</b>
			<br/><sub>Frontend Developer</sub>
			<br/>
			<a href="https://github.com/anucr" title="GitHub: anucr">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/github.svg" width="18" alt="GitHub" />
			</a>
		</td>
		<td align="center" width="180">
			<a href="https://github.com/Anuja-jayasinghe" title="Anuja Jayasinghe">
				<img src="https://avatars.githubusercontent.com/Anuja-jayasinghe?s=100" width="100" alt="Anuja Jayasinghe" />
			</a>
			<br/><b>Anuja Jayasinghe</b>
			<br/><sub>Backend Developer</sub>
			<br/>
			<a href="https://github.com/Anuja-jayasinghe" title="GitHub: Anuja-jayasinghe">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/github.svg" width="18" alt="GitHub" />
			</a>
			&nbsp;
			<a href="https://www.linkedin.com/in/anuja-jayasinghe/" title="LinkedIn: Anuja Jayasinghe">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/linkedin.svg" width="18" alt="LinkedIn" />
			</a>
		</td>
		<td align="center" width="180">
			<a href="https://github.com/PudamyaYamini" title="Pudamya Yamini">
				<img src="https://avatars.githubusercontent.com/PudamyaYamini?s=100" width="100" alt="Pudamya Yamini" />
			</a>
			<br/><b>Pudamya Yamini</b>
			<br/><sub>UI/UX & Flutter Specialist</sub>
			<br/>
			<a href="https://github.com/PudamyaYamini" title="GitHub: PudamyaYamini">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/github.svg" width="18" alt="GitHub" />
			</a>
			&nbsp;
			<a href="http://www.linkedin.com/in/pudamya-de-silva-1a2ab7320" title="LinkedIn: Pudamya de Silva">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/linkedin.svg" width="18" alt="LinkedIn" />
			</a>
		</td>
	</tr>
	<tr>
		<td align="center" width="180">
			<a href="https://github.com/KaushalSenevirathne" title="Kaushal Senevirathne">
				<img src="https://avatars.githubusercontent.com/KaushalSenevirathne?s=100" width="100" alt="Kaushal Senevirathne" />
			</a>
			<br/><b>Kaushal Senevirathne</b>
			<br/><sub>Frontend Developer</sub>
			<br/>
			<a href="https://github.com/KaushalSenevirathne" title="GitHub: KaushalSenevirathne">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/github.svg" width="18" alt="GitHub" />
			</a>
		</td>
		<td align="center" width="180">
			<a href="https://github.com/Sedani25" title="Sedani Lesara">
				<img src="https://avatars.githubusercontent.com/Sedani25?s=100" width="100" alt="Sedani Lesara" />
			</a>
			<br/><b>Sedani Lesara</b>
			<br/><sub>UI/UX & QA</sub>
			<br/>
			<a href="https://github.com/Sedani25" title="GitHub: Sedani25">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/github.svg" width="18" alt="GitHub" />
			</a>
			&nbsp;
			<a href="http://www.linkedin.com/in/sedani-lesara-sethumlee-956998395" title="LinkedIn: Sedani Lesara">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/linkedin.svg" width="18" alt="LinkedIn" />
			</a>
		</td>
		<td align="center" width="180">
			<a href="https://github.com/hitheshik" title="Hitheshi Kariyawasam">
				<img src="https://avatars.githubusercontent.com/hitheshik?s=100" width="100" alt="Hitheshi Kariyawasam" />
			</a>
			<br/><b>Hitheshi Kariyawasam</b>
			<br/><sub>UI/UX & Product Design</sub>
			<br/>
			<a href="https://github.com/hitheshik" title="GitHub: hitheshik">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/github.svg" width="18" alt="GitHub" />
			</a>
			&nbsp;
			<a href="https://www.linkedin.com/in/hitheshi-kariyawasam-719600378/" title="LinkedIn: Hitheshi Kariyawasam">
				<img src="https://cdn.jsdelivr.net/npm/simple-icons@v11/icons/linkedin.svg" width="18" alt="LinkedIn" />
			</a>
		</td>
	</tr>
</table>

</div>

---

## 📞 Contact & Support

- **Documentation**: [docs/README.md](docs/README.md)
- **Issues**: [GitHub Issues](https://github.com/maporiasl/gemified-travel-portfolio/issues)
- **Discussions**: [GitHub Discussions](https://github.com/maporiasl/gemified-travel-portfolio/discussions)
- **Email**: [info@maporiasl.com](mailto:info@maporiasl.com)

---

## 🙏 Acknowledgments

- GeoJSON data from [geoBoundaries](https://www.geoboundaries.org/)
- Sri Lanka administrative boundaries from GADM
- Mapbox for mapping services
- Firebase for backend services
- The Flutter and Node.js communities

---

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/maporiasl/MaporaSL_Mobile)
![GitHub forks](https://img.shields.io/github/forks/maporiasl/MaporaSL_Mobile)
![GitHub issues](https://img.shields.io/github/issues/maporiasl/MaporaSL_Mobile)
![GitHub license](https://img.shields.io/github/license/maporiasl/MaporaSL_Mobile)

---

**Last Updated**: January 27, 2026  
**Version**: 0.4.0  
**Status**: 🚀 Active Development - Phase 4 (Places System & Gamification)
