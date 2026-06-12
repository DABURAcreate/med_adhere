import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/patient_mgmt_repository.dart';

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
// id is either a numeric string (existing DB record) or "new_<timestamp>" (new)
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

  int? get dbId => int.tryParse(id);
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

TimeOfDay _parseTime(String hhmm) {
  final parts = hhmm.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts[0]) ?? 8,
    minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────
class MedicationScheduleScreen extends StatefulWidget {
  final String patientId;

  const MedicationScheduleScreen({super.key, required this.patientId});

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState
    extends State<MedicationScheduleScreen> {
  late List<_MedEntry> _meds;
  bool _hasChanges = false;
  bool _loading = true;

  String _patientName = '—';
  String _clinicCode = '—';
  String _patientInitials = '?';

  // DB ids present when the screen loaded — used to detect removals.
  final Set<int> _originalDbIds = {};

  final Map<String, TextEditingController> _nameCtrl = {};
  final Map<String, TextEditingController> _doseCtrl = {};

  @override
  void initState() {
    super.initState();
    _meds = [];
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchedule());
  }

  @override
  void dispose() {
    for (final c in _nameCtrl.values) { c.dispose(); }
    for (final c in _doseCtrl.values) { c.dispose(); }
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> _loadSchedule() async {
    final patientIdInt = int.tryParse(widget.patientId);
    if (patientIdInt == null) {
      setState(() => _loading = false);
      return;
    }

    final mgmtRepo = context.read<PatientMgmtRepository>();

    final patient = await mgmtRepo.getPatientById(patientIdInt);
    final meds = await mgmtRepo.getMedicationsForPatient(patientIdInt);
    final reminders = await mgmtRepo.getRemindersForPatient(patientIdInt);

    // Group reminders by medicationId
    final remindersByMed = <int, List<String>>{};
    for (final r in reminders) {
      if (r.isActive) {
        remindersByMed.putIfAbsent(r.medicationId, () => []).add(r.scheduledTime);
      }
    }

    final entries = <_MedEntry>[];
    for (final med in meds) {
      _originalDbIds.add(med.id);
      final times = remindersByMed[med.id] ?? [];
      final timeOfDays = times.map(_parseTime).toList();
      if (timeOfDays.isEmpty) timeOfDays.add(const TimeOfDay(hour: 8, minute: 0));

      final entry = _MedEntry(
        id: med.id.toString(),
        name: med.name,
        dosage: med.dosage,
        timesPerDay: timeOfDays.length,
        times: timeOfDays,
        active: med.isActive,
      );
      entries.add(entry);
    }

    // Set up text controllers
    final Map<String, TextEditingController> nameCtrl = {};
    final Map<String, TextEditingController> doseCtrl = {};
    for (final e in entries) {
      nameCtrl[e.id] = TextEditingController(text: e.name);
      doseCtrl[e.id] = TextEditingController(text: e.dosage);
    }

    if (!mounted) return;

    final name = patient?.fullName ?? '—';
    setState(() {
      _patientName = name;
      _clinicCode = patient?.registrationCode ?? '—';
      _patientInitials = name
          .trim()
          .split(' ')
          .where((w) => w.isNotEmpty)
          .take(2)
          .map((w) => w[0].toUpperCase())
          .join();
      _meds = entries;
      _nameCtrl.addAll(nameCtrl);
      _doseCtrl.addAll(doseCtrl);
      _loading = false;
    });
  }

  void _markChanged() => setState(() => _hasChanges = true);

  // ── Add medication (bottom sheet) ─────────────────────────────────────────
  void _showAddSheet() {
    final l10n = AppLocalizations.of(context)!;
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
                          color: kP4.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: kP4, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.addMedication,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: kP2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sheetFieldLabel(l10n.medicationNameLabel),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDec(
                        hint: 'e.g. Isoniazid',
                        icon: Icons.medication_liquid_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.required : null,
                  ),
                  const SizedBox(height: 14),
                  _sheetFieldLabel(l10n.dosageFieldLabel),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: doseCtrl,
                    style: const TextStyle(fontSize: 14),
                    decoration: _inputDec(
                        hint: 'e.g. 300 mg', icon: Icons.scale_rounded),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l10n.required : null,
                  ),
                  const SizedBox(height: 14),
                  _sheetFieldLabel(l10n.timesPerDay),
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
                                  color: sel ? kP3 : Colors.grey.shade300),
                            ),
                            child: Text(
                              '×',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: sel ? Colors.white : Colors.grey.shade600,
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
                      final id = 'new_${DateTime.now().millisecondsSinceEpoch}';
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
                        _nameCtrl[id] = TextEditingController(text: entry.name);
                        _doseCtrl[id] = TextEditingController(text: entry.dosage);
                        _hasChanges = true;
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(l10n.addMedication),
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
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.removeMedication,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: kP2)),
        content: Text(
          l10n.removeMedicationContent(med.name),
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade700, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
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
            child: Text(l10n.remove,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    final l10n = AppLocalizations.of(context)!;
    // Flush controller values back into models
    for (final m in _meds) {
      m.name = _nameCtrl[m.id]?.text.trim() ?? m.name;
      m.dosage = _doseCtrl[m.id]?.text.trim() ?? m.dosage;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.saveChangesQuestion,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: kP2)),
        content: Text(
          l10n.saveChangesContent,
          style: TextStyle(
              fontSize: 13, color: Colors.grey.shade700, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel,
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _persistSchedule();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kP4,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(l10n.save,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _persistSchedule() async {
    final patientIdInt = int.tryParse(widget.patientId);
    if (patientIdInt == null) return;

    final currentDbIds =
        _meds.map((m) => m.dbId).whereType<int>().toSet();
    final removedIds =
        _originalDbIds.difference(currentDbIds).toList();

    final entries = _meds.map((m) {
      return MedScheduleEntry(
        existingId: m.dbId,
        name: m.name,
        dosage: m.dosage,
        times: m.times.map(_fmt).toList(),
        active: m.active,
      );
    }).toList();

    try {
      await context.read<PatientMgmtRepository>().saveMedicationSchedule(
        patientId: patientIdInt,
        entries: entries,
        removedIds: removedIds,
      );

      if (!mounted) return;
      setState(() {
        _hasChanges = false;
        // Refresh original ids after save
        _originalDbIds.clear();
        _originalDbIds.addAll(currentDbIds);
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.scheduleSaved),
        backgroundColor: kSuccess,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.saveFailed(e.toString())),
        backgroundColor: kDanger,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: kBg,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
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
        title: Text(
          l10n.medicationScheduleTitle,
          style: const TextStyle(
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
            decoration:
                const BoxDecoration(gradient: LinearGradient(colors: [kP4, kP5])),
          ),
        ),
      );
  }

  void _showUnsavedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.unsavedChanges,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: kP2)),
        content: Text(l10n.leaveWithoutSaving,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade700, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.keepEditing,
                style: const TextStyle(color: kP3, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child:
                Text(l10n.discard, style: TextStyle(color: Colors.grey.shade500)),
          ),
        ],
      ),
    );
  }

  // ── Patient header ────────────────────────────────────────────────────────
  Widget _buildPatientHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kP1.withValues(alpha: 0.4), kP3.withValues(alpha: 0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_patientInitials,
                    style: const TextStyle(
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
                  Text(
                    _patientName,
                    style: const TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kP4.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kP4.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medication_rounded, size: 13, color: kP4),
                  const SizedBox(width: 5),
                  Text(
                    l10n.medsCount(_meds.length),
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: kP4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  // ── Change banner ─────────────────────────────────────────────────────────
  Widget _buildChangeBanner() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
        width: double.infinity,
        color: kWarning.withValues(alpha: 0.08),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: kWarning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.futureDosesOnly,
                style: TextStyle(
                  fontSize: 11,
                  color: kWarning.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
  }

  // ── Med tile (swipe-to-remove + expandable) ───────────────────────────────
  Widget _buildMedTile(_MedEntry med) {
    final l10n = AppLocalizations.of(context)!;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(l10n.remove,
                style: const TextStyle(
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
            color: med.active ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () =>
                    setState(() => med.isExpanded = !med.isExpanded),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
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
                                    color: kSuccess.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  )
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (med.active ? kP4 : Colors.grey.shade400)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.medication_liquid_rounded,
                            color: med.active
                                ? kP4
                                : Colors.grey.shade400,
                            size: 20),
                      ),
                      const SizedBox(width: 10),
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
                                Text(med.dosage,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kP3.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n.timesDaily(med.timesPerDay),
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
                      if (!med.isExpanded) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: med.times
                              .take(2)
                              .map((t) => Text(_fmt(t),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  )))
                              .toList(),
                        ),
                        if (med.times.length > 2)
                          Text('+${med.times.length - 2}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400)),
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

  Widget _buildExpandedContent(_MedEntry med) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1, thickness: 0.8, color: Colors.grey.shade100),
            const SizedBox(height: 14),
            _exLabel(l10n.dosageFieldLabel),
            const SizedBox(height: 6),
            TextFormField(
              controller: _doseCtrl[med.id],
              style: const TextStyle(fontSize: 13),
              onChanged: (_) => _markChanged(),
              decoration: _inputDec(
                  hint: 'e.g. 300 mg', icon: Icons.scale_rounded),
            ),
            const SizedBox(height: 14),
            _exLabel(l10n.timesPerDay),
            const SizedBox(height: 8),
            Row(
              children: [1, 2, 3, 4].map((n) {
                final sel = med.timesPerDay == n;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      med.timesPerDay = n;
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
                        '×',
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
            _exLabel(l10n.reminderTimesLabel),
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
                        color: kP2.withValues(alpha: 0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: kP2)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.doseLabel(i + 1),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600)),
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
                          color: kP3.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kP3.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 14, color: kP3),
                            const SizedBox(width: 6),
                            Text(_fmt(t),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: kP2,
                                )),
                            const SizedBox(width: 6),
                            Icon(Icons.edit_rounded, size: 11, color: kP4),
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
            Row(
              children: [
                Icon(
                  med.active
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 18,
                  color:
                      med.active ? kSuccess : Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.active ? l10n.activeLabel : l10n.inactiveLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: med.active ? kSuccess : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        med.active
                            ? l10n.patientReceivesReminders
                            : l10n.noRemindersSent,
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
                  activeThumbColor: kSuccess,
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
  }

  // ── Add button ────────────────────────────────────────────────────────────
  Widget _buildAddButton() {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
        onTap: _showAddSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: kP4.withValues(alpha: 0.45),
                width: 1.5,
                style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_rounded, color: kP4, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.addMedication,
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
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kP1.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.medication_rounded, size: 36, color: kP4),
              ),
              const SizedBox(height: 16),
              Text(l10n.noMedicationsYet,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kP2)),
              const SizedBox(height: 6),
              Text(
                l10n.addFirstMedication,
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
                label: Text(l10n.addMedication),
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
  }

  // ── Save bar ──────────────────────────────────────────────────────────────
  Widget _buildSaveBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _hasChanges ? _save : null,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: Text(_hasChanges ? l10n.saveChanges : l10n.noChanges),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _hasChanges ? kP4 : Colors.grey.shade300,
            foregroundColor: _hasChanges ? Colors.white : Colors.grey.shade500,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700),
            elevation: 0,
          ),
        ),
      );
  }

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

  InputDecoration _inputDec({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
