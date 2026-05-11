import 'package:flutter/material.dart';

class RiskLevelScreen extends StatelessWidget {
  const RiskLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Risk Level')),
      body: const Center(
        child: Text(
          'Risk Level Screen\n(Ghost placeholder)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
