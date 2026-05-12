import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

class RegistrationCodeScreen extends StatelessWidget {
  const RegistrationCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9E9E9),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const MedAdhereHeader(),

              const SizedBox(height: 56),

              const Text(
                'Enter Registration Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 56),

              PinInputRow(
                length: 5,
                boxSize: 50,
                boxSpacing: 14,
                onCompleted: (code) {
                  debugPrint('Entered code: $code');
                },
              ),

              const SizedBox(height: 53),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ContinueButton(
                    onPressed: () {
                      context.go('/patient/home/calendar');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}