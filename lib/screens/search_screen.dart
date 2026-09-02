import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
import '../data/models/user.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';
import '../data/repositories/posts_repository.dart';
import '../data/repositories/users_repository.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/post_card.dart';
import 'profile_screen.dart';
import 'post_detail_screen.dart' as import_detail;

// Tela de pesquisa.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  String query = '';
  bool showOnlyFollowing = false;
  late TabController _tabController;
  final PostsStore _store = PostsStore.instance;
  final UsersRepository _usersRepository = UsersRepository.instance;
  final PostsRepository _postsRepository = PostsRepository.instance;

  Timer? _debounce;
 
  List<User> _users = [];
  bool _isLoadingUsers = false;
  String? _usersError;
 
  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = false;
  String? _postsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _store.addListener(_onDataChanged);
    ProfileStore.instance.addListener(_onDataChanged);
    _searchUsers();
    _searchPosts();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _store.removeListener(_onDataChanged);
    ProfileStore.instance.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() => query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchUsers();
      _searchPosts();
    });
  }
 
  // Endpoint: GET /users?search=termo
  Future<void> _searchUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });
    try {
      final results = await _usersRepository.searchUsers(search: query);
      if (!mounted) return;
      setState(() => _users = results);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _usersError = e.message);
    } finally {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }
 
  // Endpoint: GET /posts?search=termo (combinado com feed=1 quando o usuário liga o "Apenas quem eu sigo").
  Future<void> _searchPosts() async {
    setState(() {
      _isLoadingPosts = true;
      _postsError = null;
    });
    try {
      final results = await _postsRepository.getFeed(
        followingOnly: showOnlyFollowing,
        search: query,
      );
      if (!mounted) return;
      setState(() => _posts = results.map((p) => p.toUiMap()).toList());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _postsError = e.message);
    } finally {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }
 
  void _onToggleFollowing(bool value) {
    setState(() => showOnlyFollowing = value);
    _searchPosts();
  }
 

  void _navigateToProfile(String name, String handle) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(name: name, handle: handle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppTopBar(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              hintText: 'Buscar usuários ou postagens...',
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Material(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
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
              Tab(text: 'Usuários'),
              Tab(text: 'Posts'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildUsersTab(), _buildPostsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    if (_isLoadingUsers && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.cta));
    }
    if (_usersError != null && _users.isEmpty) {
      return _buildErrorState(_usersError!, _searchUsers);
    }
    if (_users.isEmpty) {
      return const Center(
        child: Text('Nenhum usuário encontrado.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      itemCount: _users.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: AppColors.inputBorder.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, i) {
        final user = _users[i];
        final handle = '@${user.login}';
        return ListTile(
          onTap: () => _navigateToProfile(user.name, handle),
          leading: CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            child: Builder(
              builder: (context) {
                final isMe = handle == PostsStore.currentUserHandle;
                final img = isMe
                    ? ProfileStore.instance.profileImageProvider
                    : (user.profileImage != null && user.profileImage!.isNotEmpty
                        ? NetworkImage(user.profileImage!)
                        : null);
                return img == null
                    ? Icon(Icons.person, color: AppColors.secondary.withValues(alpha: 0.5), size: 20)
                    : CircleAvatar(backgroundImage: img, radius: 20);
              },
            ),
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            handle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Apenas quem eu sigo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: showOnlyFollowing,
                activeThumbColor: AppColors.cta,
                onChanged: _onToggleFollowing,
              ),
            ],
          ),
        ),
        Expanded(child: _buildPostsList()),
      ],
    );
  }
 
  Widget _buildPostsList() {
    if (_isLoadingPosts && _posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_postsError != null && _posts.isEmpty) {
      return _buildErrorState(_postsError!, _searchPosts);
    }
    if (_posts.isEmpty) {
      return const Center(
        child: Text('Nenhuma postagem encontrada.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _posts.length,
      itemBuilder: (context, i) {
        final post = _posts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            isSimplified: true, // Hide action bar
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => import_detail.PostDetailScreen(
                    postId: post['id'],
                  ),
                ),
              );
            },
            onProfileTap: () =>
                _navigateToProfile(post['name'], post['handle']),
          ),
        );
      },
    );
  }
 
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
