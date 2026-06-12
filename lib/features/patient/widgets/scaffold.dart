import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mzansi_meds_reminder/l10n/app_localizations.dart';

import '../../../app/router.dart';
import '../../../core/security/auth_service.dart';
import '../../../providers/session_provider.dart';

class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
  });

  Future<void> _logout(BuildContext context) async {
    await AuthService.clearSession();
    if (!context.mounted) return;
    context.read<SessionProvider>().signOut();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/LOGO.png",
              fit: BoxFit.contain,
              height: 70,
            ),
            const SizedBox(width: 8),
            const Text.rich(
              TextSpan(
                text: 'Med',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165B9E),
                ),
                children: [
                  TextSpan(
                    text: 'Adhere',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A7E95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.logoutTooltip,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF165B9E)),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: body,

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1DA6B3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => context.go('/patient/home'),
              child: _buildNavItem(
                imagePath: "assets/images/HOME_TAB.png",
                label: l10n.navHome,
                index: 0,
              ),
            ),
            InkWell(
              onTap: () => context.go('/patient/home/calendar'),
              child: _buildNavItem(
                imagePath: "assets/images/PROGRESS_TAB.png",
                label: l10n.navProgress,
                index: 1,
              ),
            ),
            InkWell(
              onTap: () => context.go('/patient/home/medication/0'),
              child: _buildNavItem(
                imagePath: "assets/images/MEDICATION_TAB.png",
                label: l10n.navMeds,
                index: 2,
              ),
            ),
            InkWell(
              onTap: () => context.go('/patient/home/risk'),
              child: _buildNavItem(
                imagePath: "assets/images/PROFILE_TAB.png",
                label: l10n.navRiskLevel,
                index: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String imagePath,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            imagePath,
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}