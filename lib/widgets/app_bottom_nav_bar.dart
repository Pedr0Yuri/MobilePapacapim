import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// Componente da barra de navegação inferior.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navIcon(Icons.home_rounded, 0),
              _navIcon(Icons.search_rounded, 1),
              _navIcon(Icons.person_outline_rounded, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: isActive ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Icon(
            icon,
            size: 26,
            color: isActive ? AppColors.accent : AppColors.beige,
          ),
        ),
      ),
    );
  }
}
