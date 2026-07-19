import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/bird_logo.dart';

// Tela principal do feed (onde os posts aparecem).
// É um StatelessWidget porque a lista geral não muda seu estado interno de forma complexa nesta versão básica.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  // Lista estática simulando dados vindos de um banco de dados/API.
  static const List<Map<String, dynamic>> _posts = [
    {
      'name': 'Gustavo Just',
      'handle': '@gustavo',
      'time': '2m',
      'content': 'Lorem ipsum dolor sit amet', // Substituído por lorem ipsum a pedido
      'likes': 24,
      'replies': 5,
      'liked': false,
    },
    {
      'name': 'Mariana Silva',
      'handle': '@mariana_dev',
      'time': '18m',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 12,
      'replies': 3,
      'liked': true,
    },
    {
      'name': 'Carlos Neto',
      'handle': '@carlos.neto',
      'time': '45m',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 89,
      'replies': 14,
      'liked': false,
    },
    {
      'name': 'Ana Flores',
      'handle': '@anaflores',
      'time': '1h',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 57,
      'replies': 8,
      'liked': false,
    },
    {
      'name': 'Rafael Costa',
      'handle': '@rafacosta',
      'time': '2h',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 134,
      'replies': 22,
      'liked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Usamos Column para empilhar o Header customizado e a lista de posts.
    return Column(
      children: [
        _FeedHeader(), // Nosso AppBar customizado
        
        // Expanded diz para a ListView ocupar todo o espaço restante da tela.
        // Se tirarmos o Expanded, o Flutter não sabe qual a altura da ListView e a tela quebra (dá erro de renderização).
        Expanded(
          // ListView.builder é excelente para performance, pois só renderiza os itens que estão aparecendo na tela.
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: _posts.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _PostCard(post: _posts[i]), // Passa o dado da lista pro widget que desenha o card
            ),
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
      // A altura precisa considerar o "notch" e a barra de status do celular (MediaQuery.padding.top).
      // Se tirarmos isso, a barra fica grudada ou cortada no topo da tela em alguns celulares.
      height: 72 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 12,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          // Sombreamento leve para separar o cabeçalho do conteúdo rolável
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão de menu (hambúrguer)
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.beige, size: 24),
            // Scaffold.of(context) sobe na árvore de widgets até achar o Scaffold (na HomeScreen) para abrir o Drawer lateral.
            onPressed: () => Scaffold.of(context).openDrawer(),
            splashRadius: 22, // Limita o tamanho do efeito de clique (bolinha cinza)
          ),
          // Expanded empurra o texto para o centro usando o espaço livre
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo do pássaro pequeno
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
          // Esse SizedBox de 48 balanceia o espaço do IconButton da esquerda, mantendo o título perfeitamente no centro geométrico.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// Widget que representa cada Post no feed.
// É um StatefulWidget pois gerencia seu próprio estado de "curtidas".
class _PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late bool liked;
  late int likes;

  // Roda uma única vez quando o widget é criado, inicializando os valores com base no Map recebido.
  @override
  void initState() {
    super.initState();
    liked = widget.post['liked'] as bool;
    likes = widget.post['likes'] as int;
  }

  // Função para dar Like/Deslike
  void _toggleLike() {
    setState(() {
      liked = !liked; // Inverte o booleano
      likes = liked ? likes + 1 : likes - 1; // Se agora está curtido, +1. Senão, -1.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Design tipo Card (caixa branca com sombra)
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
          // Linha superior: Avatar, Nome, @handle, tempo e botão 'mais'
          Row(
            children: [
              // Avatar com a inicial do nome
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  (widget.post['name'] as String)[0], // Pega a primeira letra da string do nome
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
              const SizedBox(width: 8),
              // Botão de 3 pontinhos para opções (ex: excluir/denunciar post)
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
                  onPressed: () {},
                  splashRadius: 16,
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // O conteúdo do post (texto)
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
          
          // Barra de ações (Curtir, Repostar, Responder)
          Row(
            children: [
              // Botão de Curtir
              _CardActionButton(
                icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: 'Curtir',
                count: likes,
                active: liked,
                activeColor: const Color(0xFFE74C3C), // Vermelho vivo para likes
                onTap: _toggleLike, // Chama a função que atualiza o estado
              ),
              const SizedBox(width: 12),
              // Botão de Repostar
              _CardActionButton(
                icon: Icons.repeat_rounded,
                label: 'Repostar',
                count: (widget.post['likes'] as int) ~/ 4, // Simulando número de reposts matematicamente pra não criar nova prop no BD local
                active: false,
                activeColor: AppColors.accent,
                onTap: () {},
              ),
              const SizedBox(width: 12),
              // Botão de Responder
              _CardActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Responder',
                count: widget.post['replies'] as int,
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

// Widget auxiliar para não repetir o código dos botões de ação na base de cada Post.
class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool active; // Indica se foi clicado (ex: já curtiu)
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
    // A cor será a ativa (vermelho/verde) ou a secundária neutra (cinza).
    final color = active ? activeColor : AppColors.textSecondary;
    return Material(
      color: Colors.transparent, // Impede que o botão fique com um quadrado branco ao redor
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
                label, // Troque por "$count" se quiser exibir só o número como no Twitter
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
