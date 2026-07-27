import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// TopBar global reutilizável — usada nas 3 abas principais (Feed, Pesquisa, Perfil).
/// Exibe o ícone de menu (3 risquinhos) à esquerda e o título centralizado.
class AppTopBar extends StatelessWidget {
  final String title;

  const AppTopBar({super.key, this.title = 'Papacapim'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 12,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.beige, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
