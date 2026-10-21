# Release Notes: Driver License Quiz (dlquiz)

## Version 1.0.0 (Build 1.0.0+1) — Initial Official Release
**Release Date:** October 2026  
**Application ID:** `app.kiddos.dlquiz` (`scooter_driver_license_quiz`)  
**Target Platforms:** Android, Linux, Windows, macOS, Web, iOS  

---

### Executive Summary

We are pleased to announce the initial official release (**v1.0.0**) of **Driver License Quiz (`dlquiz`)**, an all-in-one exam simulation and practice application for Taiwan's official Driver's License Written Exam (中華民國交通部公路局筆試題庫).

Originally conceived as a web prototype, this version represents a complete ground-up rewrite using Flutter and Material 3, delivering a fast, responsive, and cross-platform experience across mobile, tablet, desktop, and web.

---

### Key Highlights & Features

#### 1. Official Taiwan Highway Bureau Question Banks
- **Comprehensive Coverage**: Includes the complete, official written test question repository extracted directly from official Directorate General of Highways (交通部公路局) resources:
  - **Motorcycle (機車)**: 806 questions (Traditional Chinese & English).
  - **Car (汽車)**: 1,090 questions (Traditional Chinese & English).
- **Multiple Question Formats**:
  - **Yes/No (True/False)**: Interactive O / X selection.
  - **Multiple Choice**: Standard 3-choice format with complete option explanations.
- **Rich Diagram Assets**: Fully bundled vector and high-resolution diagrams for situational tests, regulatory signs, warning signs, and road markings.

#### 2. Realistic Exam Simulation
- **Dynamic 20-Question Generator**: Automatically generates 20 randomized questions per session divided into two 10-question sections (Section 1: Questions 1–10, Section 2: Questions 11–20).
- **Completion Validation**: Prevents premature submission with clear dialog feedback indicating any unanswered questions.
- **Instant Scoring & Assessment**:
  - Passing threshold set to standard exam criteria ($\ge 80\%$, at least 16 / 20 correct answers).
  - Immediate visual feedback on individual questions highlighting correct answers upon submission.

#### 3. Persistent Mistake Notebook ("錯題本")
- **Automated Logging**: Automatically tracks and stores every question answered incorrectly during exam simulations.
- **Cross-Platform SQLite Storage**:
  - Leverages [`sqflite`](https://pub.dev/packages/sqflite) on mobile platforms and [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi) on desktop environments.
  - Features upsert conflict handling (`UNIQUE(vehicle, lang, num)`) to avoid duplicate records while preserving the user's latest mistake.
- **Review Page**:
  - Dedicated review screen displaying question text, vehicle type, database index, your recorded mistake, and the correct answer.
  - One-tap database clearing option to reset review progress once mistakes are mastered.

#### 4. Bilingual Support & Localization (i18n)
- **Dual Language Interface**: Full bilingual support for **Traditional Chinese (`zh`)** and **English (`en`)**.
- **Dynamic Switching**: Instantly toggle languages from the app bar without restarting or losing session state.
- **Native Localization Architecture**: Built using Flutter ARB translation files (`flutter_localizations` & `intl`).

#### 5. Modern UI, UX & Accessibility
- **Material 3 Design**: Features sleek typography, elevated cards, and dynamic gradient visual styling:
  - Vibrant **Orange Theme** for Motorcycle quizzes.
  - Cool **Blue Theme** for Car quizzes.
- **Responsive Layout**: Fluid single-column centered layout adapting seamlessly across phones, foldable devices, tablets, and large desktop screens.
- **Keyboard Shortcuts**: Desktop and Web users can press `Enter` or `Numpad Enter` on the landing page to quickly launch into a quiz session.
- **AdBanner Integration**: Pre-integrated localized banner widget at the bottom of key screens ready for non-intrusive sponsorships or ad networks.

#### 6. Google Play Store Readiness
- **Production Package Identity**: Standardized package namespace to `app.kiddos.dlquiz`.
- **Branded Store Assets**:
  - Custom high-resolution launcher and adaptive icons (`ic_launcher`).
  - Google Play Store 512×512 store icon and 1024×500 feature graphics.
  - Complete phone and tablet screenshot collection showcasing quiz modes, mistake review, and language switching.

---

### Technical & Architectural Specifications

| Component | Specification |
| :--- | :--- |
| **Framework** | Flutter (Dart SDK `^3.11.0`, Material 3) |
| **App ID / Namespace** | `app.kiddos.dlquiz` |
| **Storage Engine** | SQLite via `sqflite` (Android/iOS) and `sqflite_common_ffi` (Linux/macOS/Windows) |
| **Internationalization** | Flutter l10n (`app_en.arb`, `app_zh.arb`) |
| **Question Extraction** | Python 3 (`fitz` / `pymupdf`, `pdfplumber`) pipeline in `scripts/extract_questions_v2.py` |
| **Dataset Verification** | Python test suite (`test/test_extracted_questions.py`) validating all 3,792 questions across both vehicle types and languages |

---

### Repository Changes & Git History

- `47bf06a` chore: add screenshots
- `6bf3c9d` chore: update app icons
- `0e2aad6` chore: update app title
- `283b0f1` chore: add feature graphics
- `b18ef00` update selection page
- `352724b` add google play assets
- `54bbf8a` update android icons
- `dc7c426` Change package name to app.kiddos.dlquiz (#9)
- `eb182ae` Add localized AdBanner widget at bottom of app pages (#8)
- `f79a183` upgrade flutter packages
- `23eac23` remove synthetic-package
- `bba01a9` upgrade kotlin version
- `34eba73` Add SelectionPage, QuizPage wrong question persistence, and ReviewPage (#7)
- `450c027` Add i18n support for English and Traditional Chinese (#6)
- `eacae1a` Update question source to v2 questions.json for car and motorcycle (zh/en) (#5)
- `c854232` Extract all driver license question versions (car/motorcycle, zh/en) (#4)
- `7c0868b` Extract questions and images from THB PDF into questions/v2 (#2)
- `f5b5d1c` Rewrite Driver License Quiz web application into Flutter Android app

---

### Getting Started & Installation

#### Android (Release Build)
```bash
# Build Android App Bundle (AAB) for Google Play Store:
flutter build appbundle --release

# Build standalone APK for testing:
flutter build apk --release
```

#### Desktop & Web
```bash
# Run locally on Linux desktop:
flutter run -d linux

# Run locally in Google Chrome:
flutter run -d chrome
```

#### Running Quality Assurance Tests
```bash
# Verify question bank integrity and image paths:
python3 test/test_extracted_questions.py

# Run Flutter widget and unit test suites:
flutter test
```
