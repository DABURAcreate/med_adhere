import 'package:flutter/material.dart';

/// Shared header for auth screens (language, login, PIN setup,
/// registration code). Displays the MedAdhere logo and the
/// two-tone "MedAdhere" wordmark.
///
/// Usage:
/// ```dart
/// Column(
///   children: const [
///     MedAdhereHeader(),
///     // ... rest of your screen
///   ],
/// )
/// ```
class MedAdhereHeader extends StatelessWidget {
  /// Height of the logo image. Defaults to 80.
  final double logoHeight;

  /// Font size of the "MedAdhere" wordmark. Defaults to 32.
  final double titleSize;

  /// Top padding above the logo. Defaults to 40.
  final double topPadding;

  /// Spacing between the logo and the wordmark. Defaults to 24.
  final double spacingBetween;

  const MedAdhereHeader({
    super.key,
    this.logoHeight = 80,
    this.titleSize = 32,
    this.topPadding = 40,
    this.spacingBetween = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Image.asset(
            'assets/images/LOGO.png',
            height: logoHeight,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 5),
        // "MedAdhere" wordmark (two colours)
        Text.rich(
          TextSpan(
            text: 'Med',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF165B9E),
            ),
            children: [
              TextSpan(
                text: 'Adhere',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A7E95),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}