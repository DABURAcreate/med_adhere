import 'package:flutter/material.dart';

class MedicationScheduleScreen extends StatelessWidget {
  final String patientId;

  const MedicationScheduleScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication Schedule')),
      body: Center(
        child: Text(
          'Medication Schedule Screen\n(Ghost placeholder)\nPatient ID: $patientId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
