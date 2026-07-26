import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';

// Tela de Perfil. É StatefulWidget porque gerencia animações de abas (Tabs) e rolagem paralela.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// with SingleTickerProviderStateMixin é necessário para habilitar as animações do TabController.
// Basicamente avisa o Flutter para sincronizar os frames de animação da aba com a taxa de atualização da tela.
class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostsStore _store = PostsStore.instance;
  final ProfileStore _profileStore = ProfileStore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Mantém o perfil sincronizado com curtidas, respostas e novos posts.
    _store.addListener(_onPostsChanged);
    _profileStore.addListener(_onPostsChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onPostsChanged);
    _profileStore.removeListener(_onPostsChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onPostsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Faixa preenchendo o Notch e Status bar usando a mesma cor do header gradiente, 
        // para dar impressão de tela cheia sem quebrar com relógio/bateria do celular.
        Container(
          height: MediaQuery.of(context).padding.top,
          color: AppColors.secondary,
        ),
        
        // NestedScrollView é complexo, mas incrível. 
        // Permite rolar a página inteira para cima escondendo a capa/foto, 
        // MAS "prega" a barra de abas (TabBar) no topo sem deixar rolar junto.
        Expanded(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Tudo aqui rola e some conforme joga o dedo para cima
                SliverToBoxAdapter(child: _buildHeader()),
                
                // pinned: true faz com que a TabBar "grude" no topo quando tenta rolar para fora da tela.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(tabController: _tabController),
                ),
              ];
            },
            
            // O corpo debaixo das abas muda deslizando para os lados (swipe).
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList(_store.ownPosts, isOwn: true),
                _buildPostsList(_store.repostedPosts, isOwn: false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Monta o cabeçalho do perfil (Capa, Avatar Centralizado, Nome, Bio e Stats)
  Widget _buildHeader() {
    return Column(
      children: [
        // Stack permite colocar widgets sobrepostos.
        // Aqui usamos para colocar a foto de perfil (CircleAvatar) flutuando POR CIMA da imagem de capa.
        Stack(
          clipBehavior: Clip.none, // Impede que o avatar seja "cortado" por estar fora dos limites do contêiner da capa.
          alignment: Alignment.center,
          children: [
            // A imagem/fundo de capa
            Container(
              height: 130,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5D3A2E), // Tons marrom escuro
                    Color(0xFF8B5E3C),
                    Color(0xFF708238), // Verde escuro
                  ],
                ),
              ),
              // Botão de 3 pontinhos na capa, posicionado no topo-direita
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white70, size: 22),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
            
            // A foto de perfil. bottom: -48 arrasta ela para baixo para cruzar a linha da capa.
            Positioned(
              bottom: -48,
              child: Container(
                padding: const EdgeInsets.all(4), // Faz uma bordinha entre a foto e o app
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.card,
                  backgroundImage: _profileStore.profileImageProvider,
                  child: _profileStore.profileImageProvider == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: AppColors.secondary.withValues(alpha: 0.5),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
        
        // Espaço para compensar a foto descendo os -48 pixels
        const SizedBox(height: 56), 
        
        // Nome de Usuário
        const Text(
          'Gustavo Just',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3, // Aperta as letras ligeiramente (design moderno)
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '@gustavo',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        
        // Botão Editar Perfil
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.inputBorder, width: 1.2), // Borda fina cinza
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)), // Bem arredondado (pílula)
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            elevation: 0,
          ),
          child: const Text(
            'Editar perfil',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          ),
        ),
        const SizedBox(height: 16),
        
        // Biografia
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            'Lorem ipsum dolor sit amet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withValues(alpha: 0.85), // Quase preto, mais legível
              height: 1.55, // Aumenta o espaçamento entre as linhas da bio
            ),
          ),
        ),
        const SizedBox(height: 14),
        
        // Dados como Localização e Data de Ingresso
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            const Text(
              'Recife, PE',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 14),
            Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 3),
            const Text(
              'Jan 2024',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 18),
        
        // Seguindo / Seguidores (Estilo centralizado IG)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _StatItem(count: '128', label: 'Seguindo'),
            // Divisória vertical no meio dos stats
            Container(
              width: 1,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 28),
              color: AppColors.inputBorder.withValues(alpha: 0.5),
            ),
            const _StatItem(count: '342', label: 'Seguidores'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Função auxiliar que gera a ListView (lista de posts).
  Widget _buildPostsList(List<Map<String, dynamic>> posts, {required bool isOwn}) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: posts.length,
      // Para cada dado na lista 'posts', ele cria um widget _PostTile
      itemBuilder: (context, i) => _PostTile(
        post: posts[i],
        isOwn: isOwn, // Passamos isOwn para saber se o post é do perfil ou repost de terceiro
      ),
    );
  }
}

