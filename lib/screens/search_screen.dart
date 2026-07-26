import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/bird_logo.dart';

// Tela de Busca — permite pesquisar usuários (por login) e posts (por conteúdo).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'name': 'Gustavo Just',
      'handle': '@gustavo',
      'bio': 'Apaixonado por tecnologia e café.',
      'location': 'Recife, PE',
    },
    {
      'name': 'Mariana Silva',
      'handle': '@mariana_dev',
      'bio': 'Desenvolvedora Flutter · compartilhando código e ideias.',
      'location': 'São Paulo, SP',
    },
    {
      'name': 'Carlos Neto',
      'handle': '@carlos.neto',
      'bio': 'Designer de produto e entusiasta de UX.',
      'location': 'Belo Horizonte, MG',
    },
    {
      'name': 'Ana Flores',
      'handle': '@anaflores',
      'bio': 'Fotógrafa amadora · registrando o cotidiano.',
      'location': 'Curitiba, PR',
    },
    {
      'name': 'Rafael Costa',
      'handle': '@rafacosta',
      'bio': 'Estudante de Ciência da Computação.',
      'location': 'Porto Alegre, RS',
    },
    {
      'name': 'Julia Mendes',
      'handle': '@juliame',
      'bio': 'Leitora voraz e amante de livros.',
      'location': 'Salvador, BA',
    },
  ];

  static const List<Map<String, dynamic>> _mockPosts = [
    {
      'name': 'Gustavo Just',
      'handle': '@gustavo',
      'time': '2m',
      'content': 'Explorando novas ideias para o Papacapim hoje!',
      'likes': 24,
      'replies': 5,
      'liked': false,
    },
    {
      'name': 'Mariana Silva',
      'handle': '@mariana_dev',
      'time': '18m',
      'content': 'Flutter facilita demais criar interfaces bonitas.',
      'likes': 12,
      'replies': 3,
      'liked': true,
    },
    {
      'name': 'Carlos Neto',
      'handle': '@carlos.neto',
      'time': '45m',
      'content': 'Design minimalista faz toda a diferença na experiência do usuário.',
      'likes': 89,
      'replies': 14,
      'liked': false,
    },
    {
      'name': 'Ana Flores',
      'handle': '@anaflores',
      'time': '1h',
      'content': 'Pôr do sol incrível na orla hoje. Natureza é inspiração pura.',
      'likes': 57,
      'replies': 8,
      'liked': false,
    },
    {
      'name': 'Rafael Costa',
      'handle': '@rafacosta',
      'time': '2h',
      'content': 'Alguém mais animado para a próxima atualização do app?',
      'likes': 134,
      'replies': 22,
      'liked': true,
    },
    {
      'name': 'Julia Mendes',
      'handle': '@juliame',
      'time': '3h',
      'content': 'Recomendação de livro: comecei um clássico da ficção científica.',
      'likes': 41,
      'replies': 6,
      'liked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  String get _query => _searchController.text.trim().toLowerCase();

  List<Map<String, dynamic>> get _filteredUsers {
    if (_query.isEmpty) return [];
    return _mockUsers.where((user) {
      final name = (user['name'] as String).toLowerCase();
      final handle = (user['handle'] as String).toLowerCase();
      return name.contains(_query) || handle.contains(_query);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_query.isEmpty) return [];
    return _mockPosts.where((post) {
      final content = (post['content'] as String).toLowerCase();
      final name = (post['name'] as String).toLowerCase();
      final handle = (post['handle'] as String).toLowerCase();
      return content.contains(_query) || name.contains(_query) || handle.contains(_query);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchHeader(
          searchController: _searchController,
          hasText: _searchController.text.isNotEmpty,
          onClear: _clearSearch,
        ),
        Material(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            indicatorColor: AppColors.cta,
            indicatorWeight: 3,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
            children: [
              _buildTabContent(isUsers: true),
              _buildTabContent(isUsers: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent({required bool isUsers}) {
    if (_query.isEmpty) {
      return _SearchInitialState(isUsers: isUsers);
    }

    final results = isUsers ? _filteredUsers : _filteredPosts;
    if (results.isEmpty) {
      return _SearchEmptyState(query: _searchController.text.trim());
    }

    if (isUsers) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _UserResultTile(user: _filteredUsers[i]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: _SearchPostCard(post: _filteredPosts[i]),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final bool hasText;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.searchController,
    required this.hasText,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
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
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                padding: const EdgeInsets.all(4),
                child: const BirdLogo(size: 20, color: AppColors.beige),
              ),
              const SizedBox(width: 10),
              const Text(
                'Buscar',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar usuários ou posts...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accent, size: 22),
              suffixIcon: hasText
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: onClear,
                      splashRadius: 18,
                    )
                  : null,
              filled: true,
              fillColor: AppColors.inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.cta, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchInitialState extends StatelessWidget {
  final bool isUsers;

  const _SearchInitialState({required this.isUsers});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUsers ? Icons.person_search_rounded : Icons.manage_search_rounded,
                size: 36,
                color: AppColors.accent.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isUsers ? 'Buscar usuários' : 'Buscar posts',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isUsers
                  ? 'Digite um nome ou @login para encontrar pessoas no Papacapim.'
                  : 'Digite palavras-chave para encontrar postagens pelo conteúdo.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final String query;

  const _SearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum resultado encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Não encontramos correspondências para "$query". Tente outro termo.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserResultTile extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserResultTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['name'] as String;
    final handle = user['handle'] as String;
    final bio = user['bio'] as String;
    final location = user['location'] as String;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          location,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const _SearchPostCard({required this.post});

  @override
  State<_SearchPostCard> createState() => _SearchPostCardState();
}

class _SearchPostCardState extends State<_SearchPostCard> {
  late bool liked;
  late int likes;

  @override
  void initState() {
    super.initState();
    liked = widget.post['liked'] as bool;
    likes = widget.post['likes'] as int;
  }

  void _toggleLike() {
    setState(() {
      liked = !liked;
      likes = liked ? likes + 1 : likes - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  (widget.post['name'] as String)[0],
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
                      widget.post['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.post['handle'] as String,
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
                widget.post['time'] as String,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.post['content'] as String,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SearchCardActionButton(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: 'Curtir',
                active: liked,
                activeColor: const Color(0xFFE74C3C),
                onTap: _toggleLike,
              ),
              const SizedBox(width: 12),
              _SearchCardActionButton(
                icon: Icons.repeat_rounded,
                label: 'Repostar',
                active: false,
                activeColor: AppColors.accent,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              _SearchCardActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Responder',
                active: false,
                activeColor: AppColors.accent,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchCardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _SearchCardActionButton({
    required this.icon,
    required this.label,
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
