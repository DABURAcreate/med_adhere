import 'dart:math';
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

// ── Models ────────────────────────────────────────────────────────────────────
class _MedicationEntry {
  String name;
  String dosage;
  int timesPerDay;
  List<TimeOfDay> reminderTimes;

  _MedicationEntry({
    this.name = '',
    this.dosage = '',
    this.timesPerDay = 1,
    List<TimeOfDay>? reminderTimes,
  }) : reminderTimes = reminderTimes ?? [const TimeOfDay(hour: 8, minute: 0)];
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _generatePatientCode() {
  final rand = Random();
  final letters = String.fromCharCodes(
      List.generate(3, (_) => rand.nextInt(26) + 65));
  final digits = rand.nextInt(9000) + 1000;
  return 'MBM-$digits';
}

String _generateActivationCode() {
  final rand = Random();
  return (10000 + rand.nextInt(90000)).toString();
}

String _formatTime(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

List<TimeOfDay> _defaultTimes(int count) {
  const defaults = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 21, minute: 0),
  ];
  return List.generate(count, (i) => defaults[i % defaults.length]);
}

// ── Screen ────────────────────────────────────────────────────────────────────
class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  int _step = 0;
  final _pageController = PageController();

  // Step 1
  final _fullNameCtrl = TextEditingController();
  final _patientCodeCtrl = TextEditingController();
  final _caregiverPhoneCtrl = TextEditingController();
  final Set<String> _selectedConditions = {};
  final _step1Key = GlobalKey<FormState>();

  // Step 2
  final List<_MedicationEntry> _medications = [_MedicationEntry()];
  final _step2Key = GlobalKey<FormState>();

  // Generated on register
  late final String _activationCode;

  static const _conditions = ['HIV', 'TB', 'Hypertension', 'Diabetes', 'Other'];

  @override
  void initState() {
    super.initState();
    _patientCodeCtrl.text = _generatePatientCode();
    _activationCode = _generateActivationCode();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameCtrl.dispose();
    _patientCodeCtrl.dispose();
    _caregiverPhoneCtrl.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_step == 0) {
      if (!(_step1Key.currentState?.validate() ?? false)) return;
      if (_selectedConditions.isEmpty) {
        _showSnack('Please select at least one condition.');
        return;
      }
    }
    if (_step == 1) {
      if (!(_step2Key.currentState?.validate() ?? false)) return;
    }
    if (_step < 3) _goToStep(_step + 1);
  }

  void _back() {
    if (_step > 0) _goToStep(_step - 1);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: kP3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _register() {
    _showSuccessSheet();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: kP2,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () => context.pop(),
    ),
    title: const Text(
      'Register Patient',
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
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

  // ── Stepper ───────────────────────────────────────────────────────────────
  Widget _buildStepper() {
    final steps = ['Patient\nInfo', 'Medications', 'Reminders', 'Confirm'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final idx = e.key;
          final label = e.value;
          final done = idx < _step;
          final active = idx == _step;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: done ? () => _goToStep(idx) : null,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: done
                                ? const Color(0xFF16A34A)
                                : active
                                ? kP3
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                            boxShadow: active
                                ? [
                              BoxShadow(
                                  color: kP3.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ]
                                : null,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check_rounded,
                                size: 16, color: Colors.white)
                                : Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: active
                                    ? Colors.white
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: active || done
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? kP3
                                : done
                                ? const Color(0xFF16A34A)
                                : Colors.grey.shade400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (idx < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xFF16A34A)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() => Container(
    padding: EdgeInsets.fromLTRB(
        16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3))
      ],
    ),
    child: Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kP3,
                side: BorderSide(color: kP3.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _step == 3 ? _register : _next,
            icon: Icon(
              _step == 3
                  ? Icons.how_to_reg_rounded
                  : Icons.arrow_forward_rounded,
              size: 18,
            ),
            label: Text(_step == 3 ? 'Register Patient' : 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _step == 3
                  ? const Color(0xFF16A34A)
                  : kP3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 1 — Patient Info
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep1() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    child: Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading('Patient Information',
              'Enter the patient\'s basic details as recorded at the clinic.'),
          const SizedBox(height: 20),

          // Full name
          _fieldLabel('Full Name *'),
          const SizedBox(height: 6),
          _textField(
            controller: _fullNameCtrl,
            hint: 'e.g. Sipho Dlamini',
            icon: Icons.person_rounded,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Clinic code
          _fieldLabel('Clinic Patient Code *'),
          const SizedBox(height: 4),
          Text(
            'Auto-generated — edit if needed',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _patientCodeCtrl,
                  hint: 'e.g. MBM-0041',
                  icon: Icons.badge_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Patient code is required'
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              _iconBtn(
                icon: Icons.refresh_rounded,
                tooltip: 'Regenerate code',
                onTap: () =>
                    setState(() => _patientCodeCtrl.text = _generatePatientCode()),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Conditions
          _fieldLabel('Condition(s) *'),
          const SizedBox(height: 4),
          Text(
            'Select all that apply',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _conditions.map((c) {
              final selected = _selectedConditions.contains(c);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selectedConditions.remove(c);
                  } else {
                    _selectedConditions.add(c);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? kP3 : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected ? kP3 : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    c,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Caregiver phone
          _fieldLabel('Caregiver Phone Number (optional)'),
          const SizedBox(height: 6),
          _textField(
            controller: _caregiverPhoneCtrl,
            hint: 'e.g. 071 234 5678',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 20),
          _infoBox(
            icon: Icons.lock_rounded,
            color: kP4,
            text:
            'Full name and ID are stored securely on the backend only. The local device stores only the clinic patient code.',
          ),
        ],
      ),
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 2 — Medications
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep2() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    child: Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading('Medications',
              'Add all medications the patient must take.'),
          const SizedBox(height: 20),

          ..._medications.asMap().entries.map((e) {
            return _buildMedCard(e.key, e.value);
          }),

          const SizedBox(height: 12),

          // Add medication
          GestureDetector(
            onTap: () => setState(() => _medications.add(_MedicationEntry())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: kP4.withOpacity(0.5),
                    width: 1.5,
                    style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_rounded, color: kP4, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+ Add Another Medication',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kP4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMedCard(int idx, _MedicationEntry med) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: kP4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.medication_rounded,
                    color: kP4, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Medication ${idx + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kP2,
              ),
            ),
            const Spacer(),
            if (_medications.length > 1)
              GestureDetector(
                onTap: () => setState(() => _medications.removeAt(idx)),
                child: Icon(Icons.close_rounded,
                    color: Colors.grey.shade400, size: 20),
              ),
          ],
        ),
        const SizedBox(height: 14),

        _fieldLabel('Medication Name *'),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: med.name,
          onChanged: (v) => med.name = v,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDecoration(
              hint: 'e.g. Tenofovir / Lamivudine', icon: Icons.medication_liquid_rounded),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Medication name is required'
              : null,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Dosage *'),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: med.dosage,
          onChanged: (v) => med.dosage = v,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDecoration(
              hint: 'e.g. 300/300/50 mg', icon: Icons.scale_rounded),
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Dosage is required' : null,
        ),
        const SizedBox(height: 12),

        _fieldLabel('Times per day *'),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((n) {
            final selected = med.timesPerDay == n;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  med.timesPerDay = n;
                  med.reminderTimes = _defaultTimes(n);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: n < 4 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? kP3 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? kP3 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    n == 1 ? '1×' : n == 2 ? '2×' : n == 3 ? '3×' : '4×',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 3 — Reminders
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep3() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeading('Set Reminder Times',
            'Set daily reminder times for each medication. These are set on behalf of the patient.'),
        const SizedBox(height: 20),

        ..._medications.asMap().entries.map((e) {
          final idx = e.key;
          final med = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: kP4.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.medication_rounded,
                          color: kP4, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        med.name.isEmpty
                            ? 'Medication ${idx + 1}'
                            : med.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kP2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kP3.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${med.timesPerDay}× daily',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kP3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...med.reminderTimes.asMap().entries.map((te) {
                  final ti = te.key;
                  final time = te.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: kP2.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${ti + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: kP2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Dose ${ti + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: kP3,
                                    onPrimary: Colors.white,
                                    surface: kCard,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() =>
                              med.reminderTimes[ti] = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: kP3.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: kP3.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 15, color: kP3),
                                const SizedBox(width: 6),
                                Text(
                                  _formatTime(time),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: kP2,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.edit_rounded,
                                    size: 12, color: kP4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),

        _infoBox(
          icon: Icons.info_outline_rounded,
          color: kP4,
          text:
          'Reminder times are set by the worker on behalf of the patient. The patient can adjust these after activating their account.',
        ),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════════════════════
  // STEP 4 — Confirm
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildStep4() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeading('Confirm Registration',
            'Review all details before registering the patient.'),
        const SizedBox(height: 20),

        // Patient info summary
        _summaryCard(
          title: 'Patient Information',
          icon: Icons.person_rounded,
          onEdit: () => _goToStep(0),
          children: [
            _summaryRow('Full Name', _fullNameCtrl.text.isEmpty ? '—' : _fullNameCtrl.text),
            _summaryRow('Clinic Code', _patientCodeCtrl.text),
            _summaryRow('Conditions',
                _selectedConditions.isEmpty ? '—' : _selectedConditions.join(', ')),
            if (_caregiverPhoneCtrl.text.isNotEmpty)
              _summaryRow('Caregiver Phone', _caregiverPhoneCtrl.text),
          ],
        ),
        const SizedBox(height: 12),

        // Medications summary
        _summaryCard(
          title: 'Medications',
          icon: Icons.medication_rounded,
          onEdit: () => _goToStep(1),
          children: _medications.asMap().entries.map((e) {
            final med = e.value;
            return _summaryRow(
              med.name.isEmpty ? 'Med ${e.key + 1}' : med.name,
              '${med.dosage} — ${med.timesPerDay}× daily',
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Reminders summary
        _summaryCard(
          title: 'Reminders',
          icon: Icons.notifications_rounded,
          onEdit: () => _goToStep(2),
          children: _medications.asMap().entries.map((e) {
            final med = e.value;
            final times =
            med.reminderTimes.map(_formatTime).join(', ');
            return _summaryRow(
              med.name.isEmpty ? 'Med ${e.key + 1}' : med.name,
              times,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Activation code preview
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kP2, kP3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kP2.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.key_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Activation Code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Give this code to the patient to activate their account',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Code display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _activationCode.split('').map((digit) {
                  return Container(
                    width: 48,
                    height: 58,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        digit,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: _activationCode));
                  _showSnack('Code copied to clipboard');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Copy Code',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _summaryCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: kP3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: kP3),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kP2,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kP3.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 11, color: kP3),
                        const SizedBox(width: 3),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: kP3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.8),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _summaryRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Success sheet ─────────────────────────────────────────────────────────
  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 32, 24, MediaQuery.of(context).padding.bottom + 32),
        decoration: const BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.how_to_reg_rounded,
                  size: 36, color: Color(0xFF16A34A)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Patient Registered!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kP2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${_fullNameCtrl.text} has been registered successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Code box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kP2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'PATIENT ACTIVATION CODE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _activationCode,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share this 5-digit code with the patient.\nThey will use it to set their PIN and activate their account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Copy button
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _activationCode));
                _showSnack('Activation code copied');
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy Code'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kP3,
                side: BorderSide(color: kP3.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 46),
                textStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            // Done button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                context.pop(); // back to patient list
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Done'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared widget helpers ─────────────────────────────────────────────────
  Widget _stepHeading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: kP2,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
          height: 1.4,
        ),
      ),
    ],
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
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(fontSize: 14),
        decoration: _inputDecoration(hint: hint, icon: icon),
        validator: validator,
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: kP4, size: 20),
        filled: true,
        fillColor: kBg,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kP4, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
        ),
      );

  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 50,
            decoration: BoxDecoration(
              color: kP4.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kP4.withOpacity(0.25)),
            ),
            child: Icon(icon, color: kP4, size: 20),
          ),
        ),
      );

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String text,
  }) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
}