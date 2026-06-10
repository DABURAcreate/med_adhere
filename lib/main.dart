import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/network/connectivity_service.dart';
import 'core/security/auth_service.dart';
import 'core/sync/sync_service.dart';
import 'core/utils/constants.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/patient/data/adherence_repository.dart';
import 'features/patient/data/patient_repository.dart';
import 'features/patient_management/data/patient_mgmt_repository.dart';
import 'features/reports/data/report_repository.dart';
import 'features/risk_assessment/domain/risk_engine.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'providers/session_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (kFirebaseConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final db = AppDatabase();
  final connectivity = ConnectivityService();
  final riskEngine = RiskEngine(
    logsDao: db.adherenceLogsDao,
    patientsDao: db.patientsDao,
  );
  final syncService = SyncService(db: db);

  final patientRepo = PatientRepository(db: db);
  final adherenceRepo = AdherenceRepository(db: db, riskEngine: riskEngine);
  final dashboardRepo = DashboardRepository(db: db);
  final authRepo = AuthRepository(db: db, connectivity: connectivity);
  final patientMgmtRepo = PatientMgmtRepository(db: db);
  final reportRepo = ReportRepository(db: db);

  // Restore previous session if one was saved on disk.
  final session = SessionProvider();
  final savedSession = await AuthService.loadSession();
  if (savedSession != null) {
    if (savedSession.role == 'patient' && savedSession.patientId != null) {
      final patient =
          await db.patientsDao.getPatientById(savedSession.patientId!);
      if (patient != null) {
        session.signInAsPatient(savedSession.patientId!);
      } else {
        // Local DB was cleared — discard stale session file.
        await AuthService.clearSession();
      }
    } else if (savedSession.role == 'worker' &&
        savedSession.workerId != null) {
      // Workers are stored in Firestore; trust the session file on startup.
      session.signInAsWorker(
        savedSession.workerId!,
        clinicName: savedSession.workerClinicName,
        fullName: savedSession.workerFullName,
      );
    }
  }

  _listenAndSync(connectivity, syncService);

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<ConnectivityService>.value(value: connectivity),
        Provider<SyncService>.value(value: syncService),
        Provider<RiskEngine>.value(value: riskEngine),
        Provider<PatientRepository>.value(value: patientRepo),
        Provider<AdherenceRepository>.value(value: adherenceRepo),
        Provider<DashboardRepository>.value(value: dashboardRepo),
        Provider<AuthRepository>.value(value: authRepo),
        Provider<PatientMgmtRepository>.value(value: patientMgmtRepo),
        Provider<ReportRepository>.value(value: reportRepo),
        ChangeNotifierProvider.value(value: session),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MedAdhereApp(),
    ),
  );
}

void _listenAndSync(ConnectivityService connectivity, SyncService sync) {
  var wasOffline = false;
  connectivity.onConnectivityChanged.listen((isOnline) {
    if (isOnline && wasOffline) sync.sync();
    wasOffline = !isOnline;
  });
}
