import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/posts_store.dart';
import '../data/profile_store.dart';

/// O [PostCard] é o widget central para renderizar uma postagem no app.
///
/// POR QUE CRIAMOS ESSE WIDGET? (Refatoração)
/// Antes, o código de UI da postagem estava duplicado em 3 telas diferentes:
/// Feed, Perfil e Pesquisa. Isso violava o princípio DRY (Don't Repeat Yourself).
/// Extraindo para cá, qualquer mudança visual (ex: tamanho da fonte) é feita
/// apenas uma vez, e o app inteiro é atualizado automaticamente.
///
/// COMO AS COISAS SE COMUNICAM:
/// Este widget é "burro" (Stateless). Ele apenas recebe os dados da postagem (`post`)
/// e os callbacks (funções) do que fazer quando o usuário interage. Quem gerencia
/// a navegação ou as curtidas é a tela pai (Feed, Perfil, etc) que chama esse widget.
class PostCard extends StatelessWidget {
  /// Os dados da postagem (texto, curtidas, handle, etc).
  final Map<String, dynamic> post;

  /// Se [isSimplified] for true, ocultamos a barra inferior de curtir/comentar.
  /// Usamos isso na tela de pesquisa, onde queremos uma visualização mais enxuta.
  final bool isSimplified;

  /// Ação disparada quando o usuário clica no corpo da postagem (abre os detalhes).
  final VoidCallback? onTap;

  /// Ação disparada ao clicar na foto ou nome do usuário.
  final VoidCallback? onProfileTap;

  /// Ação disparada ao clicar no botão de curtir.
  final VoidCallback? onLike;

  /// Ação disparada ao clicar no botão de responder/comentar.
  final VoidCallback? onReply;

  /// Ação disparada quando o próprio autor da postagem decide excluí-la.
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.isSimplified = false,
    this.onTap,
    this.onProfileTap,
    this.onLike,
    this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos um GestureDetector para capturar o toque no card inteiro
    // e navegar para a tela de detalhes.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card, // Fundo branquinho padrão do nosso Design System
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Sombra leve para dar profundidade, separando o card do fundo
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
            // Cabelho da postagem: Foto, Nome, Handle e Menu (se for o dono)
            _buildHeader(context),
            const SizedBox(height: 12),
            
            // O corpo da postagem. Usamos height: 1.55 para melhorar a legibilidade.
            Text(
              post['content'],
              style: const TextStyle(fontSize: 15, height: 1.55),
            ),
            const SizedBox(height: 14),
            
            // Rodapé: Curtidas e Comentários.
            // Só renderizamos se NÃO for simplificado.
            if (!isSimplified) _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Constrói o cabeçalho (Foto, Nome, Usuário, Data e Ícone de Deletar)
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usamos um GestureDetector também no avatar para permitir
        // ir para o perfil da pessoa clicando na foto dela.
        GestureDetector(
          onTap: onProfileTap,
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  final isMe = post['handle'] == PostsStore.currentUserHandle;
                  final img = isMe ? ProfileStore.instance.profileImageProvider : null;

                  return CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    backgroundImage: img,
                    child: img == null
                        ? Icon(
                            Icons.person,
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            size: 24,
                          )
                        : null,
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    post['handle'],
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Spacer empurra a data e o botão de delete para a extremidade direita
        const Spacer(),
        
        Text(
          post['time'],
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        
        // Se a postagem for nossa, mostramos os três pontinhos para excluir.
        // A lógica de exclusão é delegada ao callback [onDelete].
        if (post['handle'] == PostsStore.currentUserHandle && onDelete != null)
          SizedBox(
            width: 32,
            height: 32,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
                size: 20,
              ),
              color: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (val) {
                if (val == 'delete') {
                  // Ao invés de deletar diretamente aqui, avisamos o pai
                  onDelete!();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                      SizedBox(width: 10),
                      Text('Excluir', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Constrói o rodapé com os botões interativos (Curtir e Responder)
  Widget _buildFooter() {
    return Row(
      children: [
        // Botão de curtir. Usamos InkWell para o efeito de onda (ripple) nativo.
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  post['liked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  // Aqui usamos a constante global refatorada AppColors.likeRed
                  color: post['liked'] ? AppColors.likeRed : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  post['likes'].toString(),
                  style: TextStyle(
                    color: post['liked'] ? AppColors.likeRed : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 28),
        
        // Botão de responder.
        InkWell(
          onTap: onReply,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  post['replies'].toString(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
