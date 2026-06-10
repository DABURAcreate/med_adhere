import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/app_database.dart';
import '../../../providers/session_provider.dart';
import '../data/patient_repository.dart';
import '../widgets/scaffold.dart';

/// Shows all active medications for the current patient.
/// The [medicationId] URL parameter is ignored — this screen serves as the
/// Meds tab and lists every medication assigned to the logged-in patient.
class MedicationDetailScreen extends StatelessWidget {
  final String medicationId;

  const MedicationDetailScreen({
    super.key,
    required this.medicationId,
  });

  @override
  Widget build(BuildContext context) {
    final patientId = context.watch<SessionProvider>().currentPatientId;

    if (patientId == null) {
      return const MainScaffold(
        title: 'Medications',
        currentIndex: 2,
        body: Center(child: Text('No patient session found.')),
      );
    }

    final patientRepo = context.read<PatientRepository>();

    return MainScaffold(
      title: 'Medications',
      currentIndex: 2,
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Medications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Medication>>(
                  stream: patientRepo.watchMedications(patientId),
                  builder: (context, medSnap) {
                    if (medSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final meds = medSnap.data ?? [];
                    final activeMeds =
                        meds.where((m) => m.isActive).toList();

                    if (activeMeds.isEmpty) {
                      return const Center(
                        child: Text(
                          'No medications assigned yet.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      );
                    }

                    return StreamBuilder<List<Reminder>>(
                      stream: patientRepo.watchRemindersForPatient(patientId),
                      builder: (context, remSnap) {
                        final allReminders = remSnap.data ?? [];
                        final remindersByMed = <int, List<Reminder>>{};
                        for (final r in allReminders) {
                          if (r.isActive) {
                            remindersByMed
                                .putIfAbsent(r.medicationId, () => [])
                                .add(r);
                          }
                        }

                        return ListView.separated(
                          itemCount: activeMeds.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final med = activeMeds[index];
                            final times = remindersByMed[med.id]
                                    ?.map((r) => r.scheduledTime)
                                    .toList() ??
                                [];
                            return MedicationCard(
                              number: index + 1,
                              name: med.name,
                              dosage: med.dosage,
                              instructions: med.instructions,
                              doseTimes: times,
                              isActive: med.isActive,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Medication card
// =============================================================================

class MedicationCard extends StatelessWidget {
  final int number;
  final String name;
  final String dosage;
  final String? instructions;
  final List<String> doseTimes;
  final bool isActive;

  const MedicationCard({
    super.key,
    required this.number,
    required this.name,
    required this.dosage,
    this.instructions,
    required this.doseTimes,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A7E95), Color(0xFF165B9E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            '$number. $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Medication image
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/MEDICINE.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Dosage
          Text(
            'Dosage: $dosage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (!isActive) ...[
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'INACTIVE',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Schedule section
          const Text(
            'Your Schedule:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5F6E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: doseTimes.isEmpty
                ? const Text(
                    'No scheduled times yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < doseTimes.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _ScheduleRow(
                          time: doseTimes[i],
                          dose: dosage,
                        ),
                      ],
                    ],
                  ),
          ),

          if (instructions != null && instructions!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'How to Take:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F5F6E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                instructions!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String time;
  final String dose;

  const _ScheduleRow({required this.time, required this.dose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Color(0xFF7BF0A0),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          ' - ',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          dose,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
