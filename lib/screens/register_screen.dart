import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

// Tela de Registro. É um StatefulWidget porque precisamos reagir instantaneamente
// ao que o usuário digita na senha (para mostrar se os requisitos estão verdes ou vermelhos).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Variável de estado que guarda a senha atual digitada
  String _password = '';

  // "Getters" calculados dinamicamente baseados na senha atual.
  // RegExp é uma expressão regular (padrão de texto).
  bool get _hasMinLength => _password.length >= 8; // Checa se tem 8 caracteres
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]')); // Checa se tem maiúscula
  bool get _hasSymbol => _password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]')); // Checa se tem símbolo
  
  // Só considera totalmente válida se todas as 3 condições forem true.
  bool get _allValid => _hasMinLength && _hasUppercase && _hasSymbol;

  // Função que roda ao clicar em Cadastrar
  void _onRegister() {
    // showDialog abre um pop-up na tela
    showDialog(
      context: context,
      barrierDismissible: false, // Força o usuário a clicar no botão "Entendi" para fechar, não pode clicar fora.
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(28, 32, 28, 8),
          actionsPadding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário, senão ocuparia a tela toda verticalmente.
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 36,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verifique seu e-mail',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enviamos um link de confirmação para o seu email. Verifique sua caixa de entrada para ativar sua conta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // 1. Fecha o Dialog
                  Navigator.pop(context); // 2. Volta para a tela de Login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Entendi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        // Botão de voltar customizado na cor bege ao invés de usar o padrão preto/branco do sistema.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Criar Conta',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              children: [
                // Ícone circular no topo
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_add_outlined, size: 32, color: AppColors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Junte-se ao Papacapim',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                
                // Campos de registro
                const AppTextField(
                  label: 'Nome',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 18),
                const AppTextField(
                  label: 'Login',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 18),
                
                // Campo de Senha que "ouve" as mudanças
                AppTextField(
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  // Quando o texto muda, usamos setState para atualizar _password e forçar a tela a redesenhar.
                  onChanged: (value) => setState(() => _password = value),
                ),
                const SizedBox(height: 10),
                
                // Caixa de requisitos de senha.
                // A borda muda de transparente, para vermelho ou verde dinamicamente.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      // Lógica da cor da borda
                      color: _password.isEmpty
                          ? Colors.transparent // Se tiver vazio, sem borda
                          : _allValid
                              ? AppColors.accent.withValues(alpha: 0.3) // Verde se tudo ok
                              : AppColors.inputBorder.withValues(alpha: 0.4), // Cinza/neutro se faltando algo
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requisitos da senha:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Passamos o estado de cada requisito para um widget menor (_PasswordRequirement)
                      _PasswordRequirement(
                        label: 'Mínimo de 8 caracteres',
                        met: _hasMinLength,
                        active: _password.isNotEmpty, // "active" serve para dizer se o usuário já começou a digitar
                      ),
                      const SizedBox(height: 4),
                      _PasswordRequirement(
                        label: 'Pelo menos uma letra maiúscula',
                        met: _hasUppercase,
                        active: _password.isNotEmpty,
                      ),
                      const SizedBox(height: 4),
                      _PasswordRequirement(
                        label: 'Pelo menos um símbolo (!@#\$%...)',
                        met: _hasSymbol,
                        active: _password.isNotEmpty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const AppTextField(
                  label: 'Confirmação de Senha',
                  icon: Icons.lock_person_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 36),
                AppButton(
                  label: 'Cadastrar',
                  onPressed: _onRegister,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppButton(
                      label: 'Entrar',
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.pop(context), // Volta pro login
                    ),
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

// Widget privado (com underline no nome) usado só nesta tela para desenhar cada linha de requisito (check verde, erro vermelho).
class _PasswordRequirement extends StatelessWidget {
  final String label;
  final bool met; // Requisito atendido?
  final bool active; // Já começou a digitar?

  const _PasswordRequirement({
    required this.label,
    required this.met,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    
    // Lógica para decidir a cor e o ícone baseados no estado
    if (!active) {
      color = AppColors.textSecondary.withValues(alpha: 0.5); // Cinza
      icon = Icons.circle_outlined;
    } else if (met) {
      color = AppColors.accent; // Verde
      icon = Icons.check_circle_rounded;
    } else {
      color = AppColors.danger.withValues(alpha: 0.7); // Vermelho
      icon = Icons.cancel_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
