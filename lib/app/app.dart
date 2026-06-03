import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../providers/session_provider.dart';
import 'router.dart';
import 'theme.dart';

class MedAdhereApp extends StatefulWidget {
  const MedAdhereApp({super.key});

  @override
  State<MedAdhereApp> createState() => _MedAdhereAppState();
}

class _MedAdhereAppState extends State<MedAdhereApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: AppRouter.routes,
      redirect: AppRouter.redirect,
      // Re-evaluate redirect whenever SessionProvider changes.
      refreshListenable: RouterRefresh(context.read<SessionProvider>()),
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      title: 'MedAdhere',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('zu'),
        Locale('xh'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('en');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) return supported;
        }
        return const Locale('en');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Bridges a ChangeNotifier to GoRouter's Listenable interface so the router
/// re-evaluates its redirect whenever SessionProvider notifies.
class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Listenable listenable) {
    listenable.addListener(notifyListeners);
  }
}
