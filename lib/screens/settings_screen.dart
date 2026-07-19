import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_button.dart';

// Tela de Configurações (Acessada pelo Menu Lateral)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Mostra um Diálogo (Popup Modal) para confirmar exclusão de conta
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.danger, size: 24), // Ícone de alerta vermelho
              SizedBox(width: 10),
              Text(
                'Excluir Conta',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita e todos os seus dados serão perdidos.',
            style: TextStyle(color: AppColors.textPrimary, height: 1.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          // Botões no rodapé do alerta
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Só fecha o dialog
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 1. Fecha o dialog
                // 2. pushNamedAndRemoveUntil empurra para tela de registro e DELETA TODO O HISTÓRICO.
                // O "(route) => false" significa "não mantenha nenhuma rota anterior viva".
                Navigator.pushNamedAndRemoveUntil(context, '/register', (route) => false);
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Configurações',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          // ListView é usado em vez de Column para podermos rolar a tela tranquilamente
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              const SizedBox(height: 8),
              
              // Bloco de configurações de "Conta"
              _SettingsSection(
                title: 'Conta',
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.accent,
                    title: 'Editar perfil',
                    subtitle: 'Nome, bio, foto e localização',
                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.cta,
                    title: 'Privacidade',
                    subtitle: 'Controle quem pode ver seu perfil',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Notificações',
                    subtitle: 'Gerencie alertas e avisos',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Bloco de "Sobre"
              _SettingsSection(
                title: 'Sobre',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.accent,
                    title: 'Sobre o Papacapim',
                    subtitle: 'Versão 1.0.0',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.cta,
                    title: 'Termos de uso',
                    subtitle: 'Leia nossos termos e condições',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 36),
              
              // Linha divisória fina
              Divider(color: AppColors.inputBorder.withValues(alpha: 0.4)),
              const SizedBox(height: 20),
              
              // Botão para excluir conta na base das configurações
              AppButton(
                label: 'Excluir Conta',
                variant: AppButtonVariant.danger, // Variante vermelha que criamos
                icon: Icons.delete_forever_outlined,
                onPressed: () => _showDeleteDialog(context),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar que agrupa os itens (Tiles) em um card branco com título em cima (estilo iPhone Settings)
class _SettingsSection extends StatelessWidget {
  final String title; // Título da sessão (ex: "Conta")
  final List<Widget> children; // Lista de botões dentro dela

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8, // Texto espaçado e maiúsculo dá um tom mais profissional para rótulos
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Para cada item na lista "children", nós o desenhamos,
              // e se NÃO for o último item da lista, colocamos uma divisória (Divider) no meio.
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 64, // Recua a linha para ela não cruzar o ícone (design de alto nível)
                    color: AppColors.inputBorder.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Widget para cada "linha" clicável dentro da caixa de configuração.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, // O que acontece ao clicar
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Ícone dentro de um quadrado com borda arredondada e fundo semi-transparente da cor do ícone
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Setinha pra direita " > "
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
