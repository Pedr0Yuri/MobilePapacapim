import 'package:flutter/material.dart';
import '../core/app_colors.dart';

import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Login da Aplicação.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Image.asset('assets/logo.png', width: 220, height: 220),
                Transform.translate(
                  offset: const Offset(0, -15),
                  child: const Text('Microblogging para todos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 48),
                const AppTextField(label: 'Login', icon: Icons.alternate_email),
                const SizedBox(height: 18),
                const AppTextField(label: 'Senha', icon: Icons.lock_outline, obscureText: true),
                const SizedBox(height: 32),
                AppButton(label: 'Entrar', onPressed: () => Navigator.pushReplacementNamed(context, '/home')),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem uma conta?', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    AppButton(label: 'Criar conta', variant: AppButtonVariant.text, onPressed: () => Navigator.pushNamed(context, '/register')),
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
