import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/bird_logo.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';

// A HomeScreen é o "esqueleto" principal depois que o usuário loga.
// É um StatefulWidget porque precisa gerenciar qual aba (feed, busca, perfil) está ativa no momento.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Guarda o índice da aba atual da BottomNavigationBar. 0 = Feed, 3 = Perfil.
  int _currentIndex = 0;
  
  // O ScaffoldKey é necessário para podermos abrir o Drawer (menu lateral) de forma programática,
  // ou seja, ao clicar em um botão da nossa BottomNavBar customizada, e não apenas na AppBar padrão.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de telas correspondentes a cada aba da navegação inferior.
  // Se remover a _SearchPlaceholder daqui, o app vai quebrar quando tentar acessar o index 1.
  final List<Widget> _pages = const [
    FeedScreen(),
    _SearchPlaceholder(), // Tela temporária de busca
    _NotificationsPlaceholder(), // Tela temporária de notificações
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Conectando a chave ao Scaffold para controlar o Drawer.
      backgroundColor: AppColors.background,
      
      // drawer: é o menu lateral deslizante (muito comum em apps Android).
      drawer: _AppDrawer(
        // Passamos uma função para o drawer saber o que fazer quando clicar em "Sair".
        onLogout: () {
          Navigator.of(context).pop(); // 1. Fecha o Drawer
          Navigator.pushReplacementNamed(context, '/login'); // 2. Volta para login apagando o histórico
        },
      ),
      
      // O corpo principal exibe a página correspondente ao índice atual selecionado.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: _pages[_currentIndex], // Troca a tela baseada no clique da barra de navegação
        ),
      ),
      
      // Botão flutuante (FAB) usado para criar nova postagem.
      // Foi colocado aqui no Scaffold da Home (e não dentro do Feed) para ficar sobreposto a todas as telas.
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: FloatingActionButton(
          onPressed: _showNewPost,
          backgroundColor: AppColors.cta, // Laranja
          elevation: 6,
          shape: const CircleBorder(), // Força a ser perfeitamente redondo
          child: const Icon(Icons.add_rounded, color: AppColors.white, size: 30),
        ),
      ),
      
      // Nossa barra de navegação inferior totalmente customizada
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        // Atualiza a tela chamando setState quando um ícone é clicado.
        onTap: (i) => setState(() => _currentIndex = i),
        // Abre o menu lateral quando necessário
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  // Abre a tela de "Nova Postagem" vindo de baixo para cima (BottomSheet)
  void _showNewPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que a folha cresça junto com o teclado
      backgroundColor: Colors.transparent, // Transparente para podermos arredondar as bordas superiores no widget filho
      builder: (_) => const _NewPostSheet(),
    );
  }
}

