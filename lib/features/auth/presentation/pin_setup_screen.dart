import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../widgets/pin_input_row.dart';

class PinSetupScreen extends StatelessWidget {
  const PinSetupScreen({super.key});

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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create PIN:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              PinInputRow(
                length: 4,
                isObscured: true,
                // boxSize and boxSpacing use defaults (70, 15)
                onCompleted: (pin) {
                  // TODO: validate pin against database
                  debugPrint('PIN entered: $pin');
                },
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirm PIN:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              PinInputRow(
                length: 4,
                isObscured: true,
                // boxSize and boxSpacing use defaults (70, 15)
                onCompleted: (pin) {
                  // TODO: validate pin against database
                  debugPrint('PIN entered: $pin');
                },
              ),

              const SizedBox(height: 33),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ContinueButton(
                    onPressed: () {
                      context.go('/patient/home');
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