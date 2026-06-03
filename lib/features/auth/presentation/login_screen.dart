import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../providers/session_provider.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';
  bool _loading = false;
  String? _error;

  Future<void> _onContinue() async {
    if (_pin.length < 4 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AuthRepository>().login(_pin);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case AuthSuccess(:final patientId):
        context.read<SessionProvider>().signInAsPatient(patientId);
        context.go('/patient/home');
      case AuthFailure(:final message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const MedAdhereHeader(),
              const SizedBox(height: 56),

              Text(
                l10n.enterYourPin,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 56),

              PinInputRow(
                length: 4,
                isObscured: true,
                onCompleted: (pin) => setState(() => _pin = pin),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 33),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : ContinueButton(
                          onPressed: _pin.length == 4 ? _onContinue : null,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
