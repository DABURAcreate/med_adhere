import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
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
              onTap: () {context.go('/patient/home');},
              child: _buildNavItem(
                imagePath: "assets/images/HOME_TAB.png",
                label: "HOME",
                index: 0,
              ),
            ),

            InkWell(
              onTap: () {context.go('/patient/home/calendar');},
              child: _buildNavItem(
                imagePath: "assets/images/PROGRESS_TAB.png",
                label: "PROGRESS",
                index: 1,
              ),
            ),

            InkWell(
              onTap: () {context.go('/patient/home/medication/:id');},
              child: _buildNavItem(
                imagePath: "assets/images/MEDICATION_TAB.png",
                label: "MEDS",
                index: 2,
              ),
            ),

            InkWell(
              onTap: () {context.go('/patient/home/risk');},
              child: _buildNavItem(
                imagePath: "assets/images/PROFILE_TAB.png",
                label: "RISK LEVEL",
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
    bool isSelected = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3DBDFF)
                : const Color(0xFF3DBDFF),
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}