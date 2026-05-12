import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';

void main() {
  runApp(const MedAdhereApp());
}

class MedAdhereApp extends StatelessWidget {
  const MedAdhereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LanguageScreen(),
    );
  }
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  // Helper to build a language option box
  Widget _buildLanguageOption({
    required String language,
    required String value,
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
      },
      // Wrap in a widget that doesn’t clip
      child: Container(
        clipBehavior: Clip.none, // allows shadow to paint outside
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 39, 133, 124),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8), // stronger opacity
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 1, // makes shadow a bit larger
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                language,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              // Logo
              const MedAdhereHeader(),
              const SizedBox(height: 40),

              // Language card (transparent background)
              Card(
                clipBehavior: Clip.none,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // so Align works correctly
                    children: [
                      // Centred "Language:" title
                      const Text(
                        'Language:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Language options
                      _buildLanguageOption(
                        language: 'English',
                        value: 'en',
                        imagePath: 'assets/images/english.png',
                      ),
                      const SizedBox(height: 19),
                      _buildLanguageOption(
                        language: 'isiZulu',
                        value: 'zu',
                        imagePath: 'assets/images/isiZulu.png',
                      ),
                      const SizedBox(height: 19),
                      _buildLanguageOption(
                        language: 'isiXhosa',
                        value: 'xh',
                        imagePath: 'assets/images/isiXhosa.png',
                      ),

                      const SizedBox(height: 56), // spacing before button

                      // Right‑aligned Continue button inside the card
                      Align(
                        alignment: Alignment.centerRight,
                        child: ContinueButton(
                          onPressed: _selectedLanguage == null
                              ? null
                              : () async {
                            const bool isExistingUser = false;

                            if (!mounted) return;

                            if (isExistingUser) {
                              context.go('/login');
                            } else {
                              context.go('/registration-code');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // No Spacer or button here – the button is inside the card now
            ],
          ),
        ),
      ),
    );
  }
}