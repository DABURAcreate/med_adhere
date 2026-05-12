import 'package:flutter/material.dart';
import '../widgets/scaffold.dart';

class RiskLevelScreen extends StatelessWidget {
  const RiskLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Risk Level',
      currentIndex: 3,

      // ✅ Whole body scrollable
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🏷️ Risk Level Title
              const Text(
                'Risk Level',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // 🛡️ Shield Image
              Image.asset(
                'assets/images/tick.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 16),

              // 🟢 Risk Label
              const Text(
                'Low Risk',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 24),

              // 📋 Why this rating card
              Container(
                width: 336,
                height: 134,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7E95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Card Title
                    Center(
                      child: Text(
                        'Why this rating?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Bullet point
                    Text(
                      '• You were not missing a dose',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 📋 What should I do card
              Container(
                width: 336,
                height: 134,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A7E95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Card Title
                    Center(
                      child: Text(
                        'What should I do?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    // Bullet point
                    Text(
                      '• Keep taking your meds as scheduled',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}