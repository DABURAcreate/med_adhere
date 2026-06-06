import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/locale_provider.dart';
import '../data/auth_repository.dart';
import '../widgets/continue_button.dart';
import '../widgets/med_adhere_header.dart';
import '../../../app/router.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;
  bool _loading = false;

  void _selectLanguage(String value) {
    setState(() => _selectedLanguage = value);
    context.read<LocaleProvider>().setLocale(Locale(value));
  }

  Future<void> _onContinue() async {
    if (_selectedLanguage == null || _loading) return;

    setState(() => _loading = true);

    context.read<LocaleProvider>().setLocale(Locale(_selectedLanguage!));

    if (!mounted) return;
    setState(() => _loading = false);

    context.go(AppRoutes.registrationCode);
  }

  Widget _buildLanguageOption({
    required String language,
    required String value,
    required String imagePath,
  }) {
    final isSelected = _selectedLanguage == value;

    return GestureDetector(
      onTap: () => _selectLanguage(value),
      child: Container(
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 25, 95, 88)
              : const Color.fromARGB(255, 39, 133, 124),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Image.asset(imagePath, height: 50, width: 50, fit: BoxFit.contain),
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
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const MedAdhereHeader(),
                const SizedBox(height: 40),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Language:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 56),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _loading
                              ? const CircularProgressIndicator()
                              : ContinueButton(
                                  onPressed: _selectedLanguage == null
                                      ? null
                                      : _onContinue,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.go(AppRoutes.login);
                            },
                            child: const Text(
                              'Healthcare worker login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 25, 95, 88),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
