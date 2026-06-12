import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/caregiver_repository.dart';
import '../../../providers/session_provider.dart';

// ── Colour palette ────────────────────────────────────────────────────────────
const kP1 = Color(0xFF6AA9CB);
const kP2 = Color(0xFF114C90);
const kP3 = Color(0xFF165B9E);
const kP4 = Color(0xFF1A7E95);
const kP5 = Color(0xFF238F9C);
const kBg = Color(0xFFF0F5FB);
const kCard = Color(0xFFFFFFFF);
const kDanger = Color(0xFFB91C1C);
const kSuccess = Color(0xFF16A34A);

// ── Relationship options ───────────────────────────────────────────────────────
const _relationships = [
  'Mother',
  'Father',
  'Spouse / Partner',
  'Sibling',
  'Friend',
  'Other',
];

// ── Mask helper ───────────────────────────────────────────────────────────────
// Turns "+27821234567" → "+27 ** *** 4567"
String _maskPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return raw;
  final last4 = digits.substring(digits.length - 4);
  return '+27 ** *** $last4';
}

// ── Screen ────────────────────────────────────────────────────────────────────
class CaregiverLinkScreen extends StatefulWidget {
  const CaregiverLinkScreen({super.key});

  @override
  State<CaregiverLinkScreen> createState() => _CaregiverLinkScreenState();
}

