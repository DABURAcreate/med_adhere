# Mzansi Meds Reminder

A cross-platform Flutter application designed to improve medication adherence tracking for patients and healthcare workers in Southern Africa. The app supports multi-language interfaces (English, Zulu, Xhosa) and works offline with automatic Firebase synchronization.

## Features

### Patient Features (✅ Implemented)
- **Home Dashboard** — View upcoming medications and adherence status
- **Medication Tracking** — Log medication intake with detailed dose information
- **Adherence Calendar** — Visual calendar view of medication adherence history
- **Risk Assessment** — Real-time risk level monitoring with visual indicators
- **Reminder Settings** — Customise reminder times and frequency per medication
- **Language Support** — Choose between English, Zulu, or Xhosa interfaces

### Healthcare Worker Features (✅ Implemented)
- **Worker Dashboard** — Overview of clinic statistics and patient metrics
- **Patient List** — Browse clinic patients with risk indicators
- **Risk Overview** — Monitor patient risk levels with visual charts
- **Patient Registration** — Register new patients with medication schedules
- **Patient Detail** — View individual patient adherence history
- **Medication Schedule** — Assign and manage medication schedules
- **Follow-up Scheduling** — Schedule and record patient follow-ups
- **Adherence Reports** — Export per-patient and clinic-wide reports as PDF/CSV

### Security Features (✅ Implemented)
- **PIN Authentication** — SHA-256 hashed PIN setup and login
- **Session Persistence** — Authenticated session survives app restarts
- **Local Database** — SQLite storage via Drift ORM

### In Development (🔄)
- **Offline Sync** — Full offline-first sync with Firestore (service wired, protocol in progress)
- **Push Notifications** — Local medication reminders with timezone support
- **SMS Fallback** — SMS reminders for patients without smartphones
- **Encryption** — End-to-end encryption for data at rest and in transit
- **Caregiver Linking** — Link caregiver accounts for patient support

## Screens Implemented

### Authentication Flow
- **Language Screen** — Initial language selection (EN, ZU, XH)
- **Login Screen** — PIN-based login for existing users
- **PIN Setup Screen** — New user PIN configuration
- **Registration Code Screen** — Activation code verification for new accounts

### Patient Interface
- **Home Screen** — Dashboard showing upcoming medications
- **Medication Detail Screen** — Detailed view of specific medications
- **Adherence Calendar** — Month-view calendar of adherence history
- **Risk Level Screen** — Visual risk assessment display with score and recommendations
- **Reminder Settings Screen** — Per-medication reminder time configuration

### Healthcare Worker Interface
- **Dashboard Screen** — Clinic overview with statistics and charts
- **Patient List Screen** — Browsable list of clinic patients
- **Register Patient Screen** — Form to register a new patient with medications
- **Patient Detail Screen** — Individual patient profile and adherence history
- **Medication Schedule Screen** — View and manage a patient's medication schedule
- **Follow-up Screen** — Schedule and record patient follow-up appointments
- **Reports Screen** — Export adherence reports (per-patient or clinic-wide)

### Account Management
- **Caregiver Link Screen** — Link secondary caregiver accounts

## Tech Stack

- **Framework** — Flutter (Dart SDK ^3.9.2)
- **State Management** — Provider
- **Database** — SQLite with Drift ORM
- **Cloud Sync** — Firebase Firestore
- **Routing** — GoRouter
- **Notifications** — Local notifications with timezone support (stub)
- **Localization** — flutter_localizations + intl (English, Zulu, Xhosa)
- **Export** — PDF generation via `pdf` package, sharing via `share_plus`
- **Security** — `crypto` (SHA-256 PIN hashing)

## Project Structure

```
lib/
├── app/                          # App configuration
│   ├── app.dart                 # Root widget + GoRouter setup
│   ├── router.dart              # All named routes (AppRoutes + AppRouter)
│   └── theme.dart               # Light/dark themes
├── core/                         # Core services
│   ├── database/                # AppDatabase, DAOs, table definitions
│   ├── network/                 # API client, ConnectivityService
│   ├── notifications/           # Local notifications, timezone helper
│   ├── security/                # AuthService (PIN + session), EncryptionService
│   ├── sync/                    # SyncService, ConflictResolver
│   ├── sms/                     # SMS fallback service
│   └── utils/                   # Constants, date utils, report generator
├── features/                     # Feature modules (domain-driven)
│   ├── auth/                    # Login, registration, PIN setup
│   ├── patient/                 # Patient home, medication, calendar, risk
│   ├── dashboard/               # Worker dashboard, patient list, stats
│   ├── patient_management/      # Register, schedule, follow-up, patient detail
│   ├── caregiver/               # Caregiver linking
│   ├── reminders/               # Reminder settings
│   ├── reports/                 # Adherence report export
│   └── risk_assessment/         # Risk calculation engine
├── providers/                    # Global state (SessionProvider, LocaleProvider)
├── generated/                    # Auto-generated localization files
└── main.dart                     # Entry point — DI setup, session restore, sync wiring
```

## Getting Started

