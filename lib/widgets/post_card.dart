import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import 'user_avatar.dart';

/// Widget que exibe uma postagem.
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isSimplified;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.isSimplified = false,
    this.onTap,
    this.onProfileTap, // Permite navegação para o perfil do usuário ao clicar na foto.
    this.onLike,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Envolvemos em um GestureDetector para navegar para a tela de detalhes ao clicar no card.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            
            // Corpo de texto do post.
            Text(
              post['content'],
              style: const TextStyle(fontSize: 15, height: 1.55),
            ),
            
            if (!isSimplified) ...[
              const SizedBox(height: 16),
              // Footer
              _buildFooter(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onProfileTap,
          child: Row(
            children: [
              UserAvatar(
                imageUrl: post['profileImage'] as String?,
                handle: post['handle'] as String?,
                radius: 21,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    post['handle'],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        Text(
          post['time'],
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        
        if (post['handle'] == PostsStore.currentUserHandle && onDelete != null)
          SizedBox(
            width: 32,
            height: 32,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
                size: 20,
              ),
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (val) {
                if (val == 'delete') {
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                      SizedBox(width: 10),
                      Text('Excluir', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  post['liked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: post['liked'] ? AppColors.likeRed : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  post['likes'].toString(),
                  style: TextStyle(
                    color: post['liked'] ? AppColors.likeRed : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 28),
        
        InkWell(
          onTap: onReply,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  post['replies'].toString(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
