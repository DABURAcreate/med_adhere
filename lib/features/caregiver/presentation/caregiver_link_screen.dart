import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
  // Simulate whether a caregiver is already linked
  bool _isLinked = false;
  String _linkedPhone = '+27831234567';
  String _linkedRelationship = 'Mother';

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
    _fadeAnim = CurvedAnimation(
        parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Enter a valid phone number';
    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_consentGiven) {
      _showSnack('Please confirm the caregiver has agreed.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final raw = _phoneCtrl.text.trim();
    final normalised = raw.startsWith('0')
        ? '+27${raw.substring(1)}'
        : raw.startsWith('+27')
        ? raw
        : '+27$raw';

    setState(() {
      _isSaving = false;
      _isLinked = true;
      _linkedPhone = normalised;
      _linkedRelationship = _selectedRelationship ?? 'Other';
      _phoneCtrl.clear();
      _selectedRelationship = null;
      _consentGiven = false;
    });

    _showSuccessSheet();
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  void _confirmRemove() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Caregiver?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: kP2)),
        content: Text(
          'Removing your caregiver means they will no longer receive '
              'dose-missed alerts. You can re-link at any time.',
          style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLinked = false);
              _showSnack('Caregiver removed.', isError: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Remove',
                style: TextStyle(fontWeight: FontWeight.w700)),
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
                color: kSuccess.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_rounded,
                  size: 34, color: kSuccess),
            ),
            const SizedBox(height: 14),
            const Text(
              'Caregiver Linked!',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kP2),
            ),
            const SizedBox(height: 6),
            Text(
              'They will receive a dose-missed alert only.\n'
                  'No medication or diagnosis details will be shared.',
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
              label: 'Dose-missed alerts only — privacy protected',
              color: kSuccess,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Done'),
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
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
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
      body: FadeTransition(
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
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: kP2,
    foregroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () => context.pop(),
    ),
    title: const Text(
      'Caregiver',
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

  // ── Explanation card ──────────────────────────────────────────────────────
  Widget _buildExplanationCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              colors: [kP4.withOpacity(0.2), kP3.withOpacity(0.15)],
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
              const Text(
                'What is a caregiver?',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: kP2),
              ),
              const SizedBox(height: 6),
              Text(
                'A caregiver will receive an alert when you miss a dose. '
                    'They will not see your medication details or diagnosis.',
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
                      'Missed dose alert',
                      kSuccess),
                  _privacyChip(
                      Icons.do_not_disturb_rounded,
                      'No medication names',
                      kDanger),
                  _privacyChip(
                      Icons.health_and_safety_rounded,
                      'No diagnosis',
                      kDanger),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _privacyChip(IconData icon, String label, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
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
  Widget _buildLinkedCard() => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kSuccess.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    color: kSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: kSuccess, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Caregiver Linked',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: kP2),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Active',
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
              label: 'Phone',
              value: _maskPhone(_linkedPhone),
            ),
            const SizedBox(height: 10),
            _detailRow(
              icon: Icons.people_alt_rounded,
              label: 'Relationship',
              value: _linkedRelationship,
            ),
            const SizedBox(height: 10),
            _detailRow(
              icon: Icons.notifications_active_rounded,
              label: 'Alert type',
              value: 'Dose-missed only',
            ),
            const SizedBox(height: 18),

            // Privacy reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kP4.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kP4.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: kP4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your medication details and diagnosis remain private. '
                          'Your caregiver only knows when a dose is missed.',
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
        label: const Text('Remove Caregiver'),
        style: OutlinedButton.styleFrom(
          foregroundColor: kDanger,
          side: BorderSide(color: kDanger.withOpacity(0.6), width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );

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
              color: kP3.withOpacity(0.08),
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
  Widget _buildLinkForm() => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone field
        _fieldLabel('Caregiver Phone Number *'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code pill
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kP2.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kP2.withOpacity(0.15)),
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
          'Enter the caregiver\'s South African mobile number.',
          style: TextStyle(
              fontSize: 10, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 18),

        // Relationship dropdown
        _fieldLabel('Relationship *'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRelationship,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.people_alt_rounded,
                color: kP4, size: 20),
            hintText: 'Select relationship…',
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
          v == null ? 'Please select a relationship' : null,
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
          label: Text(_isSaving ? 'Linking…' : 'Link Caregiver'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kP4,
            foregroundColor: Colors.white,
            disabledBackgroundColor: kP4.withOpacity(0.55),
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

  Widget _buildConsentBox() => GestureDetector(
    onTap: () =>
        setState(() => _consentGiven = !_consentGiven),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _consentGiven
            ? kSuccess.withOpacity(0.05)
            : kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _consentGiven
              ? kSuccess.withOpacity(0.4)
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
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.55),
                children: [
                  const TextSpan(
                      text: 'I confirm the caregiver has agreed ',
                      style: TextStyle(
                          fontWeight: FontWeight.w500)),
                  TextSpan(
                    text: 'to receive dose-missed alerts',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: kP2),
                  ),
                  const TextSpan(
                      text:
                      ' for this patient. They will not be sent any medication or diagnosis details.'),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600),
  );
}