### Prerequisites
- Flutter SDK (Dart ^3.9.2 required)
- Xcode 15+ (for iOS)
- Android SDK 21+ (for Android)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd med_adhere
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Drift ORM code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Specific Platforms

```bash
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
flutter build macos     # macOS
flutter build windows   # Windows
flutter build linux     # Linux
```

## Key Modules

### Authentication (`features/auth/`)
- Language selection on first launch
- Activation code verification for new accounts
- PIN setup with SHA-256 hashing stored in the local database
- PIN login with session persistence across restarts

### Patient Module (`features/patient/`)
- Home dashboard with upcoming dose cards
- Medication details and dose logging (`taken`, `missed`, `skipped`, `late`)
- Adherence calendar with historical status view
- Risk level screen with score, reasons, and recommended actions
- Reminder settings with per-medication time pickers

### Dashboard (`features/dashboard/`)
- Clinic-wide statistics and charts
- Patient list with risk-level badges
- Risk overview cards

### Patient Management (`features/patient_management/`)
- Register new patients with demographic info and initial medications
- View and edit medication schedules
- Record and view follow-up appointments

### Reports (`features/reports/`)
- Per-patient and clinic-wide adherence reports
- PDF and CSV export with sharing support

### Data Layer
- **PatientsDao** — Patient records and profiles
- **MedicationsDao** — Medication inventory and schedules
- **RemindersDao** — Reminder configuration per medication
- **AdherenceLogsDao** — Dose intake history with idempotent insert

### Repositories
- `PatientRepository` — patient + medication CRUD
- `AdherenceRepository` — dose logging; re-runs RiskEngine after every status change
- `DashboardRepository` — clinic-wide aggregates
- `PatientMgmtRepository` — registration and schedule management
- `AuthRepository` — activation code validation and PIN persistence
- `CaregiverRepository` — caregiver account linking

### Sync Engine (`core/sync/`)
- `SyncService` — pushes `isSynced=false` rows to Firestore, pulls remote updates
- `ConnectivityService` — triggers a sync whenever the device comes back online
- `ConflictResolver` — last-write-wins; dirty local rows always beat remote versions

## Database Schema

| Table | Purpose |
|---|---|
| `patients` | Patient profiles and demographics |
| `medications` | Medication records and active status |
| `reminders` | Per-medication reminder times |
| `adherence_logs` | Dose intake records with unique constraint `(patientId, medicationId, scheduledAt)` |

Dates are stored as ISO 8601 strings (`yyyy-MM-dd`); timestamps as `DateTime` (Drift handles encoding). Foreign key cascades are enabled — deleting a patient removes all related rows.

## Firebase / Offline Sync

Firebase is active (`kFirebaseConfigured = true` in `lib/core/utils/constants.dart`). To reconfigure for a different Firebase project:
1. Run `dart pub global activate flutterfire_cli && flutterfire configure`
2. Replace `lib/firebase_options.dart` with the newly generated file

## Localization

Supported locales: English (`en`), Zulu (`zu`), Xhosa (`xh`). ARB source files live in `lib/l10n/`. After editing ARBs:
```bash
flutter gen-l10n
```

## Development

### Code Generation
After any change to a Drift table or DAO:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing & Linting
```bash
flutter test
flutter analyze
```

### Troubleshooting

**Clean build:**
```bash
flutter clean && flutter pub get
```

**iOS pod issues:**
```bash
cd ios && rm -rf Podfile.lock && pod install && cd ..
```

## Contributing

1. Create a feature branch
2. Commit changes with clear messages
3. Push and create a pull request
4. Ensure `flutter analyze` passes and tests are green

## License

This project is proprietary and confidential.

## Implementation Status

### ✅ Completed
- Authentication flow — language selection, activation code, PIN setup and login
- Session persistence — authenticated session survives app restarts
- Patient dashboard — home screen with upcoming dose cards
- Medication tracking — detail screen with dose logging
- Adherence calendar — full month-view with status history
- Risk assessment — risk engine with score, thresholds, and recommendations
- Healthcare worker dashboard — clinic stats, patient list, risk overview
- Patient management — register patient, medication schedule, follow-up, patient detail
- Reminder settings — per-medication time picker UI
- Reports — PDF/CSV export screen with per-patient and clinic-wide modes
- Caregiver linking — caregiver link screen
- Firebase integration — Firestore connectivity enabled
- Offline sync wiring — ConnectivityService triggers SyncService on reconnect

### 🔄 In Progress
- SyncService Firestore protocol (push/pull logic)
- Local push notifications (service stub exists)
- Reminder settings database persistence (UI complete, DAO write pending)

### 📋 Planned
- SMS fallback notifications
- End-to-end encryption
- Advanced report analytics
- Performance optimizations

## Changelog

### v1.0.0 (Current Development)
- Authentication system with multi-language support
- Patient medication tracking and dose logging
- Adherence calendar view
- Healthcare worker dashboard with statistics
- Risk assessment engine and visualization
- Patient management (register, schedule, follow-up)
- Reminder settings UI
- Adherence report export (PDF/CSV)
- Caregiver account linking
- Firebase integration enabled
- Session persistence across restarts
- Connectivity-triggered sync
