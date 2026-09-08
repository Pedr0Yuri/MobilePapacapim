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
import '../widgets/user_avatar.dart';
import 'profile_screen.dart';
import 'post_detail_screen.dart' as import_detail;

// Tela de pesquisa.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
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
  bool _isLoadingMoreUsers = false;
  int _currentUsersPage = 1;
  String? _usersError;
 
  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = false;
  bool _isLoadingMorePosts = false;
  int _currentPostsPage = 1;
  String? _postsError;

  final ScrollController _usersScrollController = ScrollController();
  final ScrollController _postsScrollController = ScrollController();

  void scrollToTop() {
    if (_tabController.index == 0 && _usersScrollController.hasClients) {
      _usersScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else if (_tabController.index == 1 && _postsScrollController.hasClients) {
      _postsScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

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
    _usersScrollController.dispose();
    _postsScrollController.dispose();
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
 
  Future<void> _searchUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
      _currentUsersPage = 1;
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

  Future<void> _loadMoreUsers() async {
    if (_isLoadingMoreUsers) return;
    setState(() => _isLoadingMoreUsers = true);

    try {
      _currentUsersPage++;
      final results = await _usersRepository.searchUsers(search: query, page: _currentUsersPage);
      if (!mounted) return;

      if (results.isEmpty) {
        _currentUsersPage--;
        return;
      }

      setState(() {
        _users.addAll(results);
      });
    } on ApiException {
      _currentUsersPage--;
    } finally {
      if (mounted) setState(() => _isLoadingMoreUsers = false);
    }
  }
 
  Future<void> _searchPosts() async {
    setState(() {
      _isLoadingPosts = true;
      _postsError = null;
      _currentPostsPage = 1;
    });
    try {
      final results = await _postsRepository.getFeed(
        followingOnly: showOnlyFollowing,
        search: query,
        limit: 12,
      );
      if (!mounted) return;
      setState(() {
        _posts = results.map((p) => p.toUiMap()).toList();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _postsError = e.message);
    } finally {
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  // Controla a página atual pra fazer a paginação do botão "Ver mais" na tela de busca.
  Future<void> _loadMorePosts() async {
    if (_isLoadingMorePosts) return;
    setState(() => _isLoadingMorePosts = true);
    
    try {
      _currentPostsPage++;
      final results = await _postsRepository.getFeed(
        followingOnly: showOnlyFollowing,
        search: query,
        page: _currentPostsPage,
        limit: 12,
      );
      if (!mounted) return;

      if (results.isEmpty) {
        _currentPostsPage--;
        return;
      }

      setState(() {
        _posts.addAll(results.map((p) => p.toUiMap()));
      });
    } on ApiException {
      _currentPostsPage--;
    } finally {
      if (mounted) setState(() => _isLoadingMorePosts = false);
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
      return RefreshIndicator(
        onRefresh: _searchUsers,
        color: AppColors.cta,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [_buildErrorContent(_usersError!, _searchUsers)],
        ),
      );
    }
    if (_users.isEmpty) {
      return RefreshIndicator(
        onRefresh: _searchUsers,
        color: AppColors.cta,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text('Nenhum usuário encontrado.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _searchUsers,
      color: AppColors.cta,
      child: ListView.separated(
        controller: _usersScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _users.length + 1,
        separatorBuilder: (_, i) {
          if (i == _users.length - 1) return const SizedBox.shrink(); // Hide line above 'Ver mais'
          return Divider(
            height: 1,
            color: AppColors.inputBorder.withValues(alpha: 0.3),
          );
        },
        itemBuilder: (context, i) {
          if (i == _users.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: _isLoadingMoreUsers
                  ? const Center(child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: _loadMoreUsers,
                      child: const Text('Ver mais', style: TextStyle(color: AppColors.cta)),
                    ),
            );
          }

          final user = _users[i];
          final handle = '@${user.login}';
          return ListTile(
            onTap: () => _navigateToProfile(user.name, handle),
            leading: UserAvatar(
              imageUrl: user.profileImage,
              handle: handle,
              radius: 20,
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
      ),
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
      return RefreshIndicator(
        onRefresh: _searchPosts,
        color: AppColors.cta,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [_buildErrorContent(_postsError!, _searchPosts)],
        ),
      );
    }
    if (_posts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _searchPosts,
        color: AppColors.cta,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text('Nenhuma postagem encontrada.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _searchPosts,
      color: AppColors.cta,
      child: ListView.builder(
        controller: _postsScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _posts.length + 1,
        itemBuilder: (context, i) {
          if (i == _posts.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: _isLoadingMorePosts
                  ? const Center(child: CircularProgressIndicator())
                  : TextButton(
                      onPressed: _loadMorePosts,
                      child: const Text('Ver mais', style: TextStyle(color: AppColors.cta)),
                    ),
            );
          }

          final post = _posts[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostCard(
              post: post,
              isSimplified: true, // Hide action bar
              onTap: () {
                PostsStore.instance.cacheIsolatedPost(post);
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
      ),
    );
  }
 
  Widget _buildErrorContent(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 60),
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
