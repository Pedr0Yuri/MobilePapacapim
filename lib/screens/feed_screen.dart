import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
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
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> {
  final PostsStore _store = PostsStore.instance;
  final ScrollController _allPostsScrollController = ScrollController();
  final ScrollController _followingPostsScrollController = ScrollController();

  // Permite rolar a tela para o topo ao dar double-tap no ícone da Home.
  void scrollToTop() {
    if (_allPostsScrollController.hasClients) {
      _allPostsScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    if (_followingPostsScrollController.hasClients) {
      _followingPostsScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void initState() {
    super.initState();
    _store.addListener(_onPostsChanged);
    ProfileStore.instance.addListener(_onPostsChanged);
    _store.loadFeed();
  }

  @override
  void dispose() {
    _allPostsScrollController.dispose();
    _followingPostsScrollController.dispose();
    _store.removeListener(_onPostsChanged);
    ProfileStore.instance.removeListener(_onPostsChanged);
    super.dispose();
  }

  void _onPostsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final allPosts = _store.visiblePosts;

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
            child: _buildFeedBody(allPosts),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedBody(List<Map<String, dynamic>> allPosts) {
    // Primeiro carregamento: mostra spinner enquanto não há nada pra exibir.
    if (_store.isLoadingFeed && allPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
 
    // Erro no primeiro carregamento (ex: sem internet, token inválido).
    if (_store.feedError != null && allPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 12),
              Text(
                _store.feedError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _store.loadFeed(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
 
    return TabBarView(
      children: [
        RefreshIndicator(
          onRefresh: () => _store.loadFeed(),
          color: AppColors.cta,
          child: _buildPostList(allPosts, _allPostsScrollController),
        ),
        RefreshIndicator(
          onRefresh: () => _store.loadFeed(),
          color: AppColors.cta,
          child: _buildPostList(_store.followedFeedPosts, _followingPostsScrollController),
        ),
      ],
    );
  }
 

  Widget _buildPostList(List<Map<String, dynamic>> posts, ScrollController scrollController) {
    if (posts.isEmpty) {
      return ListView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text(
              'Nenhuma postagem encontrada.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: posts.length + 1,
      itemBuilder: (context, i) {
        if (i == posts.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: _store.isLoadingMoreFeed
                ? const Center(child: CircularProgressIndicator())
                : TextButton(
                    onPressed: () => _store.loadMoreFeed(),
                    child: const Text('Ver mais', style: TextStyle(color: AppColors.cta)),
                  ),
          );
        }

        final post = posts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            onTap: () async {
              // Navega para a tela de detalhes mantendo a barra de navegação root
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) =>
                      import_detail.PostDetailScreen(postId: post['id']),
                ),
              );
              if (context.mounted) {
                _store.loadFeed();
              }
            },
            onProfileTap: () async {
              // Navega para o perfil do usuário
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(name: post['name'], handle: post['handle']),
                ),
              );
              if (context.mounted) {
                _store.loadFeed();
              }
            },
            onLike: () => _store.toggleLike(post['id']),
            onReply: () async {
              final result = await showPostReplySheet(context, post['id']);
              if (result == true && context.mounted) {
                _store.loadFeed();
              }
            },
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _store.deletePost(postId);
              } on ApiException catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                );
              }
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
