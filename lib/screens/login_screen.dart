import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
import '../data/repositories/auth_repository.dart';
import '../data/profile_store.dart';
import '../data/session_store.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Login da Aplicação.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final login = _loginController.text.trim();
    final password = _passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      _showErrorDialog('Preencha login e senha para continuar.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Chama POST /sessions. Se der certo, o AuthRepository já guarda o
      // token no SessionStore — a partir daqui o app está "autenticado"
      // e todas as próximas requisições incluem o header x-session-token.
      await AuthRepository.instance.login(login: login, password: password);
 
      // Busca nome completo e foto de perfil reais (GET /users/me) logo
      // após o login, e já popula o SessionStore/ProfileStore. Fazemos
      // isso AQUI (e não só quando o usuário abre Editar Perfil) pra que
      // o nome/foto corretos apareçam desde o primeiro momento no feed e
      // no perfil, sem precisar visitar Editar Perfil antes.
      //
      // Se essa busca falhar por algum motivo, não travamos o login por
      // causa disso — o app segue funcionando com o login como fallback
      // de nome, e sem foto.
      try {
        final user = await AuthRepository.instance.getCurrentUser();
        SessionStore.instance.updateProfile(
          name: user.name,
          profileImage: user.profileImage,
        );
        ProfileStore.instance.setNetworkProfileImageUrl(user.profileImage);
      } on ApiException {
        // Ignorado de propósito — ver comentário acima.
      }
 
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      // 401 = credenciais inválidas. A API não manda uma mensagem muito
      // clara pra esse caso, então mostramos um texto fixo e amigável.
      final message = e.statusCode == 401
          ? 'Login ou senha incorretos. Verifique os dados e tente novamente.'
          : e.message;
      _showErrorDialog(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Não foi possível entrar', style: TextStyle(color: AppColors.danger)),
        content: Text(message, style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.cta)),
          ),
        ],
      ),
    );
  }

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
                AppTextField(label: 'Login', icon: Icons.alternate_email, controller: _loginController),
                const SizedBox(height: 18),
                AppTextField(label: 'Senha', icon: Icons.lock_outline, obscureText: true, controller: _passwordController),
                const SizedBox(height: 32),
                AppButton(label: 'Entrar', onPressed: _handleLogin, loading: _isLoading),
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
