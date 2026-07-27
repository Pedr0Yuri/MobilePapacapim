import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Cadastro da Aplicação.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    List<String> missingFields = [];
    if (_nameController.text.trim().length < 3) missingFields.add('Nome (mínimo de 3 caracteres)');
    if (_loginController.text.trim().length < 3) missingFields.add('Login (mínimo de 3 caracteres)');
    if (_passwordController.text.trim().length < 3) missingFields.add('Senha (mínimo de 3 caracteres)');
    if (_confirmPasswordController.text.trim().length < 3) missingFields.add('Confirmação de Senha (mínimo de 3 caracteres)');

    if (missingFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Campos inválidos', style: TextStyle(color: AppColors.danger)),
          content: Text(
            'Por favor, corrija os seguintes campos antes de continuar:\n\n- ${missingFields.join('\n- ')}',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK', style: TextStyle(color: AppColors.cta)),
            ),
          ],
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conta criada com sucesso!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    // Caso de sucesso, volta para tela de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20), onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
        title: const Text('Criar Conta', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 22)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              children: [
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]),
                  child: const Icon(Icons.person_add_outlined, size: 32, color: AppColors.white),
                ),
                const SizedBox(height: 16),
                const Text('Junte-se ao Papacapim', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 36),
                AppTextField(label: 'Nome', icon: Icons.badge_outlined, controller: _nameController),
                const SizedBox(height: 18),
                AppTextField(label: 'Login', icon: Icons.alternate_email, controller: _loginController),
                const SizedBox(height: 18),
                AppTextField(label: 'Senha', icon: Icons.lock_outline, obscureText: true, controller: _passwordController),
                const SizedBox(height: 18),
                AppTextField(label: 'Confirmação de Senha', icon: Icons.lock_person_outlined, obscureText: true, controller: _confirmPasswordController),
                const SizedBox(height: 36),
                AppButton(label: 'Cadastrar', onPressed: _handleRegister),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem uma conta?', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    AppButton(label: 'Entrar', variant: AppButtonVariant.text, onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
                  ],
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
