import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';
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

  final List<Map<String, String>> users = [
    {'name': 'Gustavo Just', 'login': '@gustavo'},
    {'name': 'Pedr0Yuri', 'login': '@Pedr0Yuri'},
    {'name': 'Geovani Cardeal', 'login': '@GeovaniCardeal'},
    {'name': 'Nadson', 'login': '@JesusÉoCaminho'},
    {'name': 'Zoe Sabina', 'login': '@Zozoze'},
    {'name': 'Ana Bia', 'login': '@biaAragao'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _store.addListener(_onDataChanged);
    ProfileStore.instance.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onDataChanged);
    ProfileStore.instance.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredUsers {
    if (query.isEmpty) return users;
    return users
        .where(
          (u) =>
              u['name']!.toLowerCase().contains(query.toLowerCase()) ||
              u['login']!.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<Map<String, dynamic>> get filteredPosts {
    Iterable<Map<String, dynamic>> base = _store.posts;
    if (showOnlyFollowing) {
      base = base.where((p) => _store.isFollowedAuthor(p['handle']));
    }
    if (query.isEmpty) return base.toList();
    return base
        .where(
          (p) =>
              p['content'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              p['name'].toString().toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
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
            onChanged: (v) => setState(() => query = v),
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
    return ListView.separated(
      itemCount: filteredUsers.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: AppColors.inputBorder.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, i) {
        final user = filteredUsers[i];
        return ListTile(
          onTap: () => _navigateToProfile(user['name']!, user['login']!),
          leading: CircleAvatar(
            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
            child: Builder(
              builder: (context) {
                final isMe = user['login'] == PostsStore.currentUserHandle;
                final img = isMe ? ProfileStore.instance.profileImageProvider : null;
                return img == null
                    ? Icon(Icons.person, color: AppColors.secondary.withValues(alpha: 0.5), size: 20)
                    : CircleAvatar(backgroundImage: img, radius: 20);
              }
            ),
          ),
          title: Text(
            user['name']!,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            user['login']!,
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
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final posts = filteredPosts;
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
                    onChanged: (v) => setState(() => showOnlyFollowing = v),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: posts.length,
                itemBuilder: (context, i) {
                  final post = posts[i];
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
              ),
            ),
          ],
        );
      },
    );
  }
}
