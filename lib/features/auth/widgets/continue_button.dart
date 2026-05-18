import 'package:flutter/material.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';


class ContinueButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;

  const ContinueButton({
    super.key,
    required this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF87D7CE),
        foregroundColor: Colors.black,
        side: const BorderSide(
          color: Color(0xFF1462A1),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      child: Text(text ?? l10n.continueButton),
    );
  }
}