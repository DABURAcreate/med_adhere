import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../../providers/session_provider.dart';
import '../../risk_assessment/domain/risk_model.dart';
import '../data/dashboard_repository.dart';
import '../widgets/bottom_nav_bar.dart';

// ── Colour palette ────────────────────────────────────────────────────────────
const kP1 = Color(0xFF6AA9CB);
const kP2 = Color(0xFF114C90);
const kP3 = Color(0xFF165B9E);
const kP4 = Color(0xFF1A7E95);
const kP5 = Color(0xFF238F9C);
const kBg = Color(0xFFF0F5FB);
const kCard = Color(0xFFFFFFFF);

// ── Local view-model: maps a DB Patient to display-friendly fields ─────────────
class _PatientVM {
  final int id;
  final String firstName;
  final String clinicCode;
  final RiskLevel risk;
  final double adherence;
  final DateTime? lastAdherenceLogAt;

  const _PatientVM({
    required this.id,
    required this.firstName,
    required this.clinicCode,
    required this.risk,
    required this.adherence,
    this.lastAdherenceLogAt,
  });

  factory _PatientVM.from(Patient p) => _PatientVM(
        id: p.id,
        firstName: p.fullName.split(' ').first,
        clinicCode: p.registrationCode,
        risk: RiskLevel.fromString(p.riskLevel),
        adherence: p.adherencePercentage30Days ?? 0.0,
        lastAdherenceLogAt: p.lastAdherenceLogAt,
      );

  String get lastLog {
    if (lastAdherenceLogAt == null) return 'Never';
    final diff = DateTime.now().difference(lastAdherenceLogAt!).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

enum _SortOption { riskLevel, name, lastActive }
enum _FilterOption { all, high, medium, low }

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchCtrl = TextEditingController();
  _FilterOption _filter = _FilterOption.all;
  _SortOption _sort = _SortOption.riskLevel;
  String _query = '';

  // Stream is kept stable so StreamBuilder doesn't re-subscribe on rebuild.
  late final Stream<List<Patient>> _patientStream;
  bool _streamInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_streamInitialized) {
      final clinicName = context.read<SessionProvider>().workerClinicName;
      _patientStream = context
          .read<DashboardRepository>()
          .watchClinicPatients(clinicName: clinicName);
      _streamInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filter + sort ───────────────────────────────────────────────────────────
  List<_PatientVM> _applyFilters(List<Patient> raw) {
    final vms = raw.map(_PatientVM.from).toList();

    final filtered = vms.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.firstName.toLowerCase().contains(_query) ||
          p.clinicCode.toLowerCase().contains(_query);
      final matchesFilter = switch (_filter) {
        _FilterOption.all    => true,
        _FilterOption.high   => p.risk == RiskLevel.high,
        _FilterOption.medium => p.risk == RiskLevel.medium,
        _FilterOption.low    => p.risk == RiskLevel.low,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    filtered.sort((a, b) => switch (_sort) {
      _SortOption.riskLevel => a.risk.index.compareTo(b.risk.index),
      _SortOption.name      => a.firstName.compareTo(b.firstName),
      _SortOption.lastActive => () {
          final aDate = a.lastAdherenceLogAt;
          final bDate = b.lastAdherenceLogAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate); // most recent first
        }(),
    });

    return filtered;
  }

  // ── Risk helpers ────────────────────────────────────────────────────────────
  Color _riskColor(RiskLevel r) => switch (r) {
    RiskLevel.high   => const Color(0xFFB91C1C),
    RiskLevel.medium => const Color(0xFFD97706),
    RiskLevel.low    => const Color(0xFF16A34A),
  };

  String _riskLabel(RiskLevel r) => switch (r) {
    RiskLevel.high   => 'High Risk',
    RiskLevel.medium => 'Med Risk',
    RiskLevel.low    => 'Low Risk',
  };

  // ── Sort menu ───────────────────────────────────────────────────────────────
  void _showSortMenu(BuildContext context) {
    final items = {
      _SortOption.riskLevel : 'Risk Level',
      _SortOption.name      : 'Name',
      _SortOption.lastActive: 'Last Active',
    };
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
            const SizedBox(height: 16),
            Text('Sort by',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kP2)),
            const SizedBox(height: 12),
            ...items.entries.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _sort == e.key
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: _sort == e.key ? kP3 : Colors.grey.shade400,
              ),
              title: Text(e.value,
                  style: TextStyle(
                      fontWeight: _sort == e.key
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color:
                          _sort == e.key ? kP2 : Colors.grey.shade700)),
              onTap: () {
                setState(() => _sort = e.key);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(context),
      bottomNavigationBar: const MedAdhereBottomNav(currentIndex: 1),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          StreamBuilder<List<Patient>>(
            stream: _patientStream,
            builder: (context, snap) {
              final patients = _applyFilters(snap.data ?? []);
              return Expanded(
                child: Column(
                  children: [
                    _buildListHeader(context, patients.length),
                    Expanded(
                      child: snap.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator())
                          : patients.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 24),
                                  itemCount: patients.length,
                                  itemBuilder: (_, i) =>
                                      _buildPatientCard(patients[i]),
                                ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: kP2,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    title: const Text(
      'Patient List',
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
    ),
    leading: null,
    automaticallyImplyLeading: false,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kP2, kP3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
    child: TextField(
      controller: _searchCtrl,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search by name or clinic code…',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(Icons.search_rounded, color: kP4, size: 20),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.grey.shade400, size: 18),
                onPressed: () => _searchCtrl.clear(),
              )
            : null,
        filled: true,
        fillColor: kBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kP4, width: 1.5),
        ),
      ),
    ),
  );

