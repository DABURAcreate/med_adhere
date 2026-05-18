import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart' show AppLocalizations;

import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // One line — gives you all translated strings for the current locale
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
                l10n.enterYourPin,   // ← from your ARB files
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
                onCompleted: (pin) {
                  debugPrint('PIN entered: $pin');
                },
              ),

              const SizedBox(height: 33),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ContinueButton(
                    onPressed: () => context.go('/patient/home'),
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