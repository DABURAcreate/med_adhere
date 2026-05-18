import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mzansi_meds_reminder/providers/locale_provider.dart';

import 'package:provider/provider.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for patient-facing screens
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // TODO: Initialize dependencies here later
  // - await Firebase.initializeApp();
  // - await AppDatabase.instance.open();
  // - await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MedAdhereApp(),
    ),
  );
}