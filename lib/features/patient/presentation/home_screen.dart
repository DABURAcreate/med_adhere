import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/session_provider.dart';
import '../data/patient_repository.dart';
import '../widgets/scaffold.dart';
import '../widgets/dose_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = context.watch<SessionProvider>().currentPatientId;

    if (patientId == null) {
      return const Scaffold(
        body: Center(
          child: Text('No patient session found. Please log in again.'),
        ),
      );
    }

    return MainScaffold(
      title: "Today's Doses",
      currentIndex: 0,
      body: StreamBuilder(
        stream: context.read<PatientRepository>().watchPatient(patientId),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final patient = patientSnapshot.data;

          if (patient == null) {
            return const Center(
              child: Text('Patient not found. Please log in again.'),
            );
          }

          return StreamBuilder(
            stream: context
                .read<PatientRepository>()
                .watchActiveMedications(patientId),
            builder: (context, medsSnapshot) {
              final medications = medsSnapshot.data ?? [];

              final progress = medications.isEmpty ? 0.0 : 0.6;

              return Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HI! ${patient.fullName} 👋",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        DateFormat('EEEE, d MMMM yyyy')
                            .format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Today progress:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF000000),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFFA9A9A9),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
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
                        ],
                      ),

                      const SizedBox(height: 16),

                      Expanded(
                        child: medications.isEmpty
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
                          itemCount: medications.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final med = medications[index];

                            return DoseCard(
                              medicationName: med.name,
                              imageName: 'Medicine',
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