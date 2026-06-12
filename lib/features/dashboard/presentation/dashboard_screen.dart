import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../providers/session_provider.dart';
import '../data/dashboard_repository.dart';
import '../domain/clinic_stats_model.dart';
import '../widgets/bottom_nav_bar.dart';

// ── Colour palette ──────────────────────────────────────────────────────────
const kBlue1 = Color(0xFF1AA4EE);
const kBlue2 = Color(0xFF1A7E95);
const kBlue3 = Color(0xFF1462A1);
const kBlue4 = Color(0xFF165B9E);
const kBg    = Color(0xFFF0F5FB);
const kCard  = Color(0xFFFFFFFF);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  bool _syncing = false;
  String _lastSynced = '—';

  // Streams initialised once so StreamBuilder doesn't re-subscribe on rebuild.
  late final Stream<ClinicStats> _statsStream;
  late final Stream<List<Patient>> _highRiskStream;

  // Trend loaded once from Firestore-backed aggregation.
  List<int> _trend = [];
  bool _trendLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_trendLoaded) {
      // Use a flag guard so didChangeDependencies doesn't re-run every rebuild.
      _initStreams();
    }
  }

  void _initStreams() {
    final repo = context.read<DashboardRepository>();
    final clinicName = context.read<SessionProvider>().workerClinicName;
    _statsStream = repo.watchClinicStats(clinicName: clinicName);
    _highRiskStream = repo.watchHighRiskPatients(clinicName: clinicName);
    _loadTrend(repo, clinicName: clinicName);
    _trendLoaded = true; // guard
  }

  Future<void> _loadTrend(DashboardRepository repo, {String? clinicName}) async {
    final data = await repo.getAdherenceTrendPct(clinicName: clinicName);
    if (mounted) setState(() => _trend = data);
  }

  Future<void> _logout() async {
    await AuthService.clearSession();
    if (!mounted) return;
    context.read<SessionProvider>().signOut();
    context.go(AppRoutes.login);
  }

  void _triggerSync() {
    setState(() => _syncing = true);
    context.read<SyncService>().sync().then((_) {
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _lastSynced = TimeOfDay.now().format(context);
      });
      // Reload trend data after sync brings in fresh Firestore data.
      final clinicName = context.read<SessionProvider>().workerClinicName;
      _loadTrend(context.read<DashboardRepository>(), clinicName: clinicName);
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatLastSeen(DateTime? dt, AppLocalizations l10n) {
    if (dt == null) return l10n.never;
    final diff = DateTime.now().difference(dt).inDays;
    if (diff == 0) return l10n.today;
    if (diff == 1) return l10n.yesterday;
    return l10n.daysAgo(diff);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;

    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: isTablet ? _tabletLayout() : _phoneLayout(),
      bottomNavigationBar:
          isTablet ? null : const MedAdhereBottomNav(currentIndex: 0),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final l10n = AppLocalizations.of(context)!;
    final session = context.read<SessionProvider>();
    final firstName = (session.workerFullName ?? 'Worker').split(' ').first;
    final clinicLabel = session.workerClinicName ?? 'Clinic Dashboard';

    return AppBar(
    backgroundColor: Colors.white,
    centerTitle: false,
    toolbarHeight: 90,
    automaticallyImplyLeading: false,
    elevation: 2,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/LOGO.png',
              fit: BoxFit.contain,
              height: 44,
              errorBuilder: (_, _, _) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kBlue3, kBlue2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_services_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              l10n.greeting(firstName),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                text: 'Med',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kBlue4,
                  height: 1.1,
                ),
                children: [
                  TextSpan(
                    text: 'Adhere',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: kBlue2,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              clinicLabel,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: _triggerSync,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _syncing
                      ? kBlue1.withValues(alpha: 0.12)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _syncing ? kBlue1 : Colors.green.shade400,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _syncing
                        ? const SizedBox(
                            width: 9,
                            height: 9,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: kBlue1))
                        : Icon(Icons.check_circle_outline,
                            size: 10, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _syncing ? l10n.syncing : l10n.syncedAt(_lastSynced),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color:
                            _syncing ? kBlue1 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') _logout();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text(l10n.logout),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 18,
            backgroundColor: kBlue4,
            child: Text(
              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'W',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ),
      ],
    ),
  );
  }

  // ── PHONE LAYOUT ─────────────────────────────────────────────────────────
  Widget _phoneLayout() => SafeArea(
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        const SizedBox(height: 16),
        _statsRow(),
        const SizedBox(height: 24),
        _actionRequired(),
        const SizedBox(height: 24),
        _adherenceTrend(),
        const SizedBox(height: 16),
      ],
    ),
  );

  // ── TABLET LAYOUT ────────────────────────────────────────────────────────
  Widget _tabletLayout() => Row(
    children: [
      _sideNav(),
      Expanded(
        child: SafeArea(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            children: [
              const SizedBox(height: 20),
              _statsRowTablet(),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _actionRequired()),
                  const SizedBox(width: 24),
                  Expanded(child: _adherenceTrend()),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ],
  );

  // ── STATS ROW (phone) ────────────────────────────────────────────────────
  Widget _statsRow() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<ClinicStats>(
      stream: _statsStream,
      builder: (context, snap) {
        final stats = snap.data ?? ClinicStats.empty;
        return Row(
          children: [
            Expanded(
              child: _statCard(
                '${stats.totalPatients}',
                l10n.totalPatients,
                kBlue4,
                Colors.white,
                icon: Icons.people_alt_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                '${stats.highRisk}',
                l10n.highRisk,
                const Color(0xFFB91C1C),
                Colors.white,
                icon: Icons.warning_rounded,
                valueColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                stats.adherencePercent,
                l10n.avgAdherence,
                kBlue2,
                Colors.white,
                icon: Icons.trending_up_rounded,
                valueColor: const Color(0xFF86EFAC),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── STATS ROW (tablet) ───────────────────────────────────────────────────
  Widget _statsRowTablet() {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<ClinicStats>(
      stream: _statsStream,
      builder: (context, snap) {
        final stats = snap.data ?? ClinicStats.empty;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
                width: 200,
                child: _statCard('${stats.totalPatients}', l10n.totalPatients,
                    kBlue4, Colors.white,
                    icon: Icons.people_alt_rounded)),
            SizedBox(
                width: 200,
                child: _statCard('${stats.highRisk}', l10n.highRisk,
                    const Color(0xFFB91C1C), Colors.white,
                    icon: Icons.warning_rounded, valueColor: Colors.white)),
            SizedBox(
                width: 200,
                child: _statCard(stats.adherencePercent, l10n.avgAdherence,
                    kBlue2, Colors.white,
                    icon: Icons.trending_up_rounded,
                    valueColor: const Color(0xFF86EFAC))),
          ],
        );
      },
    );
  }

  Widget _statCard(
    String value,
    String label,
    Color bg,
    Color labelColor, {
    Color? valueColor,
    required IconData icon,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: valueColor ?? Colors.white)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: labelColor.withValues(alpha: 0.85))),
          ],
        ),
      );

  // ── ACTION REQUIRED ──────────────────────────────────────────────────────
  Widget _actionRequired() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.actionRequired,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E))),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go(AppRoutes.patientList),
              child: Text(l10n.viewAll,
                  style: TextStyle(
                      fontSize: 13,
                      color: kBlue3,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Patient>>(
          stream: _highRiskStream,
          builder: (context, snap) {
            final patients = snap.data ?? [];
            if (patients.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Text(
                  l10n.noHighRiskPatients,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontStyle: FontStyle.italic),
                ),
              );
            }
            return Column(
              children: patients.take(5).map(_patientCard).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _patientCard(Patient p) {
    final l10n = AppLocalizations.of(context)!;
    final score = p.riskScore ?? 0;
    final riskColor = score >= 80
        ? Colors.red.shade600
        : score >= 70
            ? Colors.orange.shade700
            : Colors.yellow.shade800;
    final adherence = p.adherencePercentage30Days ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: riskColor.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kBlue4.withValues(alpha: 0.12),
            child: Text(
              p.fullName.split(' ').map((e) => e[0]).take(2).join(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: kBlue4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.fullName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(
                  l10n.lastSeen(_formatLastSeen(p.lastAdherenceLogAt, l10n)),
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: riskColor.withValues(alpha: 0.4)),
            ),
            child: Text(l10n.riskBadge(score.toString()),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: riskColor)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${adherence.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E))),
              Text(l10n.adherence,
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  // ── ADHERENCE TREND CHART ─────────────────────────────────────────────────
  Widget _adherenceTrend() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kBlue1, kBlue3],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.clinicAdherenceTrend,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E))),
              const Spacer(),
              Text(l10n.thirtyDays,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.clinicWideAdherence,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _trend.isEmpty
                ? Center(
                    child: Text(l10n.loadingTrend,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12)))
                : CustomPaint(
                    painter: _TrendPainter(_trend),
                    size: Size.infinite,
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Day 1', 'Day 10', 'Day 20', l10n.today]
                .map((label) => Text(label,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade400)))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── SIDEBAR NAV (tablet) ──────────────────────────────────────────────────
  Widget _sideNav() => Container(
    width: 220,
    color: kBlue4,
    child: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('MedAdhere',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 36),
          ..._navItems(),
        ],
      ),
    ),
  );

  List<Widget> _navItems() {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.dashboard_rounded, l10n.navDashboard),
      (Icons.people_alt_rounded, l10n.navPatients),
      (Icons.bar_chart_rounded, l10n.navReports),
      (Icons.settings_rounded, l10n.navSettings),
    ];
    return List.generate(items.length, (i) {
      final active = i == _navIndex;
      return GestureDetector(
        onTap: () => setState(() => _navIndex = i),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(items[i].$1,
                  color: active ? Colors.white : Colors.white54,
                  size: 20),
              const SizedBox(width: 12),
              Text(items[i].$2,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.white54,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w400,
                      fontSize: 14)),
            ],
          ),
        ),
      );
    });
  }
}