  // ── Filter chips ────────────────────────────────────────────────────────────
  Widget _buildFilterChips() => Container(
    color: Colors.white,
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('All',       _FilterOption.all,    kP3),
          const SizedBox(width: 8),
          _chip('High Risk', _FilterOption.high,   const Color(0xFFB91C1C)),
          const SizedBox(width: 8),
          _chip('Med Risk',  _FilterOption.medium, const Color(0xFFD97706)),
          const SizedBox(width: 8),
          _chip('Low Risk',  _FilterOption.low,    const Color(0xFF16A34A)),
        ],
      ),
    ),
  );

  Widget _chip(String label, _FilterOption option, Color color) {
    final active = _filter == option;
    return GestureDetector(
      onTap: () => setState(() => _filter = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // ── List header (count + sort) ───────────────────────────────────────────────
  Widget _buildListHeader(BuildContext context, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 4),
    child: Row(
      children: [
        Text(
          '$count patient${count == 1 ? '' : 's'}',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showSortMenu(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kP3.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kP3.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.sort_rounded, size: 15, color: kP3),
                const SizedBox(width: 4),
                Text(
                  switch (_sort) {
                    _SortOption.riskLevel  => 'Risk Level',
                    _SortOption.name       => 'Name',
                    _SortOption.lastActive => 'Last Active',
                  },
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: kP3),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 15, color: kP3),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  // ── Patient card ─────────────────────────────────────────────────────────────
  Widget _buildPatientCard(_PatientVM p) {
    final rc = _riskColor(p.risk);
    final adherenceColor = p.adherence >= 80
        ? const Color(0xFF16A34A)
        : p.adherence >= 60
            ? const Color(0xFFD97706)
            : const Color(0xFFB91C1C);

    return GestureDetector(
      onTap: () => context.push('/worker/patients/${p.clinicCode}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: rc.withOpacity(0.18), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Coloured left accent bar
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: rc,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: avatar + name + risk badge
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: kP1.withOpacity(0.25),
                            child: Text(
                              p.firstName[0],
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kP2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.firstName,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1A1A2E))),
                                Text(p.clinicCode,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: rc.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: rc.withOpacity(0.4)),
                            ),
                            child: Text(
                              _riskLabel(p.risk),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: rc),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      const Divider(height: 1, thickness: 0.8),
                      const SizedBox(height: 10),

                      // Bottom row: adherence bar + last log
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${p.adherence.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: adherenceColor),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('adherence (30d)',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500)),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (p.adherence / 100)
                                        .clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(
                                        adherenceColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 11,
                                  color: Colors.grey.shade400),
                              const SizedBox(height: 2),
                              Text(p.lastLog,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded,
                              color: kP4, size: 20),
                        ],
                      ),
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

  // ── Empty state ──────────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
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
            child: Icon(Icons.person_search_rounded, size: 36, color: kP4),
          ),
          const SizedBox(height: 16),
          Text('No patients found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kP2)),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or filter, or register a new patient.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade500, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.push('worker/patients');
            },
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Register New Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kP3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}