// Widget auxiliar para montar os números de "Seguidores" etc de forma limpa
class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count, // O Número em negrito
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label, // A palavra menor embaixo do número
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Classe obrigatória quando se usa 'SliverPersistentHeader' lá em cima no NestedScrollView.
// Diz ao Flutter como desenhar a barra, qual o tamanho e se deve redesenhar.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  const _TabBarDelegate({required this.tabController});

  @override
  double get minExtent => 48; // Altura mínima fixada da barra

  @override
  double get maxExtent => 48; // Altura máxima fixada (não estica ao puxar para baixo)

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background, // Mesma cor do fundo, para parecer nativa e contínua
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.cta, // Sublinhado laranja
        indicatorWeight: 3, // Grossura da linha sublinhada
        labelColor: AppColors.textPrimary, // Cor aba ativa
        unselectedLabelColor: AppColors.textSecondary, // Cor aba inativa
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        dividerColor: AppColors.inputBorder.withValues(alpha: 0.4), // Linha horizontal que separa a barra dos posts
        tabs: const [
          Tab(text: 'Postagens'), // Aba index 0
          Tab(text: 'Repostados'), // Aba index 1
        ],
      ),
    );
  }
}


// Widget que desenha cada post especificamente na TELA DE PERFIL.
// (É similar, mas mais simples que o _PostCard do Feed geral)
class _PostTile extends StatelessWidget {
  final Map<String, dynamic> post;
  final bool isOwn;

  const _PostTile({required this.post, required this.isOwn});

  bool get _isCurrentUserPost => post['handle'] == PostsStore.currentUserHandle;

  void _showDeleteConfirmation(BuildContext context) {
    final postId = post['id'] as String;
    showDialog(
      context: context,
      builder: (dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                PostsStore.instance.deletePost(postId);
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
    final name = isOwn ? PostsStore.currentUserName : post['name'] as String;
    final handle = isOwn ? PostsStore.currentUserHandle : post['handle'] as String;
    final initial = name[0];
    final liked = post['liked'] as bool;
    final likes = post['likes'] as int;
    final replies = post['replies'] as int;
    final replyList = post['replyList'] as List<Map<String, dynamic>>;
    final postId = post['id'] as String;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        // Adiciona apenas uma linha leve embaixo separando cada post (estilo lista plana de perfil).
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder.withValues(alpha: 0.25), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha tudo no topo (Avatar e Textos nascem do mesmo topo)
        children: [
          
          // O Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Fundo dinâmico dependendo de quem é o dono.
              color: isOwn
                  ? AppColors.secondary.withValues(alpha: 0.12)
                  : AppColors.cta.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: isOwn ? AppColors.secondary : AppColors.cta,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Todo o texto do post em uma coluna. (Expanded faz ocupar toda largura sobrando à direita)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Flexible + TextOverflow.ellipsis impede quebra de layout se o nome for gigante "Roberto de Carvalho Fonseca...". Ele cria os "..."
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      handle, // Ex: @gustavo
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      ' · ${post['time']}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const Spacer(),
                    if (_isCurrentUserPost)
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            size: 18,
                          ),
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
                const SizedBox(height: 8),
                
                // Texto do post
                Text(
                  post['content'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                PostReplyList(replies: replyList),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _ActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      count: replies,
                      onTap: () => showPostReplySheet(context, postId),
                    ),
                    const SizedBox(width: 28),
                    _ActionIcon(
                      icon: Icons.repeat_rounded,
                      count: likes ~/ 4,
                      onTap: () {},
                    ),
                    const SizedBox(width: 28),
                    _ActionIcon(
                      icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      count: likes,
                      color: liked ? const Color(0xFFE74C3C) : null,
                      onTap: () => PostsStore.instance.toggleLike(postId),
                    ),
                    const SizedBox(width: 28),
                    _ActionIcon(
                      icon: Icons.share_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para desenhar o ícone de ação (Like/Repost) pequenininho apenas com o número.
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color? color;
  final VoidCallback onTap;

  const _ActionIcon({required this.icon, this.count, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: c),
            // if (count != null) ... só adiciona o texto e o espaço na UI se passarmos um contador de likes.
            if (count != null) ...[
              const SizedBox(width: 5),
              Text(
                '$count',
                style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
