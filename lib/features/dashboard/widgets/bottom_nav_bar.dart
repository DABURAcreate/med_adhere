import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';

class MedAdhereBottomNav extends StatelessWidget {
  final int currentIndex;

  const MedAdhereBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1DA6B3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.dashboard),
            child: _buildNavItem(
              icon: Icons.dashboard_rounded,
              label: 'HOME',
              index: 0,
            ),
          ),

          GestureDetector(
            onTap: () => context.go(AppRoutes.patientList),
            child: _buildNavItem(
              icon: Icons.people_alt_rounded,
              label: 'PATIENTS',
              index: 1,
            ),
          ),

          GestureDetector(
            onTap: () => context.go(AppRoutes.reports),
            child: _buildNavItem(
              icon: Icons.bar_chart_rounded,
              label: 'REPORTS',
              index: 2,
            ),
          ),

          GestureDetector(
            onTap: () => context.go(AppRoutes.registerPatient),
            child: _buildNavItem(
              icon: Icons.person_add_alt_1_rounded,
              label: 'REGISTER',
              index: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3DBDFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 24,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}