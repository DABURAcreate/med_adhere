import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/session_provider.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

class PinSetupScreen extends StatefulWidget {
  final int patientId;

  const PinSetupScreen({super.key, required this.patientId});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  String _confirm = '';
  bool _loading = false;
  String? _error;

  Future<void> _onContinue() async {
    if (_pin.length < 4 || _confirm.length < 4 || _loading) return;

    if (_pin != _confirm) {
      setState(() => _error = 'PINs do not match. Please try again.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await context
        .read<AuthRepository>()
        .setupPin(widget.patientId, _pin);

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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create PIN:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              PinInputRow(
                length: 4,
                isObscured: true,
                onCompleted: (pin) => setState(() => _pin = pin),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm PIN:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              PinInputRow(
                length: 4,
                isObscured: true,
                onCompleted: (pin) => setState(() => _confirm = pin),
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
                          onPressed: (_pin.length == 4 && _confirm.length == 4)
                              ? _onContinue
                              : null,
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
