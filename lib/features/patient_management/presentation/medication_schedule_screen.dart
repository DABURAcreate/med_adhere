import 'package:flutter/material.dart';
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
const kWarning = Color(0xFFD97706);

// ── Model ─────────────────────────────────────────────────────────────────────
class _MedEntry {
  String id;
  String name;
  String dosage;
  int timesPerDay;
  List<TimeOfDay> times;
  bool active;
  bool isExpanded;

  _MedEntry({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.times,
    this.active = true,
    this.isExpanded = false,
  });

  _MedEntry copyWith({
    String? name,
    String? dosage,
    int? timesPerDay,
    List<TimeOfDay>? times,
    bool? active,
    bool? isExpanded,
  }) =>
      _MedEntry(
        id: id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        timesPerDay: timesPerDay ?? this.timesPerDay,
        times: times ?? List.from(this.times),
        active: active ?? this.active,
        isExpanded: isExpanded ?? this.isExpanded,
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmt(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

List<TimeOfDay> _defaultTimes(int n) {
  const all = [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 21, minute: 0),
  ];
  return List.generate(n, (i) => all[i % all.length]);
}

// ── Fake data ─────────────────────────────────────────────────────────────────
List<_MedEntry> _fakeMeds(String patientId) => [
  _MedEntry(
    id: 'med1',
    name: 'Tenofovir / Lamivudine / Dolutegravir',
    dosage: '300/300/50 mg',
    timesPerDay: 1,
    times: [const TimeOfDay(hour: 8, minute: 0)],
    active: true,
  ),
  _MedEntry(
    id: 'med2',
    name: 'Amlodipine',
    dosage: '5 mg',
    timesPerDay: 2,
    times: [
      const TimeOfDay(hour: 8, minute: 0),
      const TimeOfDay(hour: 20, minute: 0),
    ],
    active: true,
  ),
  _MedEntry(
    id: 'med3',
    name: 'Cotrimoxazole',
    dosage: '960 mg',
    timesPerDay: 1,
    times: [const TimeOfDay(hour: 8, minute: 0)],
    active: false,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class MedicationScheduleScreen extends StatefulWidget {
  final String patientId;

  const MedicationScheduleScreen({super.key, required this.patientId});

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late List<_MedEntry> _meds;
  bool _hasChanges = false;
  // Track controllers per med id
  final Map<String, TextEditingController> _nameCtrl = {};
  final Map<String, TextEditingController> _doseCtrl = {};

  // Fake patient info
  static const _patientName = 'Sipho Dlamini';
  static const _clinicCode = 'MBM-0041';

  @override
  void initState() {
    super.initState();
    _meds = _fakeMeds(widget.patientId);
    for (final m in _meds) {
      _nameCtrl[m.id] = TextEditingController(text: m.name);
      _doseCtrl[m.id] = TextEditingController(text: m.dosage);
    }
  }

  @override
  void dispose() {
    for (final c in _nameCtrl.values) {
      c.dispose();
    }
    for (final c in _doseCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _markChanged() => setState(() => _hasChanges = true);

  // ── Add medication (bottom sheet) ─────────────────────────────────────────
  void _showAddSheet() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    int times = 1;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kP4.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: kP4, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Add Medication',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: kP2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _sheetFieldLabel('Medication Name *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDec(
                        hint: 'e.g. Isoniazid',
                        icon: Icons.medication_liquid_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  _sheetFieldLabel('Dosage *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: doseCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDec(
                        hint: 'e.g. 300 mg', icon: Icons.scale_rounded),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  _sheetFieldLabel('Times per day'),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3, 4].map((n) {
                      final sel = times == n;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setModal(() => times = n),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.only(right: n < 4 ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: sel ? kP3 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: sel
                                      ? kP3
                                      : Colors.grey.shade300),
                            ),
                            child: Text(
                              '${n}×',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: sel
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      final id = 'med_${DateTime.now().millisecondsSinceEpoch}';
                      final entry = _MedEntry(
                        id: id,
                        name: nameCtrl.text.trim(),
                        dosage: doseCtrl.text.trim(),
                        timesPerDay: times,
                        times: _defaultTimes(times),
                        active: true,
                        isExpanded: true,
                      );
                      setState(() {
                        _meds.add(entry);
                        _nameCtrl[id] =
                            TextEditingController(text: entry.name);
                        _doseCtrl[id] =
                            TextEditingController(text: entry.dosage);
                        _hasChanges = true;
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Add Medication'),
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
          ),
        ),
      ),
    );
  }

  // ── Remove confirm ────────────────────────────────────────────────────────
  Future<bool> _confirmRemove(_MedEntry med) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Medication?',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: kP2),
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
            children: [
              const TextSpan(text: 'Remove '),
              TextSpan(
                text: med.name,
                style: const TextStyle(fontWeight: FontWeight.w700, color: kP2),
              ),
              const TextSpan(
                  text:
                  ' from this patient\'s schedule? Past logs will not be affected.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
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
    return result ?? false;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    // Flush controller values back into models
    for (final m in _meds) {
      m.name = _nameCtrl[m.id]?.text.trim() ?? m.name;
      m.dosage = _doseCtrl[m.id]?.text.trim() ?? m.dosage;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Save Changes?',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: kP2)),
        content: Text(
          'Changes will apply to future doses only. Past medication logs will not be affected.',
          style:
          TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _hasChanges = false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Schedule saved successfully'),
                backgroundColor: kSuccess,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kP4,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPatientHeader(),
          _buildChangeBanner(),
          Expanded(
            child: _meds.isEmpty
                ? _buildEmpty()
                : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                ..._meds.map((m) => _buildMedTile(m)),
                const SizedBox(height: 8),
                _buildAddButton(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSaveBar(),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: kP2,
    foregroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () {
        if (_hasChanges) {
          _showUnsavedDialog();
        } else {
          context.pop();
        }
      },
    ),
    title: const Text(
      'Medication Schedule',
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

  void _showUnsavedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Unsaved Changes',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: kP2)),
        content: Text('You have unsaved changes. Leave without saving?',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Editing',
                style: TextStyle(
                    color: kP3, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Discard',
                style: TextStyle(
                    color: Colors.grey.shade500)),
          ),
        ],
      ),
    );
  }

  // ── Patient header ────────────────────────────────────────────────────────
  Widget _buildPatientHeader() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kP1.withOpacity(0.4), kP3.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('SD',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kP2)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                _patientName,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E)),
              ),
              Text(
                _clinicCode,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kP4.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kP4.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.medication_rounded, size: 13, color: kP4),
              const SizedBox(width: 5),
              Text(
                '${_meds.length} meds',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kP4),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Change banner ─────────────────────────────────────────────────────────
  Widget _buildChangeBanner() => Container(
    width: double.infinity,
    color: kWarning.withOpacity(0.08),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    child: Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: kWarning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Changes apply to future doses only and will not affect logged history.',
            style: TextStyle(
              fontSize: 11,
              color: kWarning.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Med tile (swipe-to-remove + expandable) ───────────────────────────────
  Widget _buildMedTile(_MedEntry med) {
    return Dismissible(
      key: ValueKey(med.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmRemove(med),
      onDismissed: (_) {
        setState(() {
          _nameCtrl.remove(med.id)?.dispose();
          _doseCtrl.remove(med.id)?.dispose();
          _meds.removeWhere((m) => m.id == med.id);
          _hasChanges = true;
        });
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kDanger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: med.active
                ? Colors.transparent
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // ── Tile header ──
              GestureDetector(
                onTap: () => setState(
                        () => med.isExpanded = !med.isExpanded),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      // Active indicator dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: med.active
                              ? kSuccess
                              : Colors.grey.shade400,
                          boxShadow: med.active
                              ? [
                            BoxShadow(
                              color: kSuccess.withOpacity(0.4),
                              blurRadius: 4,
                            )
                          ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (med.active ? kP4 : Colors.grey.shade400)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.medication_liquid_rounded,
                            color: med.active
                                ? kP4
                                : Colors.grey.shade400,
                            size: 20),
                      ),
                      const SizedBox(width: 10),
                      // Name + dosage
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: med.active
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.grey.shade400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  med.dosage,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kP3.withOpacity(0.07),
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${med.timesPerDay}× daily',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: kP3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Times preview (collapsed only)
                      if (!med.isExpanded) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: med.times
                              .take(2)
                              .map((t) => Text(
                            _fmt(t),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ))
                              .toList(),
                        ),
                        if (med.times.length > 2)
                          Text(
                            '+${med.times.length - 2}',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400),
                          ),
                        const SizedBox(width: 4),
                      ],
                      Icon(
                        med.isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: kP3,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Expanded content ──
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _buildExpandedContent(med),
                crossFadeState: med.isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(_MedEntry med) => Container(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, thickness: 0.8, color: Colors.grey.shade100),
        const SizedBox(height: 14),

        // Dose field
        _exLabel('Dosage'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _doseCtrl[med.id],
          style: const TextStyle(fontSize: 13),
          onChanged: (_) => _markChanged(),
          decoration: _inputDec(
              hint: 'e.g. 300 mg', icon: Icons.scale_rounded),
        ),
        const SizedBox(height: 14),

        // Frequency
        _exLabel('Times per day'),
        const SizedBox(height: 8),
        Row(
          children: [1, 2, 3, 4].map((n) {
            final sel = med.timesPerDay == n;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  med.timesPerDay = n;
                  // Preserve existing times, pad or trim
                  final existing = List<TimeOfDay>.from(med.times);
                  if (n > existing.length) {
                    final defaults = _defaultTimes(n);
                    for (int i = existing.length; i < n; i++) {
                      existing.add(defaults[i]);
                    }
                  } else {
                    existing.removeRange(n, existing.length);
                  }
                  med.times = existing;
                  _markChanged();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: n < 4 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? kP3 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel ? kP3 : Colors.grey.shade300),
                  ),
                  child: Text(
                    '${n}×',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: sel ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Time pickers
        _exLabel('Reminder times'),
        const SizedBox(height: 10),
        ...med.times.asMap().entries.map((e) {
          final i = e.key;
          final t = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kP2.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: kP2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Dose ${i + 1}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: t,
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
                      setState(() {
                        med.times[i] = picked;
                        _markChanged();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
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
                            size: 14, color: kP3),
                        const SizedBox(width: 6),
                        Text(
                          _fmt(t),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kP2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_rounded,
                            size: 11, color: kP4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 14),
        Divider(height: 1, thickness: 0.8, color: Colors.grey.shade100),
        const SizedBox(height: 12),

        // Active toggle
        Row(
          children: [
            Icon(
              med.active
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              size: 18,
              color: med.active ? kSuccess : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: med.active
                          ? kSuccess
                          : Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    med.active
                        ? 'Patient receives reminders for this medication'
                        : 'No reminders sent — medication paused',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        height: 1.3),
                  ),
                ],
              ),
            ),
            Switch(
              value: med.active,
              activeColor: kSuccess,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
              onChanged: (v) => setState(() {
                med.active = v;
                _markChanged();
              }),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Add button ────────────────────────────────────────────────────────────
  Widget _buildAddButton() => GestureDetector(
    onTap: _showAddSheet,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: kP4.withOpacity(0.45),
            width: 1.5,
            style: BorderStyle.solid),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_rounded, color: kP4, size: 20),
          const SizedBox(width: 8),
          Text(
            '+ Add Medication',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kP4,
            ),
          ),
        ],
      ),
    ),
  );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kP1.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child:
            Icon(Icons.medication_rounded, size: 36, color: kP4),
          ),
          const SizedBox(height: 16),
          const Text('No medications yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kP2)),
          const SizedBox(height: 6),
          Text(
            'Tap below to add the first medication for this patient.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddSheet,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Medication'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kP3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );

  // ── Save bar ──────────────────────────────────────────────────────────────
  Widget _buildSaveBar() => Container(
    padding: EdgeInsets.fromLTRB(
        16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: ElevatedButton.icon(
      onPressed: _hasChanges ? _save : null,
      icon: const Icon(Icons.save_rounded, size: 18),
      label: Text(_hasChanges ? 'Save Changes' : 'No Changes'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _hasChanges ? kP4 : Colors.grey.shade300,
        foregroundColor:
        _hasChanges ? Colors.white : Colors.grey.shade500,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _exLabel(String label) => Text(
    label,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade500,
      letterSpacing: 0.2,
    ),
  );

  Widget _sheetFieldLabel(String label) => Text(
    label,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade600,
    ),
  );

  InputDecoration _inputDec(
      {required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
        TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: kP4, size: 18),
        filled: true,
        fillColor: kBg,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kP4, width: 1.5),
        ),
      );
}