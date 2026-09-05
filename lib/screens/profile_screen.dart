import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
import '../data/models/user.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';
import '../data/repositories/users_repository.dart';
import '../data/session_store.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_avatar.dart';
import 'followers_screen.dart';
import 'post_detail_screen.dart' as import_detail;

// Tela de Perfil do Usuário.
class ProfileScreen extends StatefulWidget {
  final String? handle;
  final String? name;

  const ProfileScreen({super.key, this.handle, this.name});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final PostsStore _store = PostsStore.instance;
  final UsersRepository _usersRepo = UsersRepository.instance;
  final ScrollController _scrollController = ScrollController();

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  User? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoadingProfile = true;
  bool _isLoadingPosts = true;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onPostsChanged);
    ProfileStore.instance.addListener(_onPostsChanged);
    _loadUserData();
    _loadUserPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _store.removeListener(_onPostsChanged);
    ProfileStore.instance.removeListener(_onPostsChanged);
    super.dispose();
  }

  void _onPostsChanged() {
    if (mounted) setState(() {});
  }

  bool get isOwnProfile =>
      widget.handle == null || widget.handle == PostsStore.currentUserHandle;

  /// Login do perfil (sem o @).
  String get _login {
    if (isOwnProfile) {
      return SessionStore.instance.userLogin ?? '';
    }
    final handle = widget.handle!;
    return handle.startsWith('@') ? handle.substring(1) : handle;
  }

  /// Carrega dados reais do usuário via GET /users/{login}.
  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });
    try {
      final loginParam = isOwnProfile ? 'me' : _login;
      final user = await _usersRepo.getUser(loginParam);
      if (!mounted) return;
      setState(() => _userData = user);

      // Para o próprio perfil, atualiza SessionStore e ProfileStore
      // com os dados mais recentes.
      if (isOwnProfile) {
        SessionStore.instance.updateProfile(
          name: user.name,
          profileImage: user.profileImage,
        );
        ProfileStore.instance.setNetworkProfileImageUrl(user.profileImage);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _profileError = e.message);
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  /// Carrega postagens reais do usuário via GET /users/{login}/posts.
  Future<void> _loadUserPosts() async {
    setState(() => _isLoadingPosts = true);
    try {
      final posts = await _usersRepo.getUserPosts(_login);
      if (!mounted) return;
      setState(() => _userPosts = posts.map((p) => p.toUiMap()).toList());
    } on ApiException {
      // Se falhar, apenas mostramos vazio.
    } finally {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([_loadUserData(), _loadUserPosts()]);
  }

  @override
  Widget build(BuildContext context) {
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
                _userData?.name ?? widget.name ?? 'Perfil',
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
            child: _profileError != null && _userData == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            _profileError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: refreshAll,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: refreshAll,
                    color: AppColors.cta,
                    child: NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder: (context, _) => [
                        SliverToBoxAdapter(child: _buildHeader()),
                      ],
                      body: _buildPostsList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    if (_isLoadingPosts && _userPosts.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.cta));
    }
    if (_userPosts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 60),
          Center(
            child: Text(
              'Nenhuma postagem ainda.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _userPosts.length,
      itemBuilder: (context, i) {
        final post = _userPosts[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: PostCard(
            post: post,
            onTap: () async {
              PostsStore.instance.cacheIsolatedPost(post);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => import_detail.PostDetailScreen(postId: post['id']),
                ),
              );
              if (mounted) {
                refreshAll();
              }
            },
            onProfileTap: () {},
            onLike: () {
              // Atualiza a UI otimisticamente aqui, já que esta lista é independente do PostsStore
              final liked = post['liked'] as bool;
              setState(() {
                post['liked'] = !liked;
                post['likes'] = (post['likes'] as int) + (liked ? -1 : 1);
              });
              // Chama a API através da store
              _store.toggleLike(post['id']);
            },
            onReply: () async {
              final result = await showPostReplySheet(context, post['id']);
              if (result == true && mounted) {
                refreshAll();
              }
            },
            onDelete: () => _showDeleteDialog(context, post['id']),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final user = _userData;
    final isFollowing = user?.youFollow ?? false;
    final displayName = user?.name ?? widget.name ?? PostsStore.currentUserName;
    final displayHandle = widget.handle ?? PostsStore.currentUserHandle;
    final followersCount = user?.followersNumber ?? 0;
    final followingCount = user?.followingNumber ?? 0;

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
                child: UserAvatar(
                  imageUrl: user?.profileImage,
                  handle: displayHandle,
                  radius: 40,
                  iconSize: 44,
                ),
              ),
              if (_isLoadingProfile)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cta),
                )
              else if (isOwnProfile)
                OutlinedButton(
                  onPressed: () async {
                    await Navigator.of(context, rootNavigator: true)
                        .pushNamed('/edit-profile');
                    // Atualiza a tela de perfil ao voltar da tela de edição
                    _loadUserData();
                    _loadUserPosts();
                  },
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
              else
                ElevatedButton(
                  onPressed: () async {
                    await _store.toggleFollow(displayHandle);
                    // Recarrega os dados do perfil pra atualizar contagem
                    _loadUserData();
                  },
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
              // Badges "Segue você" quando outro usuário te segue
              if (!isOwnProfile && user?.followsYou == true) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Segue você',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                _formatCount(followingCount),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FollowersScreen(
                        login: _login,
                        title: 'Seguidores de ${_userData?.name ?? displayName}',
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      _formatCount(followersCount),
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

  /// Formata contadores grandes de forma legível (ex: 1500 → "1.5k").
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
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
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _store.deletePost(postId);
                _loadUserPosts(); // Recarrega lista
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
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger))
          ),
        ],
      ),
    );
  }
}
