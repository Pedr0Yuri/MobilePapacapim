import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/bird_logo.dart';
import '../data/posts_store.dart';

// Tela principal do feed (onde os posts aparecem).
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PostsStore _store = PostsStore.instance;

  @override
  void initState() {
    super.initState();
    // Quando um post é criado, curtido ou respondido, atualizo o feed.
    _store.addListener(_onPostsChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onPostsChanged);
    super.dispose();
  }

  void _onPostsChanged() => setState(() {});

  Widget _postCard(Map<String, dynamic> post, {bool showRecommendationBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: _PostCard(
        post: post,
        isOwn: post['handle'] == PostsStore.currentUserHandle,
        showRecommendationBadge: showRecommendationBadge,
        onDelete: () => _store.deletePost(post['id'] as String),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final followed = _store.followedFeedPosts;
    final recommended = _store.recommendedFeedPosts;

    return Column(
      children: [
        _FeedHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              if (followed.isNotEmpty) ...[
                const _FeedSectionHeader(
                  title: 'Seguindo',
                  icon: Icons.people_outline_rounded,
                ),
                const SizedBox(height: 8),
                ...followed.map((post) => _postCard(post)),
                if (recommended.isNotEmpty) const SizedBox(height: 8),
              ],
              if (recommended.isNotEmpty) ...[
                const _FeedSectionHeader(
                  title: 'Recomendados para você',
                  icon: Icons.auto_awesome_outlined,
                  muted: true,
                ),
                const SizedBox(height: 8),
                ...recommended.map((post) => _postCard(post, showRecommendationBadge: true)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool muted;

  const _FeedSectionHeader({
    required this.title,
    required this.icon,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = muted ? AppColors.textSecondary : AppColors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 20, color: muted ? AppColors.accent : AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// Cabeçalho superior (substitui o AppBar padrão).
class _FeedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 12,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.beige, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
            splashRadius: 22,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  padding: const EdgeInsets.all(4),
                  child: const BirdLogo(size: 20, color: AppColors.beige),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Papacapim',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isOwn;
  final bool showRecommendationBadge;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.isOwn,
    this.showRecommendationBadge = false,
    required this.onDelete,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Excluir publicação?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Tem certeza de que deseja excluir esta publicação?',
            style: TextStyle(color: AppColors.textPrimary, height: 1.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
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
    final liked = post['liked'] as bool;
    final likes = post['likes'] as int;
    final replies = post['replies'] as int;
    final replyList = post['replyList'] as List<Map<String, dynamic>>;
    final postId = post['id'] as String;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: showRecommendationBadge
            ? AppColors.inputBg.withValues(alpha: 0.45)
            : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: showRecommendationBadge
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.35), width: 1)
            : null,
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
          if (showRecommendationBadge)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sugestão',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  (post['name'] as String)[0],
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      post['handle'] as String,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                post['time'] as String,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              if (isOwn)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    splashRadius: 16,
                    onSelected: (value) {
                      if (value == 'delete') _showDeleteConfirmation(context);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post['content'] as String,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          PostReplyList(replies: replyList),
          const SizedBox(height: 16),
          Row(
            children: [
              _CardActionButton(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: 'Curtir',
                count: likes,
                active: liked,
                activeColor: const Color(0xFFE74C3C),
                onTap: () => PostsStore.instance.toggleLike(postId),
              ),
              const SizedBox(width: 12),
              _CardActionButton(
                icon: Icons.repeat_rounded,
                label: 'Repostar',
                count: likes ~/ 4,
                active: false,
                activeColor: AppColors.accent,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _CardActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Responder',
                count: replies,
                active: false,
                activeColor: AppColors.accent,
                onTap: () => showPostReplySheet(context, postId),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
