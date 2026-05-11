import 'package:flutter/material.dart';

class FollowUpScreen extends StatelessWidget {
  final String patientId;

  const FollowUpScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow Up')),
      body: Center(
        child: Text(
          'Follow Up Screen\n(Ghost placeholder)\nPatient ID: $patientId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
