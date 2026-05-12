import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/scaffold.dart';
import '../widgets/dose_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double progress = 0.6; // 60% progress (temporary)

    return MainScaffold(
      title: "Today's Doses",
      currentIndex: 0,
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Greeting
              const Text(
                "HI! Prince 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              // 📅 Date
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // 📊 Progress row (label + bar)
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

                  // 📈 Progress bar
                  Expanded(
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF000000),
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

              // 📜 Scrollable dose list
              Expanded(
                child: ListView(
                  children: const [
                    DoseCard(
                      medicationName: 'Metformin',
                      imageName: 'Medicine',
                    ),
                    SizedBox(height: 16),
                    DoseCard(
                      medicationName: 'Aspirin',
                      imageName: 'Medicine',
                    ),
                   
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}