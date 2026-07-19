import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/bird_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Login. É um StatelessWidget pois ela não muda de forma dinâmica
// enquanto o usuário está olhando para ela (ela apenas reage aos toques redirecionando).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold é a base de quase toda tela do Flutter. Ele gerencia AppBar, Drawers, FloatingButtons, etc.
    // Se você retornar direto um Column, não terá o estilo de tela "fundo branco", e vai quebrar o layout.
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // Center e ConstrainedBox: usamos isso para o layout não esticar infinitamente em telas grandes (Web/Tablet).
      // A caixa principal terá no máximo 450 pixels de largura e ficará centralizada.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          
          // SingleChildScrollView permite que a tela faça 'scroll' se o teclado subir e cobrir os inputs.
          // Sem ele, daria o erro famoso do Flutter "Bottom overflowed by X pixels".
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                
                // Container que faz o fundo marrom arredondado ao redor do logo.
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22), // Bordas super arredondadas
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 24, // Sombra suave espalhada
                        offset: const Offset(0, 10), // Joga a sombra para baixo
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: const BirdLogo(size: 52, color: AppColors.beige), // Nosso logo desenhado via código
                ),
                const SizedBox(height: 24),
                
                // Nome do App
                const Text(
                  'Papacapim',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Conecte-se com o mundo',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Nossos campos de texto customizados reutilizados (reduz muito código!)
                const AppTextField(
                  label: 'Login',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 18),
                const AppTextField(
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  obscureText: true, // Esconde o texto digitado
                ),
                const SizedBox(height: 32),
                
                // Nosso botão principal
                AppButton(
                  label: 'Entrar',
                  onPressed: () {
                    // pushReplacementNamed empurra a tela de Home e apaga a de Login da "pilha".
                    // Isso impede que o usuário volte para a tela de login ao clicar no botão "voltar" do Android.
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                const SizedBox(height: 20),
                
                // Opção de ir para o cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppButton(
                      label: 'Criar conta',
                      variant: AppButtonVariant.text, // Variante apenas de texto
                      onPressed: () {
                        // Apenas pushNamed, pois queremos poder voltar para o login depois.
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
