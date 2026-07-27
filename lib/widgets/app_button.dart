import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// Variantes do botão.
enum AppButtonVariant { filled, text, outlined, danger }

// Componente global de Botão para reusabilidade.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({super.key, required this.label, required this.onPressed, this.variant = AppButtonVariant.filled, this.icon});

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.filled:
        return SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cta, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0, textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            child: Text(label),
          ),
        );
      case AppButtonVariant.text:
        return TextButton(onPressed: onPressed, style: TextButton.styleFrom(foregroundColor: AppColors.cta, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), child: Text(label));
      case AppButtonVariant.outlined:
        return SizedBox(
          width: double.infinity, height: 52,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
            label: Text(label),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.accent, side: const BorderSide(color: AppColors.accent, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        );
      case AppButtonVariant.danger:
        return SizedBox(
          width: double.infinity, height: 52,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon ?? Icons.delete_outline, size: 20),
            label: Text(label),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        );
    }
  }
}
