import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// Este enum define os tipos de botões que temos no app.
// Em vez de criar um arquivo para "BotaoPreenchido", outro para "BotaoDeTexto", etc,
// criamos um único componente inteligente que se adapta baseado no "Variant" que passarmos.
enum AppButtonVariant { filled, text, outlined, danger }

class AppButton extends StatelessWidget {
  final String label; // O texto que vai no botão
  final VoidCallback onPressed; // A função que roda quando o botão é clicado
  final AppButtonVariant variant; // O estilo visual do botão
  final IconData? icon; // Ícone opcional (usado nos botões outlined e danger)

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled, // Se não passarmos variante, será 'filled' por padrão.
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Aqui usamos um switch para retornar o design visual correto baseado na variante escolhida.
    // Isso centraliza o design system. Se o estilo do botão primário mudar, só mudamos aqui.
    switch (variant) {
      case AppButtonVariant.filled:
        // SizedBox com double.infinity faz o botão ocupar 100% da largura disponível.
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cta, // Cor de fundo (Laranja)
              foregroundColor: AppColors.white, // Cor do texto
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14), // Bordas arredondadas
              ),
              elevation: 0, // Sem sombra para visual flat
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(label),
          ),
        );

      case AppButtonVariant.text:
        // Um botão simples só com texto, sem fundo nem borda.
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.cta,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(label),
        );

      case AppButtonVariant.outlined:
        // Botão com borda fina (usado para ações secundárias ou alternativas).
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            // Se tivermos ícone ele desenha, senão desenha um widget vazio (SizedBox.shrink)
            icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent, width: 1.2), // Borda fina verde
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );

      case AppButtonVariant.danger:
        // Botão específico para ações destrutivas (excluir conta).
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            // Usa o ícone passado ou 'delete' por padrão
            icon: Icon(icon ?? Icons.delete_outline, size: 20),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger, width: 1.2), // Borda fina vermelha
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }
}
