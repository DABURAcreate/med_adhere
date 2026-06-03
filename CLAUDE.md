# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Generate Drift ORM code (required after any table/DAO change)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Generate localization files (required after editing .arb files)
flutter gen-l10n

# Build for specific platforms
flutter build apk       # Android
flutter build ios       # iOS
flutter build macos     # macOS
flutter build web       # Web
```

**Important:** Whenever you modify a Drift table (`lib/core/database/tables/`) or DAO (`lib/core/database/daos/`), you must re-run `dart run build_runner build --delete-conflicting-outputs` to regenerate the `.g.dart` files. The app will not compile without up-to-date generated files.

## Architecture

### Two user roles, one codebase

The app serves two distinct user types whose routes never overlap:

- **Patients** — `/patient/*` routes. Home screen, medication detail, adherence calendar, risk level, reminder settings.
- **Healthcare Workers** — `/worker/*` routes. Dashboard, patient list, patient detail, medication schedule, follow-up.
- **Shared** — Auth flow (`/`, `/login`, `/pin-setup`, `/registration-code`) and caregiver linking (`/caregiver/link`).

All routes are declared statically in `lib/app/router.dart` as `AppRoutes` constants and assembled in `AppRouter.routes`. Navigation uses `GoRouter` with named routes — always navigate by name to avoid hardcoding path strings.

### Feature modules

`lib/features/` follows a domain-driven layout. Each feature has up to three layers:

- `data/` — repository classes. These are the only things that touch DAOs. Repositories receive `AppDatabase` via constructor injection.
- `domain/` — pure Dart models and business logic (e.g. `risk_engine.dart`).
- `presentation/` — screens.
- `widgets/` — feature-local widgets.

Nothing outside a repository should call a DAO directly.

### Database layer (Drift ORM)

`AppDatabase` in `lib/core/database/app_database.dart` is the single SQLite instance. Schema v1 has four tables: `patients`, `medications`, `reminders`, `adherence_logs`. Foreign key cascades are enabled — deleting a patient removes their medications, reminders, and logs.

Key conventions:
- Dates stored as ISO 8601 strings (`yyyy-MM-dd`) in text columns; timestamps stored as `DateTime` (Drift handles encoding).
- `isSynced: false` marks rows that have not yet been uploaded to the backend. `sync_service.dart` queries these on connectivity restore.
- Prefer `setMedicationActive(false)` over hard-deleting medications to preserve adherence history.
- Dose statuses are plain strings: `'taken'`, `'missed'`, `'skipped'`, `'late'`.
- `AdherenceLogsDao.insertLog` uses `InsertMode.insertOrIgnore` on the unique constraint `(patientId, medicationId, scheduledAt)` to survive sync replays safely.

### State management

`Provider` is used for global state. Currently only `LocaleProvider` (in `lib/providers/locale_provider.dart`) is in the widget tree — it drives the app locale and is injected at the root in `main.dart`. The `AppDatabase` instance is not yet in the Provider tree (the TODO in `main.dart` marks this as pending).

### Localization

Supported locales: English (`en`), Zulu (`zu`), Xhosa (`xh`). ARB source files live in `lib/l10n/`. After editing ARBs, run `flutter gen-l10n` — this regenerates `lib/generated/` and `lib/l10n/app_localizations*.dart`. Use `AppLocalizations.of(context)!` to access strings in widgets.

### Core services (partially implemented)

Several core services exist as stubs or are not yet wired into the app:

- `core/sync/sync_service.dart` — offline sync engine (stub).
- `core/security/auth_service.dart` / `encryption_service.dart` — PIN auth and encryption (stubs).
- `core/notifications/notification_service.dart` — local push notifications with timezone support (stub).
- `core/sms/sms_fallback_service.dart` — SMS reminders for offline patients (stub).
- `core/network/api_client.dart` — backend HTTP client (stub).

The `main.dart` TODOs mark where these should be initialized before `runApp`.

### Firebase + offline sync

Firebase is gated behind `kFirebaseConfigured` in `lib/core/utils/constants.dart` (currently `false`). To enable:
1. Run `dart pub global activate flutterfire_cli && flutterfire configure`
2. Replace `lib/firebase_options.dart` with the generated file
3. Set `kFirebaseConfigured = true` in `constants.dart`

`SyncService` (`lib/core/sync/sync_service.dart`) pushes all rows with `isSynced=false` to Firestore, then pulls documents updated after the last sync timestamp (persisted to `getApplicationDocumentsDirectory()/last_sync.json`). Conflict resolution is last-write-wins via `ConflictResolver` — a dirty local row (unsent) always beats the remote version.

`ConnectivityService` streams connectivity changes; `main.dart` subscribes and calls `SyncService.sync()` each time the device goes from offline → online.

### Risk engine

`RiskEngine` (`lib/features/risk_assessment/domain/risk_engine.dart`) reads `AdherenceLogsDao` directly and writes the result back to `PatientsDao.updateRiskLevel`. Call it after every dose log. Key thresholds (in `constants.dart`):
- **High**: adherence < 50% OR ≥ 4 consecutive missed days
- **Medium**: adherence < 80% OR ≥ 2 consecutive missed days OR last-7-day rate < 60%
- **Low**: otherwise

`RiskResult` (`lib/features/risk_assessment/domain/risk_model.dart`) carries a 0–100 numeric score, adherence rate, streak, and human-readable `reasons`/`recommendation` strings consumed by `RiskLevelScreen`.

### Session state

`SessionProvider` (`lib/providers/session_provider.dart`) holds the current patient ID and role. Set via `signInAsPatient(id)` from the auth flow. Screens read `context.watch<SessionProvider>().currentPatientId` to scope queries.

### Repository layer

Three repositories wrap the DAOs for screens:
- `PatientRepository` — patient + medication CRUD
- `AdherenceRepository` — dose logging; always re-runs `RiskEngine.calculate()` after a status change and returns the updated `RiskResult`
- `DashboardRepository` — clinic-wide aggregates for the worker dashboard

### PDF reports

`lib/core/utils/report_generator.dart` and `lib/features/reports/` handle PDF generation using the `pdf` package and sharing via `share_plus`.
