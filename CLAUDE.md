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
- **Healthcare Workers** — `/worker/*` routes. Dashboard, patient list, patient detail, medication schedule, follow-up, reports.
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

`Provider` is the state management solution. All global objects are injected in `main.dart` via `MultiProvider` before `runApp`. The full Provider tree includes:

- `AppDatabase` — single SQLite instance
- `ConnectivityService` — network connectivity stream
- `SyncService` — offline sync engine
- `RiskEngine` — risk score calculator
- `PatientRepository` — patient + medication CRUD
- `AdherenceRepository` — dose logging + risk recalculation
- `DashboardRepository` — clinic-wide aggregates
- `AuthRepository` — activation code validation and PIN persistence
- `PatientMgmtRepository` — patient registration and schedule management
- `SessionProvider` (ChangeNotifier) — current patient ID and role
- `LocaleProvider` (ChangeNotifier) — app locale (drives language switching)

Screens access these via `context.read<T>()` (one-off reads) or `context.watch<T>()` (rebuilds on change).

### Localization

Supported locales: English (`en`), Zulu (`zu`), Xhosa (`xh`). ARB source files live in `lib/l10n/`. After editing ARBs, run `flutter gen-l10n` — this regenerates `lib/generated/` and `lib/l10n/app_localizations*.dart`. Use `AppLocalizations.of(context)!` to access strings in widgets.

### Core services

- `core/security/auth_service.dart` — **implemented**. PIN hashing (SHA-256), `saveSession` / `loadSession` / `clearSession` using a JSON file in the app documents directory.
- `core/network/connectivity_service.dart` — **implemented**. Streams connectivity changes via `connectivity_plus`. `main.dart` listens and calls `SyncService.sync()` each time the device goes from offline → online.
- `core/sync/sync_service.dart` — partially implemented. Push/pull protocol with Firestore is in progress; wired in `main.dart`.
- `core/notifications/notification_service.dart` — stub. Timezone helper exists; notification scheduling not yet wired.
- `core/sms/sms_fallback_service.dart` — stub.
- `core/network/api_client.dart` — stub.
- `core/security/encryption_service.dart` — stub.

### Session state

`SessionProvider` (`lib/providers/session_provider.dart`) holds the current patient ID and role. At startup, `main.dart` calls `AuthService.loadSession()` to restore a persisted session from disk, validating that the patient still exists in the local DB before restoring. Screens read `context.watch<SessionProvider>().currentPatientId` to scope queries.

On login, call `AuthService.saveSession(patientId)` to persist the session. On logout, call `AuthService.clearSession()` and reset the `SessionProvider`.

### Firebase + offline sync

Firebase is enabled — `kFirebaseConfigured = true` in `lib/core/utils/constants.dart`. `firebase_options.dart` contains the active configuration.

To reconfigure for a different Firebase project:
1. Run `dart pub global activate flutterfire_cli && flutterfire configure`
2. Replace `lib/firebase_options.dart` with the generated file

`SyncService` pushes all rows with `isSynced=false` to Firestore, then pulls documents updated after the last sync timestamp (persisted to `getApplicationDocumentsDirectory()/last_sync.json`). Conflict resolution is last-write-wins via `ConflictResolver` — a dirty local row (unsent) always beats the remote version.

### Risk engine

`RiskEngine` (`lib/features/risk_assessment/domain/risk_engine.dart`) reads `AdherenceLogsDao` directly and writes the result back to `PatientsDao.updateRiskLevel`. Call it after every dose log. Key thresholds (in `constants.dart`):
- **High**: adherence < 50% OR ≥ 4 consecutive missed days
- **Medium**: adherence < 80% OR ≥ 2 consecutive missed days OR last-7-day rate < 60%
- **Low**: otherwise

`RiskResult` (`lib/features/risk_assessment/domain/risk_model.dart`) carries a 0–100 numeric score, adherence rate, streak, and human-readable `reasons`/`recommendation` strings consumed by `RiskLevelScreen`.

### Repository layer

Repositories wrap the DAOs and are the only layer screens should call:
- `PatientRepository` — patient + medication CRUD
- `AdherenceRepository` — dose logging; always re-runs `RiskEngine.calculate()` after a status change and returns the updated `RiskResult`
- `DashboardRepository` — clinic-wide aggregates for the worker dashboard
- `PatientMgmtRepository` — patient registration, medication schedule management
- `AuthRepository` — activation code lookup and PIN storage
- `CaregiverRepository` — caregiver account linking

### PDF reports

`lib/core/utils/report_generator.dart` and `lib/features/reports/` handle PDF generation using the `pdf` package and sharing via `share_plus`. The report screen supports both per-patient and clinic-wide modes, and exports in PDF or CSV format.
