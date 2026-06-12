import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';

import '../domain/today_dose_item.dart';

class DoseCard extends StatelessWidget {
  final String medicationName;

  /// Scheduled dose time as HH:mm, e.g. "08:00". Shown when pending.
  final String doseTime;

  final DoseStatus status;
  final DateTime? loggedAt;

  /// The exact scheduled DateTime — used to flag overdue pending doses.
  final DateTime scheduledAt;

  final VoidCallback? onTaken;
  final VoidCallback? onMissed;

  const DoseCard({
    super.key,
    required this.medicationName,
    required this.doseTime,
    required this.status,
    required this.scheduledAt,
    this.loggedAt,
    this.onTaken,
    this.onMissed,
  });

  bool get _isOverdue =>
      status == DoseStatus.pending &&
      DateTime.now().isAfter(scheduledAt.add(const Duration(minutes: 30)));

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1A8FA3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: name + status chip ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    medicationName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: status, isOverdue: _isOverdue),
              ],
            ),

            const SizedBox(height: 8),

            // ── Dose time row ────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  status == DoseStatus.pending
                      ? AppLocalizations.of(context)!.scheduledLabel
                      : AppLocalizations.of(context)!.loggedAtLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _timeLabel(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAEFF00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Image + buttons ───────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/MEDICINE.png',
                  height: 110,
                  width: 95,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                        label: AppLocalizations.of(context)!.takenButton,
                        icon: Icons.check_circle_rounded,
                        activeColor: const Color(0xFF4CAF50),
                        isActive: status == DoseStatus.taken,
                        onPressed: status == DoseStatus.taken ? null : onTaken,
                      ),
                      _ActionButton(
                        label: AppLocalizations.of(context)!.missedButton,
                        icon: Icons.cancel_rounded,
                        activeColor: const Color(0xFFFF0000),
                        isActive: status == DoseStatus.missed,
                        onPressed:
                            status == DoseStatus.missed ? null : onMissed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeLabel() {
    if (status == DoseStatus.pending) {
      return doseTime != '--:--' ? doseTime : '—';
    }
    if (loggedAt != null) return DateFormat('hh:mm a').format(loggedAt!);
    return doseTime != '--:--' ? doseTime : '—';
  }
}

// ── Status chip ──────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final DoseStatus status;
  final bool isOverdue;

  const _StatusChip({required this.status, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, bg) = switch (status) {
      DoseStatus.taken => (l10n.taken, const Color(0xFF4CAF50)),
      DoseStatus.missed => (l10n.missed, const Color(0xFFFF0000)),
      DoseStatus.pending when isOverdue => (l10n.statusOverdue, const Color(0xFFE65100)),
      DoseStatus.pending => (l10n.pending, const Color(0xFFFFC107)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isActive;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.isActive,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? activeColor : activeColor.withAlpha(160),
          foregroundColor: Colors.white,
          disabledBackgroundColor: activeColor,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: isActive
                ? BorderSide(color: Colors.white.withAlpha(180), width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          elevation: isActive ? 0 : 2,
        ),
      ),
    );
  }
}
