import 'package:flutter/material.dart';

class AdherenceCalendarScreen extends StatelessWidget {
  const AdherenceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adherence Calendar')),
      body: const Center(
        child: Text(
          'Adherence Calendar Screen\n(Ghost placeholder)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
