# Mzansi Meds Reminder

A cross-platform Flutter application designed to improve medication adherence tracking for patients and healthcare workers in Southern Africa. The app supports multi-language interfaces (English, Zulu, Xhosa) and works offline with automatic data synchronization.

## Features

### Patient Features (✅ Implemented)
- **Home Dashboard** — View upcoming medications and adherence status
- **Medication Tracking** — Log medication intake with detailed dose information
- **Adherence Calendar** — Visual calendar view of medication adherence history
- **Risk Assessment** — Real-time risk level monitoring with visual indicators
- **Language Support** — Choose between English, Zulu, or Xhosa interfaces

### Healthcare Worker Features (✅ Implemented)
- **Worker Dashboard** — Overview of clinic statistics and patient metrics
- **Patient List** — Browse clinic patients with risk indicators
- **Risk Overview** — Monitor patient risk levels with visual charts

### Additional Features (🔄 In Development)
- **Medication Reminders** — Notifications for scheduled medications (with SMS fallback)
- **Offline Support** — Full functionality without internet connectivity
- **Data Sync** — Automatic sync when connectivity is restored
- **Patient Management** — Register and manage patient information
- **Follow-up Scheduling** — Schedule patient follow-ups
- **Adherence Reports** — Export adherence reports as PDF

### Security Features (🔄 In Development)
- **PIN Authentication** — Secure patient access with PIN setup
- **Encryption** — End-to-end encryption for sensitive data
- **Local Database** — Encrypted SQLite storage
- **Caregiver Linking** — Link caregiver accounts for support

## Screens Implemented

### Authentication Flow
- **Language Screen** — Initial language selection (EN, ZU, XH)
- **Login Screen** — PIN-based login for existing users
- **PIN Setup Screen** — New user PIN configuration
- **Registration Code Screen** — Code verification for new accounts

### Patient Interface
- **Home Screen** — Dashboard showing upcoming medications
- **Medication Detail Screen** — Detailed view of specific medications
- **Adherence Calendar** — Month-view calendar of adherence history
- **Risk Level Screen** — Visual risk assessment display

### Healthcare Worker Interface
- **Dashboard Screen** — Clinic overview with statistics and charts
- **Patient List Screen** — Browsable list of clinic patients
- **Risk Overview Card** — Quick-view risk indicators
- **Clinic Stats Chart** — Visual representation of clinic metrics

### Account Management
- **Caregiver Link Screen** — Link secondary caregiver accounts

## Tech Stack

- **Framework** — Flutter 3.9.2+
- **State Management** — Provider (with multi-language support)
- **Database** — SQLite with drift ORM
- **Routing** — GoRouter
- **Networking** — HTTP client with offline-first architecture
- **Notifications** — Local notifications with timezone support
- **Localization** — intl (English, Zulu, Xhosa)
- **Export** — PDF generation

## Project Structure

```
lib/
├── app/                          # App configuration
│   ├── app.dart                 # Main app widget
│   ├── router.dart              # Navigation routes
│   └── theme.dart               # App theming
├── core/                         # Core services
│   ├── database/                # SQLite database, DAOs, tables
│   ├── network/                 # API client, connectivity
│   ├── notifications/           # Local notifications, timezone
│   ├── security/                # Authentication, encryption
│   ├── sync/                    # Data synchronization
│   ├── sms/                     # SMS fallback service
│   └── utils/                   # Constants, helpers
├── features/                     # Feature modules (domain-driven)
│   ├── auth/                    # Login, registration, PIN setup
│   ├── patient/                 # Patient home, medication, calendar
│   ├── dashboard/               # Worker dashboard, stats
│   ├── patient_management/      # Register, schedule, follow-up
│   ├── caregiver/               # Caregiver linking
│   ├── reminders/               # Reminder settings
│   ├── reports/                 # Adherence reports
│   └── risk_assessment/         # Risk calculation engine
├── generated/                    # Auto-generated localization files
└── main.dart                     # Entry point
```

## Getting Started

