import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// Nosso componente padronizado de campo de texto.
// Ao invés de repetir as cores e decorações (bordas, paddings) em cada tela, 
// criamos este componente. Assim garantimos que o app inteiro siga o mesmo padrão visual.
class AppTextField extends StatelessWidget {
  final String label; // Texto da etiqueta superior
  final IconData icon; // Ícone que fica à esquerda (prefixIcon)
  final bool obscureText; // Define se vai ocultar os caracteres (usado para senhas)
  final TextEditingController? controller; // O controlador que acessa o que o usuário digitou
  final String? initialValue; // Um valor já preenchido inicial (usado na edição de perfil)
  final int maxLines; // Quantas linhas o campo pode ter (usado na Bio, que precisa de várias)
  final ValueChanged<String>? onChanged; // Uma função que é chamada toda vez que o usuário digita algo

  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscureText = false, // Por padrão, textos não são ocultos
    this.controller,
    this.initialValue,
    this.maxLines = 1, // Por padrão, apenas 1 linha
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // O TextFormField do Flutter não aceita ter um 'initialValue' E um 'controller' ao mesmo tempo.
      // Então fazemos um teste ternário: se o controller for nulo, permitimos o initialValue.
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      // Se for senha (obscureText = true), força a ser 1 linha, senão usa maxLines.
      maxLines: obscureText ? 1 : maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      // A InputDecoration define o visual inteiro do campo (fundo, bordas, label, etc)
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        // O prefixIcon é o ícone da esquerda.
        // O padding aqui é um "truque" matemático para o ícone não ficar no meio de um campo multilinhas (como a bio), 
        // e sim alinhado no topo acompanhando o texto.
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines - 1) * 20.0 : 0),
          child: Icon(icon, color: AppColors.accent, size: 22),
        ),
        filled: true, // Indica que o campo tem cor de fundo
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        
        // Estado normal: borda simples clara
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        // Estado desabilitado, mas presente: borda simples clara
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        // Estado quando clica no campo (focado): borda mais grossa e laranja (cta)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.cta, width: 1.5),
        ),
      ),
    );
  }
}
