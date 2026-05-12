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

// ── Follow-up type ────────────────────────────────────────────────────────────
enum _FollowUpType { call, visit, sms }

extension _FollowUpTypeX on _FollowUpType {
  String get label => switch (this) {
    _FollowUpType.call => 'Call',
    _FollowUpType.visit => 'Visit',
    _FollowUpType.sms => 'SMS',
  };

  IconData get icon => switch (this) {
    _FollowUpType.call => Icons.phone_rounded,
    _FollowUpType.visit => Icons.home_rounded,
    _FollowUpType.sms => Icons.sms_rounded,
  };

  Color get color => switch (this) {
    _FollowUpType.call => kP3,
    _FollowUpType.visit => const Color(0xFF6D28D9),
    _FollowUpType.sms => kP4,
  };
}

// ── Helpers ───────────────────────────────────────────────────────────────────
DateTime _nextWorkingDay() {
  var d = DateTime.now().add(const Duration(days: 1));
  while (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
    d = d.add(const Duration(days: 1));
  }
  return DateTime(d.year, d.month, d.day, 9, 0);
}

String _fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final dow = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${dow[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
}

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

// ── Screen ────────────────────────────────────────────────────────────────────
class FollowUpScreen extends StatefulWidget {
  final String patientId;

  const FollowUpScreen({super.key, required this.patientId});

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  _FollowUpType _type = _FollowUpType.call;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _notesCtrl = TextEditingController();
  final _smsCtrl = TextEditingController();
  bool _saving = false;

  // Fake patient data
  static const _patientName = 'Sipho Dlamini';
  static const _clinicCode = 'MBM-0041';
  static const _riskLevel = 'High Risk';

  @override
  void initState() {
    super.initState();
    final nwd = _nextWorkingDay();
    _selectedDate = nwd;
    _selectedTime = TimeOfDay(hour: nwd.hour, minute: nwd.minute);
    _updateSmsText();
    _notesCtrl.addListener(_updateSmsText);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _smsCtrl.dispose();
    super.dispose();
  }

  void _updateSmsText() {
    if (_type == _FollowUpType.sms) {
      final dateStr = _fmtDate(_selectedDate);
      final timeStr = _fmtTime(_selectedTime);
      _smsCtrl.text =
      'Hi $_patientName, your healthcare worker has scheduled a follow-up '
          'on $dateStr at $timeStr. '
          'Please ensure you are available. '
          'For questions, contact your clinic. '
          '– MedAdhere';
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: kP3,
            onPrimary: Colors.white,
            surface: kCard,
            onSurface: kP2,
          ),
          dialogBackgroundColor: kCard,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updateSmsText();
      });
    }
  }

  // ── Time picker ───────────────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
        _selectedTime = picked;
        _updateSmsText();
      });
    }
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _saving = false);
    _showSuccessSheet();
  }

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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 34, color: kSuccess),
            ),
            const SizedBox(height: 14),
            const Text(
              'Follow-up Scheduled',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: kP2),
            ),
            const SizedBox(height: 6),
            Text(
              'Saved locally and will sync when online.',
              style:
              TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            // Summary pill row
            _successPill(
              icon: _type.icon,
              label: _type.label,
              color: _type.color,
            ),
            const SizedBox(height: 10),
            _successPill(
              icon: Icons.calendar_today_rounded,
              label: '${_fmtDate(_selectedDate)} at ${_fmtTime(_selectedTime)}',
              color: kP3,
            ),
            if (_type == _FollowUpType.sms) ...[
              const SizedBox(height: 10),
              _successPill(
                icon: Icons.wifi_off_rounded,
                label: 'SMS queued — will send when online',
                color: kWarning,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Patient'),
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

  Widget _successPill(
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
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientBanner(),
                  const SizedBox(height: 20),
                  _buildTypeSelector(),
                  const SizedBox(height: 16),
                  _buildDateTimeCard(),
                  const SizedBox(height: 16),
                  _buildNotesCard(),
                  if (_type == _FollowUpType.sms) ...[
                    const SizedBox(height: 16),
                    _buildSmsPreview(),
                  ],
                  const SizedBox(height: 16),
                  _buildOfflineBanner(),
                ],
              ),
            ),
          ),
          _buildSaveBar(),
        ],
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
      'Schedule Follow-up',
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

  // ── Patient banner ────────────────────────────────────────────────────────
  Widget _buildPatientBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kDanger.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3))
      ],
    ),
    child: Row(
      children: [
        // Avatar
        Container(
          width: 44,
          height: 44,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 2),
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
        // Risk badge
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kDanger.withOpacity(0.09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kDanger.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 12, color: kDanger),
              const SizedBox(width: 4),
              Text(
                _riskLevel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: kDanger,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Follow-up type selector ───────────────────────────────────────────────
  Widget _buildTypeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Follow-up Type'),
      const SizedBox(height: 10),
      Row(
        children: _FollowUpType.values.map((t) {
          final selected = _type == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type = t;
                _updateSmsText();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                    right: t != _FollowUpType.sms ? 10 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? t.color : kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? t.color
                        : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                        color: t.color.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                      : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.icon,
                      size: 22,
                      color:
                      selected ? Colors.white : Colors.grey.shade500,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );

  // ── Date & time ───────────────────────────────────────────────────────────
  Widget _buildDateTimeCard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Date & Time'),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            // Date row
            _pickerRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: _fmtDate(_selectedDate),
              isFirst: true,
              onTap: _pickDate,
            ),
            Divider(
                height: 1,
                thickness: 0.8,
                indent: 16,
                endIndent: 16,
                color: Colors.grey.shade100),
            // Time row
            _pickerRow(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: _fmtTime(_selectedTime),
              isFirst: false,
              onTap: _pickTime,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _pickerRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isFirst,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kP3.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: kP3),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      );

  // ── Notes ─────────────────────────────────────────────────────────────────
  Widget _buildNotesCard() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Notes'),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: TextField(
          controller: _notesCtrl,
          maxLines: 4,
          minLines: 4,
          style: const TextStyle(fontSize: 13, height: 1.5),
          decoration: InputDecoration(
            hintText:
            'E.g. Patient reported difficulty remembering evening dose.',
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                height: 1.5),
            filled: true,
            fillColor: kCard,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: kP4, width: 1.5),
            ),
          ),
        ),
      ),
    ],
  );

  // ── SMS preview ───────────────────────────────────────────────────────────
  Widget _buildSmsPreview() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _sectionLabel('SMS Preview'),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kP4.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_rounded, size: 10, color: kP4),
                const SizedBox(width: 4),
                Text('Editable',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kP4)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: kP4.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SMS header bar
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: kP4.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
                border: Border(
                    bottom: BorderSide(
                        color: kP4.withOpacity(0.15))),
              ),
              child: Row(
                children: [
                  Icon(Icons.sms_rounded, size: 14, color: kP4),
                  const SizedBox(width: 7),
                  Text(
                    'To: $_patientName',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kP4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_smsCtrl.text.length} chars',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            // Editable message body
            TextField(
              controller: _smsCtrl,
              maxLines: 5,
              minLines: 3,
              style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Colors.grey.shade700),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14)),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14)),
                  borderSide:
                  BorderSide(color: kP4, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              'SMS will be queued and sent automatically when a network connection is available.',
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                  height: 1.4),
            ),
          ),
        ],
      ),
    ],
  );

  // ── Offline banner ────────────────────────────────────────────────────────
  Widget _buildOfflineBanner() => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: kWarning.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kWarning.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(Icons.cloud_sync_rounded, size: 16, color: kWarning),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Follow-up saved locally. Will sync to backend and send SMS when online.',
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
            offset: const Offset(0, -3))
      ],
    ),
    child: ElevatedButton(
      onPressed: _saving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: kP4,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kP4.withOpacity(0.6),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800),
        elevation: 0,
      ),
      child: _saving
          ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor:
            AlwaysStoppedAnimation(Colors.white)),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_type.icon, size: 18),
          const SizedBox(width: 8),
          const Text('Schedule Follow-up'),
        ],
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: kP2,
    ),
  );
}