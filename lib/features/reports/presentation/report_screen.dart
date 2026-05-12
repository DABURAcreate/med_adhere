import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/features/reports/presentation/report_export_service.dart';

import '../../dashboard/widgets/bottom_nav_bar.dart';

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

// ── Report type ───────────────────────────────────────────────────────────────
enum _ReportType { perPatient, perClinic }

enum _ExportFormat { pdf, csv }

// ── Fake patients ─────────────────────────────────────────────────────────────
class _PatientOption {
  final String name;
  final String code;
  const _PatientOption(this.name, this.code);
  @override
  String toString() => '$name ($code)';
}

const _patients = [
  _PatientOption('Sipho Dlamini', 'MBM-0041'),
  _PatientOption('Thandi Mokoena', 'MBM-0017'),
  _PatientOption('Lungelo Khumalo', 'MBM-0093'),
  _PatientOption('Nokwanda Zulu', 'MBM-0058'),
  _PatientOption('Bongani Sithole', 'MBM-0022'),
];

// ── Fake report rows ──────────────────────────────────────────────────────────
class _ReportRow {
  final String date;
  final String subject; // patient name or medication name
  final int taken;
  final int missed;
  final double adherence;
  const _ReportRow({
    required this.date,
    required this.subject,
    required this.taken,
    required this.missed,
    required this.adherence,
  });
}

List<_ReportRow> _fakePatientRows(_PatientOption p) => [
  _ReportRow(date: '01 May', subject: 'TLD 300mg', taken: 1, missed: 0, adherence: 100),
  _ReportRow(date: '02 May', subject: 'TLD 300mg', taken: 0, missed: 1, adherence: 0),
  _ReportRow(date: '03 May', subject: 'TLD 300mg', taken: 1, missed: 0, adherence: 100),
  _ReportRow(date: '04 May', subject: 'Amlodipine', taken: 2, missed: 0, adherence: 100),
  _ReportRow(date: '05 May', subject: 'Amlodipine', taken: 1, missed: 1, adherence: 50),
  _ReportRow(date: '06 May', subject: 'TLD 300mg', taken: 0, missed: 1, adherence: 0),
  _ReportRow(date: '07 May', subject: 'TLD 300mg', taken: 1, missed: 0, adherence: 100),
];

const _fakeClinicRows = [
  _ReportRow(date: '01 May', subject: 'Sipho D.', taken: 3, missed: 0, adherence: 100),
  _ReportRow(date: '02 May', subject: 'Thandi M.', taken: 2, missed: 1, adherence: 67),
  _ReportRow(date: '03 May', subject: 'Lungelo K.', taken: 1, missed: 2, adherence: 33),
  _ReportRow(date: '04 May', subject: 'Nokwanda Z.', taken: 3, missed: 0, adherence: 100),
  _ReportRow(date: '05 May', subject: 'Bongani S.', taken: 2, missed: 1, adherence: 67),
  _ReportRow(date: '06 May', subject: 'Sipho D.', taken: 0, missed: 3, adherence: 0),
  _ReportRow(date: '07 May', subject: 'Thandi M.', taken: 3, missed: 0, adherence: 100),
];

