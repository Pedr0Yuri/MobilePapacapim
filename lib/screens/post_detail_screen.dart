import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/api_exception.dart';
import '../data/posts_store.dart';
import '../widgets/user_avatar.dart';
import 'profile_screen.dart';

// Detalhes do post.
class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostsStore _store = PostsStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChanged);
    // Carrega as respostas reais da API ao abrir a tela.
    _store.loadReplies(widget.postId);
  }

  @override
  void dispose() {
    _store.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final post = _store.findPost(widget.postId);

    if (post == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.primary, elevation: 0),
        body: const Center(child: Text('Postagem não encontrada.', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.beige, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Postagem', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 22)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ProfileScreen(name: post['name'], handle: post['handle']))),
                            child: UserAvatar(
                              imageUrl: post['profileImage'] as String?,
                              handle: post['handle'] as String?,
                              radius: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ProfileScreen(name: post['name'], handle: post['handle']))),
                                  child: Text(post['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                ),
                                Text(post['handle'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              ],
                            ),
                          ),
                          if (post['handle'] == PostsStore.currentUserHandle)
                            SizedBox(
                              width: 32, height: 32,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
                                color: AppColors.card,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                onSelected: (val) {
                                  if (val == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
                                        content: const Text('Excluir esta postagem?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(ctx);
                                              try {
                                                await _store.deletePost(post['id']);
                                                if (!context.mounted) return;
                                                Navigator.pop(context);
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
                                            child: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: AppColors.danger, size: 20), SizedBox(width: 10), Text('Excluir', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600))])),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(post['content'], style: const TextStyle(fontSize: 18, height: 1.5)),
                      const SizedBox(height: 16),
                      Text(post['time'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.inputBorder.withValues(alpha: 0.3), height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 22, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(post['replies'].toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _store.toggleLike(post['id']),
                            child: Row(
                              children: [
                                Icon(
                                  post['liked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                                  size: 22, 
                                  color: post['liked'] ? AppColors.likeRed : AppColors.textSecondary
                                ),
                                const SizedBox(width: 8),
                                Text(post['likes'].toString(), style: TextStyle(color: post['liked'] ? AppColors.likeRed : AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.inputBorder.withValues(alpha: 0.3), height: 1),
                      const SizedBox(height: 16),
                      if ((post['replyList'] as List).isNotEmpty)
                        const Text('Comentários', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      PostReplyList(
                        replies: post['replyList'],
                        onReplyAdded: () => _store.loadReplies(widget.postId),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: GestureDetector(
                  onTap: () async {
                    final result = await showPostReplySheet(context, post['id']);
                    if (result == true && mounted) {
                      _store.loadReplies(widget.postId);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        UserAvatar(
                          handle: PostsStore.currentUserHandle,
                          radius: 14,
                        ),
                        const SizedBox(width: 12),
                        const Text('Escreva sua resposta...', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