### Prerequisites
- Flutter 3.9.2 or higher
- Dart 3.9.2 or higher
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

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Specific Platforms

**iOS:**
```bash
flutter build ios
```

**Android:**
```bash
flutter build apk
```

**Web:**
```bash
flutter build web
```

**macOS:**
```bash
flutter build macos
```

**Windows:**
```bash
flutter build windows
```

**Linux:**
```bash
flutter build linux
```

## Key Modules

### Authentication (`features/auth/`)
- Language selection
- PIN-based authentication
- Registration code verification
- Login flow

### Patient Module (`features/patient/`)
- Home dashboard with upcoming medications
- Medication details and scheduling
- Adherence calendar with historical data
- Risk level visualization
- Dose tracking widgets

### Dashboard (`features/dashboard/`)
- Clinic-wide statistics and charts
- Patient list with risk indicators
- Risk overview cards
- Bottom navigation for multi-screen navigation

### Data Management
- **Patients DAO** — Patient records and profiles
- **Medications DAO** — Medication inventory
- **Reminders DAO** — Reminder scheduling
- **Adherence Logs DAO** — Dose tracking history

### Sync Engine (`core/sync/`)
- Offline-first architecture
- Automatic conflict resolution
- Data consistency maintenance

## Database Schema

### Tables
- **patients** — Patient profiles, demographics
- **medications** — Available medications
- **reminders** — Medication reminders and schedules
- **adherence_logs** — Dose intake records

## Localization

Supported languages:
- English
- Zulu (zu)
- Xhosa (xh)

Add new languages by updating `l10n.yaml` and adding message files.

## API Integration

The app communicates with a backend API for:
- User authentication
- Clinic data synchronization
- Patient records
- Reports submission

See `core/network/api_client.dart` for endpoint configuration.

## Notifications

- **Local Notifications** — Device-based medication reminders
- **SMS Fallback** — SMS reminders for offline patients
- **Timezone Support** — Correct scheduling across timezones

## Development

### Code Standards
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions focused and testable

### Testing
```bash
flutter test
```

### Linting
```bash
flutter analyze
```

## Troubleshooting

**Dependency issues:**
```bash
flutter clean
flutter pub get
```

**Build cache problems:**
```bash
flutter clean
flutter pub cache clean
flutter pub get
flutter run
```

**iOS specific issues:**
```bash
cd ios
rm -rf Podfile.lock
pod install
cd ..
flutter run
```

## Contributing

1. Create a feature branch
2. Commit changes with clear messages
3. Push and create a pull request
4. Ensure tests pass and code is analyzed

## License

This project is proprietary and confidential.

## Support

For issues and questions, contact the development team.

## Implementation Status

### ✅ Completed Features
- **Authentication Flow** — Language selection, login, PIN setup, registration code verification
- **Patient Dashboard** — Home screen with upcoming medications
- **Medication Tracking** — Medication details screen with dose information
- **Adherence Calendar** — Full calendar view showing adherence history
- **Risk Assessment** — Risk level visualization and calculation
- **Healthcare Worker Dashboard** — Clinic stats, patient list, risk overview cards
- **Caregiver Linking** — Caregiver link screen for account management
- **UI Components** — Bottom navigation, app bar, continue button, PIN input, badges

### 🔄 In Progress
- Dashboard patient list refinements
- Patient management (register, schedule, follow-up)
- Reminder settings and notifications
- Reports and PDF export
- Offline sync engine

### 📋 Planned
- SMS fallback notifications
- Advanced risk engine
- Report analytics
- Performance optimizations

## Changelog

### v1.0.0 (Current Development)
- ✅ Authentication system with multi-language support
- ✅ Patient medication tracking interface
- ✅ Adherence calendar view
- ✅ Healthcare worker dashboard with statistics
- ✅ Risk assessment visualization
- ✅ Caregiver account linking
- ✅ Bottom navigation and app scaffolding
- 🔄 Offline support with sync (in progress)
- 🔄 Patient management workflows (in progress)
