import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/repositories/auth_repository.dart';
import '../data/session_store.dart';
import 'user_avatar.dart';

// Drawer menu.
class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onProfileTap;

  const AppDrawer({
    super.key,
    required this.onLogout,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = SessionStore.instance.name ?? SessionStore.instance.userLogin ?? '';
    final displayHandle = PostsStore.currentUserHandle;

    return Drawer(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, 28 + MediaQuery.of(context).padding.top, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary.withValues(alpha: 0.9)
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                        ),
                        child: UserAvatar(
                          handle: displayHandle,
                          imageUrl: SessionStore.instance.profileImage,
                          radius: 24,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayHandle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.beige.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _drawerItem(
              Icons.person_outline_rounded,
              'Perfil',
              AppColors.accent,
              onProfileTap,
            ),
            _drawerItem(
              Icons.help_outline_rounded,
              'Ajuda e Sobre',
              AppColors.cta,
              () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
            const Spacer(),
            _drawerItem(
              Icons.logout_rounded,
              'Sair',
              AppColors.danger,
              () async {
                // Encerra sessão na API (DELETE /sessions/1) e limpa token local.
                await AuthRepository.instance.logout();
                onLogout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color == AppColors.danger ? color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
