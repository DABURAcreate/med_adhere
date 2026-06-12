import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../providers/session_provider.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

// ── Colour palette (matches worker screens) ───────────────────────────────────
const _kP2 = Color(0xFF114C90);
const _kP3 = Color(0xFF165B9E);
const _kP4 = Color(0xFF1A7E95);
const _kBg = Color(0xFFF0F5FB);

class RegisterWorkerScreen extends StatefulWidget {
  const RegisterWorkerScreen({super.key});

  @override
  State<RegisterWorkerScreen> createState() => _RegisterWorkerScreenState();
}

class _RegisterWorkerScreenState extends State<RegisterWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _staffNumberCtrl = TextEditingController();
  final _clinicNameCtrl = TextEditingController();

  String _pin = '';
  String _confirmPin = '';
  bool _saving = false;
  String? _pinError;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _staffNumberCtrl.dispose();
    _clinicNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    // Validate text fields
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validate PINs
    if (_pin.length < 4) {
      setState(() => _pinError = l10n.pinTooShort);
      return;
    }
    if (_pin != _confirmPin) {
      setState(() => _pinError = l10n.pinMismatch);
      return;
    }
    setState(() {
      _pinError = null;
      _saving = true;
    });

    final result = await context.read<AuthRepository>().registerWorker(
          fullName: _fullNameCtrl.text,
          staffNumber: _staffNumberCtrl.text,
          clinicName: _clinicNameCtrl.text.trim().isEmpty
              ? null
              : _clinicNameCtrl.text,
          pin: _pin,
        );

    if (!mounted) return;
    setState(() => _saving = false);

    switch (result) {
      case AuthSuccess(:final userId):
        context.read<SessionProvider>().signInAsWorker(
          userId,
          clinicName: _clinicNameCtrl.text.trim().isEmpty
              ? null
              : _clinicNameCtrl.text.trim(),
          fullName: _fullNameCtrl.text.trim(),
        );
        context.go(AppRoutes.dashboard);
      case AuthFailure(:final message):
        _showSnack(message);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: _kP3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kP2,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.registerWorkerTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kP2, _kP3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: MedAdhereHeader()),
              const SizedBox(height: 24),

              _sectionLabel(l10n.staffDetails),
              const SizedBox(height: 12),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textField(
                      controller: _fullNameCtrl,
                      label: l10n.fullNameLabel,
                      hint: 'e.g. Dr. Nomsa Dlamini',
                      icon: Icons.person_rounded,
                      capitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.fullNameRequired
                          : null,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      controller: _staffNumberCtrl,
                      label: l10n.staffNumberLabel,
                      hint: 'e.g. STF-00123',
                      icon: Icons.badge_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.staffNumberRequired
                          : null,
                    ),
                    const SizedBox(height: 14),

                    _textField(
                      controller: _clinicNameCtrl,
                      label: l10n.clinicNameOptional,
                      hint: 'e.g. Soweto Community Clinic',
                      icon: Icons.local_hospital_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _sectionLabel(l10n.setYourPin),
              const SizedBox(height: 4),
              Text(
                l10n.pinSubtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),

              _fieldLabel(l10n.pinLabel),
              const SizedBox(height: 10),
              PinInputRow(
                length: 4,
                isObscured: true,
                boxSize: 60,
                onCompleted: (pin) => setState(() => _pin = pin),
              ),

              const SizedBox(height: 20),
              _fieldLabel(l10n.confirmPinField),
              const SizedBox(height: 10),
              PinInputRow(
                length: 4,
                isObscured: true,
                boxSize: 60,
                onCompleted: (pin) => setState(() => _confirmPin = pin),
              ),

              if (_pinError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _pinError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kP3,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _kP3.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.how_to_reg_rounded, size: 20),
                            const SizedBox(width: 10),
                            Text(l10n.registerSignIn),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: _kP2,
        ),
      );

  Widget _fieldLabel(String label) => Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade600,
          letterSpacing: 0.2,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            style: const TextStyle(fontSize: 14),
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: Icon(icon, color: _kP4, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kP4, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFB91C1C), width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFB91C1C), width: 1.5),
              ),
            ),
          ),
        ],
      );
}
