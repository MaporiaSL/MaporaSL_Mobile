# MAPORIA — Contribution Guide

## 1. Team Philosophy
We work with **clarity, respect, and curiosity**.
Every member should understand both *why* and *how* each part of MAPORIA exists.

> “We explore together — both the world and our code.”

---

## 2. Communication
| Platform | Purpose |
|---|---|
| **ChatGPT Project Folder** | Central knowledge hub & planning reference |
| **GitHub Issues** | Task management, feature requests, bugs |
| **Docsify (/docs)** | Living documentation (source of truth) |
| **Google Drive** | Shared assets (designs, media, presentations) |
| **Group Chat (Discord/WhatsApp)** | Quick syncs, informal communication |

---

## 3. Branching Strategy
- **Main:** Stable, production-ready.
- **Dev:** Latest working integration.
- **Feature branches:** `feature/<short-description>` (e.g., `feature/gps-tracking`)
- **Fix branches:** `fix/<short-description>` (e.g., `fix/map-overlay-lag`)

**Merge Rules**
- Every PR must be reviewed by at least one other member.
- No direct commits to `main` or `dev`. All work must come from a feature/fix branch.

---

## 4. Commit Message Convention
We follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard. This helps keep the commit history clean and enables automatic changelog generation.

**Format:**
`<type>[optional scope]: <description>`

**Common Types:**
-   `feat`: A new feature (e.g., `feat: add photo geotagging`)
-   `fix`: A bug fix (e.g., `fix: correct map overlay lag`)
-   `docs`: Documentation only changes (e.g., `docs: update contribution guide`)
-   `style`: Code style changes (e.g., `style: format with dart format`)
-   `refactor`: Code change that neither fixes a bug nor adds a feature
-   `test`: Adding missing tests
-   `chore`: Changes to the build process or auxiliary tools

**Example:**
`feat(profile): add badge grid to user dashboard`