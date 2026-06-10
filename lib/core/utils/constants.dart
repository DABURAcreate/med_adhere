// Set to true after running `flutterfire configure` and replacing firebase_options.dart.
// While false the app runs in offline-only mode — no Firestore reads or writes.
const bool kFirebaseConfigured = true;

// Dose status strings — match the AdherenceLogs table constraint (min:4, max:7).
const String kStatusTaken = 'taken';
const String kStatusMissed = 'missed';
const String kStatusSkipped = 'skipped';
const String kStatusLate = 'late';

// Risk level strings — stored in the patients table.
const String kRiskLow = 'low';
const String kRiskMedium = 'medium';
const String kRiskHigh = 'high';

// Risk engine parameters.
const int kRiskWindowDays = 30;
const int kRiskRecentWindowDays = 7;
const double kRiskHighThreshold = 0.50;
const double kRiskMediumThreshold = 0.80;
const int kConsecutiveMissesHighOverride = 4;
const int kConsecutiveMissesMediumOverride = 2;

// Firestore collection names.
const String kColPatients = 'patients';
const String kColMedications = 'medications';
const String kColReminders = 'reminders';
const String kColAdherenceLogs = 'adherence_logs';
// Stores one document per activation code (doc ID = code) for O(1) patient lookup.
const String kColActivationCodes = 'activation_codes';
// Stores healthcare worker accounts (doc ID = Firestore auto-ID).
const String kColWorkers = 'workers';
