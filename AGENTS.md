# AGENTS.md

Welcome to the **Driver License Quiz (`dlquiz`)** repository! This document provides essential architectural context, project conventions, and operational workflows for AI agents and human contributors working within this codebase.

---

## 1. Project Overview

- **Name / Package**: `scooter_driver_license_quiz` (Application ID: `app.kiddos.dlquiz`)
- **Purpose**: A cross-platform exam simulation and practice application for Taiwan's official Driver's License Written Exam (中華民國交通部公路局筆試題庫).
- **Supported Vehicles**: Motorcycle (機車 - 806 questions) and Car (汽車 - 1,090 questions).
- **Supported Languages**: Traditional Chinese (`zh`) and English (`en`).
- **Target Platforms**: Android, iOS, Linux, macOS, Windows, and Web (Flutter Multiplatform).
- **Key Features**:
  - Timed / structured quiz simulation (20 randomized questions: 10 per section).
  - Dynamic question support (Yes/No questions and 3-choice Multiple Choice questions, with or without diagram assets).
  - Persistent SQLite notebook for reviewing incorrect answers ("錯題本").
  - Bilingual interface with automatic and manual locale switching.
  - Official PDF question bank extraction pipeline in Python.

---

## 2. Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.11.0`, Material 3 design).
- **State Management**: Reactive `StatefulWidget` architectures with model state controllers (`QuizState`).
- **Database / Storage**:
  - [`sqflite`](https://pub.dev/packages/sqflite) (Mobile: Android / iOS)
  - [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi) (Desktop: Linux / Windows / macOS)
- **Internationalization**: Flutter's native localization tooling (`flutter_localizations`, ARB files via `l10n.yaml`).
- **Dataset Pipeline**: Python 3 (`pymupdf` / `fitz`, `pdfplumber`).

---

## 3. Directory Layout & Architecture

```text
dlquiz/
├── analysis_options.yaml       # Dart analyzer and linting rules (flutter_lints)
├── android/                    # Android host project (app.kiddos.dlquiz)
├── google-play-assets/         # Store icons & feature graphics
├── l10n.yaml                   # Flutter localization config pointing to lib/l10n/
├── lib/
│   ├── l10n/                   # Translation ARB definitions & generated files
│   │   ├── app_en.arb          # English translation keys & strings
│   │   ├── app_zh.arb          # Traditional Chinese translation keys & strings
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_en.dart
│   │   └── app_localizations_zh.dart
│   ├── main.dart               # Entry point: DriverLicenseQuizApp, Theme, Locale provider
│   ├── models/
│   │   ├── question.dart       # Question model, JSON & DB serialization, QuestionType enum
│   │   ├── quiz_state.dart     # Quiz session state: 20-question generator, scoring, validation
│   │   └── wrong_question_record.dart # Model for stored mistakes in SQLite
│   ├── pages/
│   │   ├── selection_page.dart # Landing screen: vehicle/language selector, shortcut keys
│   │   ├── quiz_page.dart      # Quiz taker screen: radio selection, scoring & DB persistence
│   │   └── review_page.dart    # Review screen: list incorrect questions, clear records
│   ├── utils/
│   │   ├── database_helper.dart# SQLite singleton helper (wrong_questions table)
│   │   └── question_parser.dart# JSON dataset parser and legacy text parser
│   └── widgets/
│       └── ad_banner.dart      # Reusable bottom ad banner widget (localized)
├── pubspec.yaml                # Dependencies, asset registrations, metadata
├── questions/
│   └── v2/                     # Extracted question banks and image assets
│       ├── car/
│       │   ├── en/             # English Car questions.json, questions.txt, images/
│       │   └── zh/             # Chinese Car questions.json, questions.txt, images/
│       └── motorcycle/
│           ├── en/             # English Motorcycle questions.json, questions.txt, images/
│           └── zh/             # Chinese Motorcycle questions.json, questions.txt, images/
├── requirements.txt            # Python dependencies for PDF extraction
├── scripts/
│   └── extract_questions_v2.py # Automated downloader & PDF parser for Taiwan Highway Bureau questions
└── test/
    ├── ad_banner_test.dart     # Tests for AdBanner widget and page integrations
    ├── database_test.dart      # Unit tests for SQLite operations via DatabaseHelper
    ├── quiz_test.dart          # Unit tests for QuestionParser and QuizState
    ├── selection_page_test.dart# Widget tests for SelectionPage interactions & shortcuts
    ├── test_extracted_questions.py # Python validation for question counts, schema, and images
    └── widget_test.dart        # End-to-end widget flow tests (Selection -> Quiz -> Review)
```

---

## 4. Key Models & Core Logic

### `Question` (`lib/models/question.dart`)
- Represents an individual quiz question.
- Supports two formats:
  - `QuestionType.yesNo`: Answers are `'O'` or `'X'`.
  - `QuestionType.multipleChoice`: Answers are `'1'`, `'2'`, or `'3'`, with an `options` map (`{'1': '...', '2': '...', '3': '...'}`).
- May contain one or more relative image paths (`images`) pointing to bundled asset files.
- Provides `toDbMap` and `fromDbMap` for database persistence.

### `QuizState` (`lib/models/quiz_state.dart`)
- Generated using `QuizState.generateFromQuestions(questions)`.
- Selects 20 randomized questions:
  - **Section 1**: 10 questions (index 1 to 10).
  - **Section 2**: 10 questions (index 11 to 20).
- Tracks user answers in `section1UserAnswers` and `section2UserAnswers`.
- Validates all questions are answered before submission (`submitAnswers(l10n)`).
- Passing criteria: $\ge 80\%$ (at least 16 / 20 correct).

### `DatabaseHelper` (`lib/utils/database_helper.dart`)
- Manages local SQLite storage for incorrect answers in table `wrong_questions`.
- Initialized automatically for desktop via `sqfliteFfiInit()` and `databaseFactoryFfi`.
- Supports setting a custom `Database` instance (`setDatabase(db)`), essential for fast in-memory unit/widget testing.
- Uses `ConflictAlgorithm.replace` on `UNIQUE(vehicle, lang, num)` to prevent duplicates.

---

## 5. Development Workflows & Common Commands

### Prerequisites
- Flutter SDK (>= 3.11.0) and Dart
- Python 3.12+ (for data extraction & dataset verification)

### Running the App
```bash
# Run on connected device or default desktop target
flutter run

# Run on specific target
flutter run -d linux
flutter run -d chrome
flutter run -d <android-device-id>
```

### Static Analysis & Formatting
```bash
# Analyze Dart source code
flutter analyze

# Format Dart source files
dart format lib/ test/
```

### Running Tests
```bash
# Run pure Dart unit tests (QuizState & QuestionParser)
flutter test test/quiz_test.dart

# Run all Flutter widget & unit tests
flutter test

# Run Python dataset integrity tests
python3 test/test_extracted_questions.py
```

### Localization Management
When adding or updating UI strings:
1. Update `lib/l10n/app_en.arb` (English template).
2. Update `lib/l10n/app_zh.arb` (Traditional Chinese).
3. Generate localization classes:
   ```bash
   flutter gen-l10n
   ```
4. Access strings in widgets via `AppLocalizations.of(context)?.<key>`.

### Question Dataset Extraction
To re-extract or update questions from official Taiwan Directorate General of Highways (公路局) PDFs:
```bash
# Install Python extraction dependencies
pip install -r requirements.txt

# Run the extraction script
python3 scripts/extract_questions_v2.py

# Verify extracted datasets
python3 test/test_extracted_questions.py
```

---

## 6. Guidelines & Best Practices for Agents

1. **Localization Consistency**:
   - Never hardcode Chinese or English user-facing text in widgets or dialogs.
   - Always define matching keys in both `app_en.arb` and `app_zh.arb`.
   - Provide placeholders in `.arb` files for dynamic values (e.g. `{count}`, `{answer}`).

2. **Database Testing & Desktop Compatibility**:
   - `sqflite` requires `sqflite_common_ffi` on desktop and in test runner environments.
   - When writing tests that interact with `DatabaseHelper`, always initialize `sqfliteFfiInit()` and provide an in-memory database using `DatabaseHelper.instance.setDatabase(db)` in `setUp()`. Close it in `tearDown()`.

3. **Question Bank Integrity**:
   - Never manually alter question numbering or answer values in `questions/v2/` without running `python3 test/test_extracted_questions.py`.
   - All question images must exist in the corresponding `images/` directory and be registered under `assets:` in `pubspec.yaml`.

4. **UI & Keyboard Navigation**:
   - `SelectionPage` supports keyboard accessibility (hitting `Enter` triggers quiz start). Maintain keyboard focus node listeners when modifying entry page navigation.
   - Preserve `AdBanner` at the bottom of main scaffold pages (`SelectionPage`, `QuizPage`, `ReviewPage`).

5. **Linting & Code Quality**:
   - Adhere to `analysis_options.yaml`.
   - Avoid using deprecated Flutter APIs (e.g., use modern radio grouping constructs and avoid deprecated properties).
