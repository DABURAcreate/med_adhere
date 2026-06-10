import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/session_provider.dart';
import '../data/adherence_repository.dart';
import '../data/patient_repository.dart';
import '../domain/today_dose_item.dart';
import '../widgets/dose_card.dart';
import '../widgets/scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = context.watch<SessionProvider>().currentPatientId;

    if (patientId == null) {
      return const Scaffold(
        body: Center(child: Text('No patient session found. Please log in again.')),
      );
    }

    return MainScaffold(
      title: "Today's Doses",
      currentIndex: 0,
      body: StreamBuilder(
        stream: context.read<PatientRepository>().watchPatient(patientId),
        builder: (context, patientSnap) {
          if (patientSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final patient = patientSnap.data;
          if (patient == null) {
            return const Center(
              child: Text('Patient not found. Please log in again.'),
            );
          }

          return StreamBuilder<List<TodayDoseItem>>(
            stream: context
                .read<AdherenceRepository>()
                .watchTodayDoses(patientId),
            builder: (context, dosesSnap) {
              final doses = dosesSnap.data ?? [];

              final total = doses.length;
              final taken =
                  doses.where((d) => d.status == DoseStatus.taken).length;
              final missed =
                  doses.where((d) => d.status == DoseStatus.missed).length;
              final pending = total - taken - missed;
              final progress = total == 0 ? 0.0 : taken / total;

              return Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Greeting ──────────────────────────────────────────
                      Text(
                        'Hi, ${patient.fullName} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Progress bar ──────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Today progress:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFFA9A9A9),
                                ),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: const Color(0xFFA9A9A9),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF2ED39E),
                                  ),
                                  minHeight: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            total == 0
                                ? '—'
                                : '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ── Summary counts ────────────────────────────────────
                      if (total > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _CountBadge(
                              count: taken,
                              label: 'Taken',
                              color: const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 10),
                            _CountBadge(
                              count: missed,
                              label: 'Missed',
                              color: const Color(0xFFFF0000),
                            ),
                            const SizedBox(width: 10),
                            _CountBadge(
                              count: pending,
                              label: 'Pending',
                              color: const Color(0xFFFFC107),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // ── Dose list ─────────────────────────────────────────
                      Expanded(
                        child: doses.isEmpty
                            ? const Center(
                                child: Text(
                                  'No active medications found.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: doses.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final dose = doses[index];
                                  return DoseCard(
                                    medicationName: dose.medicationName,
                                    doseTime: dose.doseTime,
                                    status: dose.status,
                                    loggedAt: dose.loggedAt,
                                    onTaken: dose.isLocked
                                        ? null
                                        : () {
                                            context
                                                .read<AdherenceRepository>()
                                                .markDoseTaken(
                                                  patientId: patientId,
                                                  medicationId:
                                                      dose.medicationId,
                                                  scheduledAt: dose.scheduledAt,
                                                  reminderId: dose.reminderId,
                                                );
                                          },
                                    onMissed: dose.isLocked
                                        ? null
                                        : () {
                                            context
                                                .read<AdherenceRepository>()
                                                .markDoseMissed(
                                                  patientId: patientId,
                                                  medicationId:
                                                      dose.medicationId,
                                                  scheduledAt: dose.scheduledAt,
                                                  reminderId: dose.reminderId,
                                                );
                                          },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Count badge ───────────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CountBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color == const Color(0xFFFFC107) ? Colors.black54 : color,
          ),
        ),
      ],
    );
  }
}