// Widget privado para o Menu Lateral (Drawer)
class _AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;
  const _AppDrawer({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.card,
      // Bordas arredondadas apenas do lado direito (já que ele abre da esquerda)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      // SafeArea impede que o menu fique por baixo do "notch" (câmera) do celular
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do Drawer com o nome e @ do usuário
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                // Gradiente escuro para dar um contraste legal
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar do usuário
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.15),
                          border: Border.all(color: AppColors.white.withValues(alpha: 0.25), width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'G', // Inicial do nome
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Pequeno logo do App no canto do cabeçalho
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const BirdLogo(size: 20, color: AppColors.beige),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Gustavo Just',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@gustavo',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.beige.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // Contadores de Seguindo/Seguidores
                  Row(
                    children: [
                      Text(
                        '128',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.white),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Seguindo',
                        style: TextStyle(color: AppColors.beige.withValues(alpha: 0.7), fontSize: 13),
                      ),
                      const SizedBox(width: 18),
                      Text(
                        '342',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.white),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Seguidores',
                        style: TextStyle(color: AppColors.beige.withValues(alpha: 0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Opções do menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _DrawerCard(
                    icon: Icons.person_outline_rounded,
                    iconBg: AppColors.accent.withValues(alpha: 0.12),
                    iconColor: AppColors.accent,
                    label: 'Perfil',
                    onTap: () => Navigator.pop(context), // Apenas fecha o menu por enquanto
                  ),
                  const SizedBox(height: 6),
                  _DrawerCard(
                    icon: Icons.settings_outlined,
                    iconBg: AppColors.cta.withValues(alpha: 0.12),
                    iconColor: AppColors.cta,
                    label: 'Configurações',
                    onTap: () {
                      Navigator.pop(context); // Fecha o drawer primeiro
                      Navigator.pushNamed(context, '/settings'); // Vai pra tela de configs
                    },
                  ),
                  const SizedBox(height: 6),
                  _DrawerCard(
                    icon: Icons.help_outline_rounded,
                    iconBg: AppColors.secondary.withValues(alpha: 0.12),
                    iconColor: AppColors.secondary,
                    label: 'Ajuda',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Spacer(), // Joga o botão de sair lá pro final da tela
            
            // Botão Sair
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DrawerCard(
                icon: Icons.logout_rounded,
                iconBg: AppColors.danger.withValues(alpha: 0.1),
                iconColor: AppColors.danger,
                label: 'Sair',
                labelColor: AppColors.danger,
                onTap: onLogout, // Chama a função que passamos lá em cima no HomeScreen
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// O Widget visual de cada item (card) do Menu Lateral.
class _DrawerCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _DrawerCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Material e InkWell formam o efeito de onda (ripple) quando você toca no item.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Quadrado arredondado com a cor de fundo do ícone
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Setinha indicando que é clicável
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: (labelColor ?? AppColors.textSecondary).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Barra de navegação inferior (Bottom NavBar) feita 100% à mão.
// Por que não usar o BottomNavigationBar padrão do Flutter?
// Porque queríamos um visual específico, cor fixa, e animação de clique customizada.
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback onMenu;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // Fundo marrom escuro
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2), // Sombra para cima
          ),
        ],
      ),
      // SafeArea bottom garante que a barra não fique escondida atrás da barra de gestos do iPhone/Android.
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Passamos index para cada ícone saber quando está ativo
              _NavIcon(icon: Icons.home_rounded, index: 0, current: currentIndex, onTap: onTap),
              _NavIcon(icon: Icons.search_rounded, index: 1, current: currentIndex, onTap: onTap),
              _NavIcon(icon: Icons.notifications_none_rounded, index: 2, current: currentIndex, onTap: onTap),
              _NavIcon(icon: Icons.person_outline_rounded, index: 3, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

// Ícone individual da Bottom NavBar com animação
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int current; // Qual o índice atualmente selecionado na Home?
  final void Function(int) onTap;

  const _NavIcon({
    required this.icon,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    
    // GestureDetector captura o toque. HitTestBehavior.opaque garante que clicar no espaço em volta do ícone também funciona.
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      // AnimatedContainer e AnimatedScale fazem o ícone aumentar (dar um pulo) e mudar de cor suavemente ao clicar.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0, // Fica 15% maior se estiver ativo
          duration: const Duration(milliseconds: 200),
          child: Icon(
            icon,
            size: 26,
            color: isActive ? AppColors.accent : AppColors.beige, // Verde se ativo, Bege se inativo
          ),
        ),
      ),
    );
  }
}


// --- TELAS PLACEHOLDER (Temporárias) --- //
// Como ainda não programamos as telas de Busca e Notificações de verdade, usamos esses placeholders.
// Sem eles, ao clicar nas abas, o app quebraria.

class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fake AppBar
        Container(
          height: 72 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
          child: const Center(
            child: Text(
              'Buscar',
              style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_rounded, size: 56, color: AppColors.inputBorder),
                SizedBox(height: 16),
                Text(
                  'Busca em breve',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsPlaceholder extends StatelessWidget {
  const _NotificationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 72 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
          child: const Center(
            child: Text(
              'Notificações',
              style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.inputBorder),
                SizedBox(height: 16),
                Text(
                  'Notificações em breve',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Widget da tela que desliza de baixo para cima para escrever uma nova postagem.
class _NewPostSheet extends StatelessWidget {
  const _NewPostSheet();

  @override
  Widget build(BuildContext context) {
    // DraggableScrollableSheet permite que a tela possa ser arrastada e feche quando desliza muito pra baixo.
    return DraggableScrollableSheet(
      initialChildSize: 0.75, // Ocupa 75% da tela inicialmente
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          // EdgeInsets que considera o tamanho do teclado na parte inferior (viewInsets.bottom)
          // Isso impede que o teclado cubra os botões.
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              // O "puxador" visual no topo (aquele tracinho cinza)
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              
              // Cabeçalho (Cancelar / Título / Publicar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Text(
                    'Nova postagem',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 17),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cta,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Área de digitação
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar de quem está postando
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    child: const Text(
                      'G',
                      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Campo de texto principal
                  Expanded(
                    child: TextField(
                      autofocus: true, // Já abre o teclado direto
                      maxLines: null, // Cresce infinitamente conforme digita
                      decoration: const InputDecoration(
                        hintText: 'O que está acontecendo?',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 17),
                        border: InputBorder.none, // Remove aquela linha padrão embaixo
                      ),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, height: 1.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
