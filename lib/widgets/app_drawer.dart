import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/profile_store.dart';

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
                        child: Builder(
                          builder: (context) {
                            final img = ProfileStore.instance.profileImageProvider;
                            return CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: img,
                              child: img == null
                                  ? const Center(
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.white,
                                        size: 28,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pedr0Yuri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@Pedr0Yuri',
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
              onLogout,
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