// ── Line chart painter ────────────────────────────────────────────────────────
class _TrendPainter extends CustomPainter {
  final List<int> data;
  const _TrendPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.reduce(min).toDouble();
    final maxVal = data.reduce(max).toDouble();
    final range  = (maxVal - minVal).clamp(1, double.infinity);

    double xOf(int i) => i / (data.length - 1) * size.width;
    double yOf(int v) =>
        size.height -
        ((v - minVal) / range) * size.height * 0.85 -
        size.height * 0.075;

    final fillPath = Path();
    fillPath.moveTo(xOf(0), yOf(data[0]));
    for (int i = 1; i < data.length; i++) {
      final x0 = xOf(i - 1), y0 = yOf(data[i - 1]);
      final x1 = xOf(i),     y1 = yOf(data[i]);
      final cpx = (x0 + x1) / 2;
      fillPath.cubicTo(cpx, y0, cpx, y1, x1, y1);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [kBlue1.withValues(alpha: 0.28), kBlue1.withValues(alpha: 0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path();
    linePath.moveTo(xOf(0), yOf(data[0]));
    for (int i = 1; i < data.length; i++) {
      final x0 = xOf(i - 1), y0 = yOf(data[i - 1]);
      final x1 = xOf(i),     y1 = yOf(data[i]);
      final cpx = (x0 + x1) / 2;
      linePath.cubicTo(cpx, y0, cpx, y1, x1, y1);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = kBlue1
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(Offset(xOf(data.length - 1), yOf(data.last)), 5,
        Paint()..color = kBlue1);
    canvas.drawCircle(Offset(xOf(data.length - 1), yOf(data.last)), 3,
        Paint()..color = Colors.white);

    final refPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (final pct in [0.25, 0.5, 0.75]) {
      final y = size.height * pct;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), refPaint);
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final val in [60, 70, 80]) {
      final y = yOf(val);
      tp.text = TextSpan(
        text: '$val%',
        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) => old.data != data;
}
