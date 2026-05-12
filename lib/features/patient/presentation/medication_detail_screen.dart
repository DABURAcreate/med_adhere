import 'package:flutter/material.dart';
import '../widgets/scaffold.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String medicationId;

  const MedicationDetailScreen({
    super.key,
    required this.medicationId,
  });

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Medication Detail',
      currentIndex: 2,
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 💊 Medications label
             
                Center(
    child: const Text(
    'Medications',
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
),
          
                  
               
                
            
             

              const SizedBox(height: 16),

              // 📜 Scrollable content
              Expanded(
                child: ListView(
                  children: const [
                    MedicationCard(),
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

class MedicationCard extends StatelessWidget {
  const MedicationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 353,
      height: 546,
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
          // 💊 Title
          const Text(
            '1. Metformin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 🖼️ Medication Image
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/MEDICINE.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🏷️ For: label
          const Text(
            'For: Diabetes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // 📅 Your Schedule section
          const Text(
            'Your Schedule:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F5F6E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ScheduleRow(time: '8:00 am', dose: '1 tablet'),
                SizedBox(height: 8),
                _ScheduleRow(time: '8:00 pm', dose: '1 tablet'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 💡 How to Take section
          const Text(
            'How to Take:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
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
            child: const Text(
              'Take each tablet with water\nafter a meal. Breakfast / Supper',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
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