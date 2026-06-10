import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

class RegistrationCodeScreen extends StatefulWidget {
  const RegistrationCodeScreen({super.key});

  @override
  State<RegistrationCodeScreen> createState() => _RegistrationCodeScreenState();
}

class _RegistrationCodeScreenState extends State<RegistrationCodeScreen> {
  String _code = '';
  bool _loading = false;
  String? _error;

  Future<void> _onContinue() async {
    if (_code.length < 5 || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context.read<AuthRepository>().lookupOrCreateByCode(_code);

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case AuthSuccess(:final userId):
        context.go('/pin-setup', extra: int.parse(userId));
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
                l10n.enterRegistrationCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 56),

              PinInputRow(
                length: 5,
                boxSize: 50,
                boxSpacing: 14,
                onCompleted: (code) => setState(() => _code = code),
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

              const SizedBox(height: 53),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : ContinueButton(
                          onPressed: _code.length == 5 ? _onContinue : null,
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
