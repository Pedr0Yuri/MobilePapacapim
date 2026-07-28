import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';
import 'post_detail_screen.dart' as import_detail;

// Tela de Perfil do Usuário.
class ProfileScreen extends StatefulWidget {
  final String? handle;
  final String? name;

  const ProfileScreen({super.key, this.handle, this.name});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _onPostsChanged() {
    if (mounted) setState(() {});
  }

  bool get isOwnProfile =>
      widget.handle == null || widget.handle == PostsStore.currentUserHandle;

  @override
  Widget build(BuildContext context) {
    final profilePosts = isOwnProfile
        ? _store.ownPosts
        : _store.posts.where((p) => p['handle'] == widget.handle).toList();

    final showDrawerHeader = isOwnProfile && (ModalRoute.of(context)?.isFirst == true);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        onLogout: () => Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login'),
        onProfileTap: () => Navigator.pop(context),
      ),
      appBar: showDrawerHeader
          ? null
          : AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.beige,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.name ?? 'Perfil',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
      body: Column(
        children: [
          if (showDrawerHeader) const AppTopBar(),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(child: _buildHeader()),
              ],
              body: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: profilePosts.length,
                itemBuilder: (context, i) {
                  final post = profilePosts[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: PostCard(
                      post: post,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => import_detail.PostDetailScreen(postId: post['id']),
                          ),
                        );
                      },
                      // O onProfileTap no próprio perfil poderia ser vazio, mas mantemos por consistência.
                      onProfileTap: () {},
                      onLike: () => _store.toggleLike(post['id']),
                      onReply: () => showPostReplySheet(context, post['id']),
                      onDelete: () => _showDeleteDialog(context, post['id']),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isFollowing =
        !isOwnProfile && _store.followedHandles.contains(widget.handle);
    final displayName = widget.name ?? PostsStore.currentUserName;
    final displayHandle = widget.handle ?? PostsStore.currentUserHandle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isOwnProfile
                    ? Builder(
                        builder: (context) {
                          final img = ProfileStore.instance.profileImageProvider;
                          return CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.card,
                            backgroundImage: img,
                            child: img == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 44,
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  )
                                : null,
                          );
                        },
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.secondary.withValues(
                          alpha: 0.15,
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.secondary.withValues(alpha: 0.5),
                          size: 48,
                        ),
                      ),
              ),
              isOwnProfile
                  ? OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pushNamed('/edit-profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.inputBorder,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Editar perfil',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _store.toggleFollow(widget.handle!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? AppColors.inputBg
                            : AppColors.textPrimary,
                        foregroundColor: isFollowing
                            ? AppColors.textPrimary
                            : AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: Text(
                        isFollowing ? 'Seguindo' : 'Seguir',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayHandle,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                isOwnProfile ? '128' : '45',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Seguindo',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 24),
              Text(
                isOwnProfile ? '342' : '1.2k',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Seguidores',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.inputBorder.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Postagens',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Exibe um diálogo nativo para confirmar a exclusão.
  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
        content: const Text('Excluir esta postagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar')
          ),
          TextButton(
            onPressed: () { 
              _store.deletePost(postId); 
              Navigator.pop(ctx); 
            },
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger))
          ),
        ],
      ),
    );
  }
}