class _CaregiverLinkScreenState extends State<CaregiverLinkScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _isLinked = false;
  String _linkedPhone = '';
  String _linkedRelationship = '';

  // Form state
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String? _selectedRelationship;
  bool _consentGiven = false;
  bool _isSaving = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCaregiver());
  }

  Future<void> _loadCaregiver() async {
    final patientId = context.read<SessionProvider>().currentPatientId;
    if (patientId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final info =
        await context.read<CaregiverRepository>().getCaregiver(patientId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (info != null) {
        _isLinked = true;
        _linkedPhone = info.phone;
        _linkedRelationship = info.relationship;
      }
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validatePhone(String? v) {
    final l10n = AppLocalizations.of(context)!;
    if (v == null || v.trim().isEmpty) return l10n.phoneRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return l10n.phoneInvalid;
    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_consentGiven) {
      _showSnack(AppLocalizations.of(context)!.caregiverConsentRequired, isError: true);
      return;
    }

    final patientId = context.read<SessionProvider>().currentPatientId;
    if (patientId == null) return;

    setState(() => _isSaving = true);

    final raw = _phoneCtrl.text.trim();
    final normalised = raw.startsWith('0')
        ? '+27${raw.substring(1)}'
        : raw.startsWith('+27')
            ? raw
            : '+27$raw';
    final relationship = _selectedRelationship ?? 'Other';

    try {
      await context.read<CaregiverRepository>().linkCaregiver(
            patientId,
            phone: normalised,
            relationship: relationship,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSnack(AppLocalizations.of(context)!.caregiverSaveFailed, isError: true);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isLinked = true;
      _linkedPhone = normalised;
      _linkedRelationship = relationship;
      _phoneCtrl.clear();
      _selectedRelationship = null;
      _consentGiven = false;
    });

    _showSuccessSheet();
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  void _confirmRemove() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.removeCaregiverDialog,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: kP2)),
        content: Text(
          l10n.removeCaregiverContent,
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final patientId =
                  context.read<SessionProvider>().currentPatientId;
              if (patientId != null) {
                try {
                  await context
                      .read<CaregiverRepository>()
                      .unlinkCaregiver(patientId);
                } catch (_) {}
              }
              if (!mounted) return;
              setState(() {
                _isLinked = false;
                _linkedPhone = '';
                _linkedRelationship = '';
              });
              _showSnack(AppLocalizations.of(context)!.caregiverRemoved, isError: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(l10n.remove,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Snack ─────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {required bool isError}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? kDanger : kSuccess,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );

  // ── Success bottom sheet ──────────────────────────────────────────────────
  void _showSuccessSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 28, 24, MediaQuery.of(context).padding.bottom + 28),
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: kSuccess.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_rounded,
                  size: 34, color: kSuccess),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.caregiverLinkedSuccess,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kP2),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.caregiverLinkedSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            // Masked phone
            _linkedInfoPill(
              icon: Icons.phone_rounded,
              label: _maskPhone(_linkedPhone),
              color: kP4,
            ),
            const SizedBox(height: 8),
            _linkedInfoPill(
              icon: Icons.people_alt_rounded,
              label: _linkedRelationship,
              color: kP3,
            ),
            const SizedBox(height: 8),
            _linkedInfoPill(
              icon: Icons.lock_rounded,
              label: l10n.privacyProtected,
              color: kSuccess,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(l10n.done),
              style: ElevatedButton.styleFrom(
                backgroundColor: kP3,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkedInfoPill(
      {required IconData icon,
        required String label,
        required Color color}) =>
      Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
          ],
        ),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExplanationCard(),
                    const SizedBox(height: 20),
                    _isLinked ? _buildLinkedCard() : _buildLinkForm(),
                  ],
                ),
              ),
            ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
    backgroundColor: kP2,
    foregroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () => context.pop(),
    ),
    title: Text(
      l10n.caregiverTitle,
      style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [kP2, kP3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
    ),
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(4),
      child: Container(
        height: 4,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [kP4, kP5])),
      ),
    ),
  );
  }

  // ── Explanation card ──────────────────────────────────────────────────────
  Widget _buildExplanationCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kP4.withValues(alpha: 0.2), kP3.withValues(alpha: 0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.people_rounded,
              color: kP3, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.whatIsCaregiver,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: kP2),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.caregiverDescription,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.55),
              ),
              const SizedBox(height: 12),
              // Privacy chips row
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _privacyChip(
                      Icons.notifications_active_rounded,
                      l10n.missedDoseAlert,
                      kSuccess),
                  _privacyChip(
                      Icons.do_not_disturb_rounded,
                      l10n.noMedicationNames,
                      kDanger),
                  _privacyChip(
                      Icons.health_and_safety_rounded,
                      l10n.noDiagnosis,
                      kDanger),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  }

  Widget _privacyChip(IconData icon, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      );

  // ── Already linked card ───────────────────────────────────────────────────
  Widget _buildLinkedCard() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kSuccess.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kSuccess.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: kSuccess, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.caregiverLinkedTitle,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: kP2),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSuccess.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.activeStatus,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kSuccess)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 0.8),
            const SizedBox(height: 14),

            // Phone (masked)
            _detailRow(
              icon: Icons.phone_rounded,
              label: l10n.phoneLabel,
              value: _maskPhone(_linkedPhone),
            ),
            const SizedBox(height: 10),
            _detailRow(
              icon: Icons.people_alt_rounded,
              label: l10n.relationshipLabel,
              value: _linkedRelationship,
            ),
            const SizedBox(height: 10),
            _detailRow(
              icon: Icons.notifications_active_rounded,
              label: l10n.alertTypeLabel,
              value: l10n.dosesMissedOnly,
            ),
            const SizedBox(height: 18),

            // Privacy reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kP4.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kP4.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: kP4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.privacyNote,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Remove button
      OutlinedButton.icon(
        onPressed: _confirmRemove,
        icon: const Icon(Icons.person_remove_rounded, size: 18),
        label: Text(l10n.removeCaregiverButton),
        style: OutlinedButton.styleFrom(
          foregroundColor: kDanger,
          side: BorderSide(color: kDanger.withValues(alpha: 0.6), width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: kP3.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: kP3),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
          ),
        ],
      );

  // ── Link form ─────────────────────────────────────────────────────────────
  Widget _buildLinkForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone field
        _fieldLabel(l10n.caregiverPhoneField),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code pill
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kP2.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kP2.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SA flag emoji approximation via text
                  const Text('🇿🇦',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('+27',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kP2)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[\d\s\-\+]')),
                ],
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: '0XX XXX XXXX',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  prefixIcon: Icon(Icons.phone_rounded,
                      color: kP4, size: 20),
                  filled: true,
                  fillColor: kCard,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: kP4, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: kDanger, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: kDanger, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.grey.shade200),
                  ),
                ),
                validator: _validatePhone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.caregiverPhoneHint,
          style: TextStyle(
              fontSize: 10, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 18),

        // Relationship dropdown
        _fieldLabel(l10n.relationshipField),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: _selectedRelationship,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.people_alt_rounded,
                color: kP4, size: 20),
            hintText: l10n.selectRelationship,
            hintStyle: TextStyle(
                color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: kCard,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kP4, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.grey.shade200),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: kDanger, width: 1.5),
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: kP4, size: 22),
          dropdownColor: kCard,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E)),
          items: _relationships
              .map((r) => DropdownMenuItem(
              value: r, child: Text(r)))
              .toList(),
          onChanged: (v) =>
              setState(() => _selectedRelationship = v),
          validator: (v) =>
          v == null ? l10n.selectRelationshipRequired : null,
        ),
        const SizedBox(height: 24),

        // Consent checkbox
        _buildConsentBox(),
        const SizedBox(height: 28),

        // Link button
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation(
                      Colors.white)))
              : const Icon(Icons.person_add_rounded, size: 18),
          label: Text(_isSaving ? l10n.linking : l10n.linkCaregiver),
          style: ElevatedButton.styleFrom(
            backgroundColor: kP4,
            foregroundColor: Colors.white,
            disabledBackgroundColor: kP4.withValues(alpha: 0.55),
            disabledForegroundColor: Colors.white70,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800),
            elevation: 0,
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildConsentBox() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
    onTap: () =>
        setState(() => _consentGiven = !_consentGiven),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _consentGiven
            ? kSuccess.withValues(alpha: 0.05)
            : kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _consentGiven
              ? kSuccess.withValues(alpha: 0.4)
              : Colors.grey.shade300,
          width: _consentGiven ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color:
              _consentGiven ? kSuccess : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _consentGiven
                    ? kSuccess
                    : Colors.grey.shade400,
                width: 1.5,
              ),
            ),
            child: _consentGiven
                ? const Icon(Icons.check_rounded,
                size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.consentText,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.55,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600),
  );
}