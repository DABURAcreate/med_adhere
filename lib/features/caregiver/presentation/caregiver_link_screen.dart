import 'package:flutter/material.dart';

class CaregiverLinkScreen extends StatelessWidget {
  const CaregiverLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Caregiver')),
      body: const Center(
        child: Text(
          'Caregiver Link Screen\n(Ghost placeholder)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