// ── Helpers ───────────────────────────────────────────────────────────────────
String _fmtDate(DateTime d) {
  const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

Color _adherenceColor(double v) =>
    v >= 80 ? kSuccess : v >= 60 ? kWarning : kDanger;

// ── Screen ────────────────────────────────────────────────────────────────────
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  _ReportType _type = _ReportType.perPatient;
  _ExportFormat _format = _ExportFormat.pdf;
  _PatientOption? _selectedPatient;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 29));
  DateTime _endDate = DateTime.now();
  bool _isExporting = false;
  bool _isOffline = false; // toggle to demo offline warning
  List<_ReportRow>? _previewRows;
  bool _hasGenerated = false;

  void _generatePreview() {
    if (_type == _ReportType.perPatient && _selectedPatient == null) {
      _showSnack('Please select a patient first.');
      return;
    }
    setState(() {
      _hasGenerated = true;
      _previewRows = _type == _ReportType.perPatient
          ? _fakePatientRows(_selectedPatient!)
          : _fakeClinicRows;
    });
  }

  Future<void> _export() async {
    if (!_hasGenerated || _previewRows == null) {
      _generatePreview();
      return;
    }
    if (_isOffline) {
      _showOfflineDialog();
      return;
    }

    setState(() => _isExporting = true);

    await ReportExportService.instance.export(
      config: ReportConfig(
        type: _type == _ReportType.perPatient
            ? ReportType.perPatient
            : ReportType.perClinic,
        format: _format == _ExportFormat.pdf
            ? ExportFormat.pdf
            : ExportFormat.csv,
        patientName: _selectedPatient?.name,
        patientCode: _selectedPatient?.code,
        clinicName: 'Mbombela Clinic (MBM)',
        startDate: _startDate,
        endDate: _endDate,
        rows: _previewRows!
            .map((r) => ReportRow(
          date: r.date,
          subject: r.subject,
          taken: r.taken,
          missed: r.missed,
          adherence: r.adherence,
        ))
            .toList(),
      ),
      context: context,
    );

    if (mounted) setState(() => _isExporting = false);
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: kP3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );

  void _showOfflineDialog() => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Icon(Icons.wifi_off_rounded, color: kWarning, size: 20),
        const SizedBox(width: 8),
        const Text('No Connection',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kP2)),
      ]),
      content: Text(
        'Full report data requires connectivity. Please connect to a network and try again.',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kP3,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );

  void _showExportSuccess() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
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
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: kSuccess.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(
              _format == _ExportFormat.pdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.table_chart_rounded,
              size: 32, color: kSuccess,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${_format == _ExportFormat.pdf ? 'PDF' : 'CSV'} Export Ready',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: kP2),
          ),
          const SizedBox(height: 6),
          Text(
            'Your report has been generated successfully.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          _infoPill(Icons.calendar_today_rounded,
              '${_fmtDate(_startDate)} – ${_fmtDate(_endDate)}', kP3),
          const SizedBox(height: 8),
          _infoPill(
            _type == _ReportType.perPatient
                ? Icons.person_rounded
                : Icons.local_hospital_rounded,
            _type == _ReportType.perPatient
                ? _selectedPatient!.name
                : 'Mbombela Clinic (MBM)',
            kP4,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share / Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kP4,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  );

  Widget _infoPill(IconData icon, String label, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    ),
  );

  // ── Date pickers ──────────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: kP3,
            onPrimary: Colors.white,
            surface: kCard,
            onSurface: kP2,
          ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
        _hasGenerated = false;
        _previewRows = null;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_isOffline) _buildOfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeCards(),
                  const SizedBox(height: 20),
                  _buildOptionsCard(),
                  const SizedBox(height: 16),
                  _buildGenerateButton(),
                  if (_hasGenerated) ...[
                    const SizedBox(height: 20),
                    _buildPreviewSection(),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildExportBar(),
        ],
      ),
      bottomNavigationBar: const MedAdhereBottomNav(currentIndex: 2),
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
    title: const Text('Reports',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
    actions: [
      // Demo offline toggle
      IconButton(
        icon: Icon(
          _isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
          size: 20,
          color: _isOffline ? kWarning : Colors.white60,
        ),
        tooltip: 'Toggle offline (demo)',
        onPressed: () => setState(() => _isOffline = !_isOffline),
      ),
    ],
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

  // ── Offline banner ────────────────────────────────────────────────────────
  Widget _buildOfflineBanner() => Container(
    width: double.infinity,
    color: kWarning.withOpacity(0.1),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    child: Row(
      children: [
        Icon(Icons.wifi_off_rounded, size: 14, color: kWarning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'You are offline. Full report data requires connectivity.',
            style: TextStyle(
                fontSize: 11,
                color: kWarning.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                height: 1.3),
          ),
        ),
      ],
    ),
  );

  // ── Report type cards ─────────────────────────────────────────────────────
  Widget _buildTypeCards() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionLabel('Report Type'),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
              child: _typeCard(
                _ReportType.perPatient,
                icon: Icons.person_rounded,
                title: 'Per Patient',
                subtitle: 'Individual adherence\nby date range',
              )),
          const SizedBox(width: 12),
          Expanded(
              child: _typeCard(
                _ReportType.perClinic,
                icon: Icons.local_hospital_rounded,
                title: 'Per Clinic',
                subtitle: 'All patients overview\nby date range',
              )),
        ],
      ),
    ],
  );

  Widget _typeCard(_ReportType t,
      {required IconData icon,
        required String title,
        required String subtitle}) {
    final selected = _type == t;
    return GestureDetector(
      onTap: () => setState(() {
        _type = t;
        _hasGenerated = false;
        _previewRows = null;
        if (t == _ReportType.perClinic) _selectedPatient = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? kP3.withOpacity(0.04) : kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kP3 : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
                color: kP3.withOpacity(0.15),
                blurRadius: 12,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (selected ? kP3 : Colors.grey.shade400).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 22, color: selected ? kP3 : Colors.grey.shade400),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: selected ? kP2 : Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                    height: 1.4)),
            const SizedBox(height: 10),
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? kP3 : Colors.transparent,
                    border: Border.all(
                        color: selected ? kP3 : Colors.grey.shade300,
                        width: 1.5),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 6),
                Text(
                  selected ? 'Selected' : 'Tap to select',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected ? kP3 : Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Options card ──────────────────────────────────────────────────────────
  Widget _buildOptionsCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
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
        // Patient selector (per-patient only)
        if (_type == _ReportType.perPatient) ...[
          _sectionLabel('Patient'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPatient != null
                    ? kP4.withOpacity(0.4)
                    : Colors.transparent,
              ),
            ),
            child: DropdownButtonFormField<_PatientOption>(
              value: _selectedPatient,
              decoration: InputDecoration(
                prefixIcon:
                Icon(Icons.person_search_rounded, color: kP4, size: 20),
                filled: true,
                fillColor: kBg,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 13, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kP4, width: 1.5),
                ),
                hintText: 'Select a patient…',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: kP4, size: 22),
              dropdownColor: kCard,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E)),
              items: _patients
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.toString()),
              ))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedPatient = v;
                _hasGenerated = false;
                _previewRows = null;
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 16),
        ],

        // Clinic label (per-clinic)
        if (_type == _ReportType.perClinic) ...[
          _sectionLabel('Clinic'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.local_hospital_rounded,
                    color: kP4, size: 18),
                const SizedBox(width: 10),
                const Text('Mbombela Clinic (MBM)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: kSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Auto',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: kSuccess)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.8),
          const SizedBox(height: 16),
        ],

        // Date range
        _sectionLabel('Date Range'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDateRange,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded,
                    color: kP4, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_fmtDate(_startDate)} → ${_fmtDate(_endDate)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E)),
                      ),
                      Text(
                        '${_endDate.difference(_startDate).inDays + 1} days',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit_rounded,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 0.8),
        const SizedBox(height: 16),

        // Format selector
        _sectionLabel('Export Format'),
        const SizedBox(height: 10),
        Row(
          children: [
            _formatChip(_ExportFormat.pdf,
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF',
                color: kDanger),
            const SizedBox(width: 10),
            _formatChip(_ExportFormat.csv,
                icon: Icons.table_chart_rounded,
                label: 'CSV',
                color: kSuccess),
          ],
        ),
      ],
    ),
  );

  Widget _formatChip(_ExportFormat f,
      {required IconData icon, required String label, required Color color}) {
    final sel = _format == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _format = f),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: sel ? color : Colors.grey.shade200,
                width: sel ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: sel ? color : Colors.grey.shade400),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: sel ? color : Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Generate preview button ───────────────────────────────────────────────
  Widget _buildGenerateButton() => OutlinedButton.icon(
    onPressed: _generatePreview,
    icon: const Icon(Icons.preview_rounded, size: 16),
    label: const Text('Preview Report Data'),
    style: OutlinedButton.styleFrom(
      foregroundColor: kP3,
      side: BorderSide(color: kP3.withOpacity(0.5), width: 1.5),
      minimumSize: const Size(double.infinity, 46),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle:
      const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );

  // ── Preview section ───────────────────────────────────────────────────────
  Widget _buildPreviewSection() {
    final rows = _previewRows;
    if (rows == null || rows.isEmpty) {
      return _buildEmptyState();
    }

    // Summary stats
    final totalTaken = rows.fold(0, (s, r) => s + r.taken);
    final totalMissed = rows.fold(0, (s, r) => s + r.missed);
    final avgAdherence = rows.isEmpty
        ? 0.0
        : rows.fold(0.0, (s, r) => s + r.adherence) / rows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel('Preview'),
            const Spacer(),
            Text('${rows.length} rows',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),

        // Summary stats row
        Row(
          children: [
            _statBubble('${totalTaken}', 'Taken', kSuccess),
            const SizedBox(width: 8),
            _statBubble('${totalMissed}', 'Missed', kDanger),
            const SizedBox(width: 8),
            _statBubble(
                '${avgAdherence.toStringAsFixed(0)}%', 'Avg', kP4),
          ],
        ),
        const SizedBox(height: 12),

        // Table
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 44,
                horizontalMargin: 14,
                columnSpacing: 16,
                headingRowColor: WidgetStateProperty.all(
                    kP2.withOpacity(0.05)),
                border: TableBorder(
                  horizontalInside: BorderSide(
                      color: Colors.grey.shade100, width: 1),
                ),
                columns: [
                  _col('Date'),
                  _col(_type == _ReportType.perPatient
                      ? 'Medication'
                      : 'Patient'),
                  _col('Taken'),
                  _col('Missed'),
                  _col('Adh. %'),
                ],
                rows: rows
                    .map((r) => DataRow(cells: [
                  DataCell(Text(r.date,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600))),
                  DataCell(SizedBox(
                    width: 110,
                    child: Text(r.subject,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                  )),
                  DataCell(_centeredCell(
                      '${r.taken}', kSuccess)),
                  DataCell(
                      _centeredCell('${r.missed}', kDanger)),
                  DataCell(_adherenceCell(r.adherence)),
                ]))
                    .toList(),
              ),
            ),
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
                'Preview shows a sample. Full data is included in the export.',
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
  }

  DataColumn _col(String label) => DataColumn(
    label: Text(label,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: kP2)),
  );

  Widget _centeredCell(String text, Color color) => Container(
    width: 28,
    height: 24,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Center(
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color)),
    ),
  );

  Widget _adherenceCell(double v) {
    final c = _adherenceColor(v);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 24,
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text('${v.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: c)),
          ),
        ),
      ],
    );
  }

  Widget _statBubble(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Container(
    padding: const EdgeInsets.symmetric(vertical: 32),
    alignment: Alignment.center,
    child: Column(
      children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: kP1.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.bar_chart_rounded, size: 32, color: kP4),
        ),
        const SizedBox(height: 14),
        const Text('No data for this range',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kP2)),
        const SizedBox(height: 6),
        Text(
          'No adherence records were found for the selected\npatient and date range. Try widening your selection.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.5),
        ),
      ],
    ),
  );

  // ── Export bar ────────────────────────────────────────────────────────────
  Widget _buildExportBar() => Container(
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
      onPressed: _isExporting ? null : _export,
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
      child: _isExporting
          ? const SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white)),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _format == _ExportFormat.pdf
                ? Icons.picture_as_pdf_rounded
                : Icons.table_chart_rounded,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(_hasGenerated
              ? 'Export ${_format == _ExportFormat.pdf ? "PDF" : "CSV"} Report'
              : 'Preview & Export'),
        ],
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w800, color: kP2),
  );
}