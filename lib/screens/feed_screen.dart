import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/post_card.dart';
import 'profile_screen.dart';
import 'post_detail_screen.dart' as import_detail;

// Feed.
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
    _store.addListener(_onPostsChanged);
    ProfileStore.instance.addListener(_onPostsChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onPostsChanged);
    ProfileStore.instance.removeListener(_onPostsChanged);
    super.dispose();
  }

  void _onPostsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final allPosts = _store.posts;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const AppTopBar(),
          Material(
            color: AppColors.background,
            child: TabBar(
              indicatorColor: AppColors.cta,
              indicatorWeight: 3,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: AppColors.inputBorder.withValues(alpha: 0.4),
              tabs: const [
                Tab(text: 'Todos'),
                Tab(text: 'Seguindo'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPostList(allPosts),
                _buildPostList(_store.followedFeedPosts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma postagem encontrada.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final post = posts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            onTap: () {
              // Navega para a tela de detalhes mantendo a barra de navegação root
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) =>
                      import_detail.PostDetailScreen(postId: post['id']),
                ),
              );
            },
            onProfileTap: () {
              // Navega para o perfil do usuário
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(name: post['name'], handle: post['handle']),
                ),
              );
            },
            onLike: () => _store.toggleLike(post['id']),
            onReply: () => showPostReplySheet(context, post['id']),
            onDelete: () => _showDeleteDialog(context, post['id']),
          ),
        );
      },
    );
  }

  /// Exibe um diálogo nativo para confirmar a exclusão.
  /// Usamos dialogs nativos (AlertDialog) para evitar exclusões acidentais.
  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
        content: const Text('Excluir esta postagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _store.deletePost(postId);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
