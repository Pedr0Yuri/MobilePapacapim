import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/profile_store.dart';

// Guarda os posts em memória enquanto o app está aberto, simulando o back-end.
class PostsStore extends ChangeNotifier {
  PostsStore._();

  static final PostsStore instance = PostsStore._();

  static const String currentUserName = 'Pedr0Yuri';
  static const String currentUserHandle = '@Pedr0Yuri';

  // IDs dos posts repostados.
  static const List<String> repostedPostIds = ['2', '3'];

  // Handles mockados de perfis que o usuário logado segue (sem API).
  List<String> followedHandles = ['@GeovaniCardeal'];

  bool isFollowedAuthor(String handle) => followedHandles.contains(handle);

  List<Map<String, dynamic>> get followedFeedPosts => posts
      .where((post) => isFollowedAuthor(post['handle'] as String))
      .toList();

  List<Map<String, dynamic>> get recommendedFeedPosts => posts
      .where((post) => !isFollowedAuthor(post['handle'] as String))
      .toList();

  final List<Map<String, dynamic>> posts = [
    {
      'id': '1',
      'name': 'Pedr0Yuri',
      'handle': '@Pedr0Yuri',
      'time': '2m',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 24,
      'replies': 5,
      'liked': false,
      'replyList': <Map<String, dynamic>>[],
    },
    {
      'id': '2',
      'name': 'Geovani Cardeal',
      'handle': '@GeovaniCardeal',
      'time': '18m',
      'content': 'ola mundo',
      'likes': 12,
      'replies': 3,
      'liked': true,
      'replyList': <Map<String, dynamic>>[],
    },
    {
      'id': '3',
      'name': 'Nadson',
      'handle': '@JesusÉoCaminho',
      'time': '45m',
      'content': 'ola mundo',
      'likes': 89,
      'replies': 14,
      'liked': false,
      'replyList': <Map<String, dynamic>>[],
    },
    {
      'id': '4',
      'name': 'Zoe Sabina',
      'handle': '@Zozoze',
      'time': '1h',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 57,
      'replies': 8,
      'liked': false,
      'replyList': <Map<String, dynamic>>[],
    },
    {
      'id': '5',
      'name': 'Ana Bia',
      'handle': '@biaAragao',
      'time': '2h',
      'content': 'Lorem ipsum dolor sit amet',
      'likes': 134,
      'replies': 22,
      'liked': true,
      'replyList': <Map<String, dynamic>>[],
    },
  ];

  List<Map<String, dynamic>> get ownPosts =>
      posts.where((post) => post['handle'] == currentUserHandle).toList();

  List<Map<String, dynamic>> get repostedPosts =>
      posts.where((post) => repostedPostIds.contains(post['id'])).toList();

  Map<String, dynamic>? findPost(String id) {
    return _findPostOrReply(id, posts);
  }

  Map<String, dynamic>? _findPostOrReply(String id, List<Map<String, dynamic>> currentList) {
    for (final item in currentList) {
      if (item['id'] == id) return item;
      if (item['replyList'] != null) {
        final found = _findPostOrReply(id, item['replyList'] as List<Map<String, dynamic>>);
        if (found != null) return found;
      }
    }
    return null;
  }

  // Nova postagem vai pro topo do feed com os dados mockados do usuário logado.
  void addPost(String content) {
    posts.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': currentUserName,
      'handle': currentUserHandle,
      'time': 'agora',
      'content': content,
      'likes': 0,
      'replies': 0,
      'liked': false,
      'replyList': <Map<String, dynamic>>[],
    });
    notifyListeners();
  }

  void deletePost(String id) {
    posts.removeWhere((post) => post['id'] == id);
    notifyListeners();
  }

  void deleteReply(String id) {
    _deleteReplyRec(id, posts);
    notifyListeners();
  }

  bool _deleteReplyRec(String id, List<Map<String, dynamic>> currentList) {
    for (var item in currentList) {
      if (item['replyList'] != null) {
        final replyList = item['replyList'] as List<Map<String, dynamic>>;
        final index = replyList.indexWhere((r) => r['id'] == id);
        if (index != -1) {
          replyList.removeAt(index);
          item['replies'] = (item['replies'] as int) - 1;
          if ((item['replies'] as int) < 0) item['replies'] = 0;
          return true;
        }
        if (_deleteReplyRec(id, replyList)) return true;
      }
    }
    return false;
  }

  // Curtida fica centralizada aqui pra refletir igual no Feed e no Perfil.
  void toggleLike(String id) {
    final post = findPost(id);
    if (post == null) return;

    final liked = post['liked'] as bool;
    post['liked'] = !liked;
    post['likes'] = (post['likes'] as int) + (liked ? -1 : 1);
    notifyListeners();
  }

  void toggleFollow(String handle) {
    if (followedHandles.contains(handle)) {
      followedHandles.remove(handle);
    } else {
      followedHandles.add(handle);
    }
    notifyListeners();
  }

  void addReply(String id, String content) {
    final post = findPost(id);
    if (post == null) return;

    final replyList = post['replyList'] as List<Map<String, dynamic>>;
    replyList.insert(0, {
      'id': 'reply_${DateTime.now().millisecondsSinceEpoch}',
      'name': currentUserName,
      'handle': currentUserHandle,
      'content': content,
      'time': 'agora',
      'likes': 0,
      'liked': false,
      'replies': 0,
      'replyList': <Map<String, dynamic>>[],
    });
    post['replies'] = (post['replies'] as int) + 1;
    notifyListeners();
  }
}

// Abre a tela de resposta como rota completa (evita bug de modal + teclado no Android).
void showPostReplySheet(BuildContext context, String postId, {String? initialText}) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _ReplyScreen(postId: postId, initialText: initialText),
    ),
  );
}

class _ReplyScreen extends StatefulWidget {
  final String postId;
  final String? initialText;
  const _ReplyScreen({required this.postId, this.initialText});

  @override
  State<_ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<_ReplyScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        leadingWidth: 100,
        title: const Text(
          'Responder',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  PostsStore.instance.addReply(widget.postId, text);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text('Enviar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final img = ProfileStore.instance.profileImageProvider;
                return CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                  backgroundImage: img,
                  child: img == null
                      ? Icon(Icons.person, color: AppColors.secondary.withValues(alpha: 0.5), size: 24)
                      : null,
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua resposta...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 17,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 17, height: 1.5, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Lista de respostas exibida abaixo do conteúdo do post (recursiva para "escadinha").
class PostReplyList extends StatelessWidget {
  final List<Map<String, dynamic>> replies;
  final double indent;

  const PostReplyList({super.key, required this.replies, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (indent == 0) const SizedBox(height: 14),
        ...replies.map(
          (reply) {
            final hasNestedReplies = (reply['replyList'] as List?)?.isNotEmpty ?? false;
            
            return Padding(
              padding: EdgeInsets.only(left: indent == 0 ? 0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBg.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final isMe = reply['handle'] == PostsStore.currentUserHandle;
                            final img = isMe ? ProfileStore.instance.profileImageProvider : null;
                            return CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                              backgroundImage: img,
                              child: img == null
                                  ? Icon(Icons.person, color: AppColors.secondary.withValues(alpha: 0.5), size: 18)
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            reply['name'] as String,
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            reply['handle'] as String,
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '· ${reply['time']}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (reply['handle'] == PostsStore.currentUserHandle)
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 16),
                                        color: AppColors.card,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        onSelected: (val) {
                                          if (val == 'delete') {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
                                                content: const Text('Excluir este comentário?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                                  TextButton(
                                                    onPressed: () { 
                                                      PostsStore.instance.deleteReply(reply['id']); 
                                                      Navigator.pop(ctx); 
                                                    }, 
                                                    child: const Text('Excluir', style: TextStyle(color: AppColors.danger))
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'delete', 
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, color: AppColors.danger, size: 18), 
                                                SizedBox(width: 8), 
                                                Text('Excluir', style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600))
                                              ]
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reply['content'] as String,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.45),
                              ),
                              const SizedBox(height: 8),
                              // Botões Curtir e Responder
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => PostsStore.instance.toggleLike(reply['id']),
                                    child: Row(
                                      children: [
                                        Icon(
                                          (reply['liked'] ?? false) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          size: 16,
                                          color: (reply['liked'] ?? false) ? AppColors.likeRed : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${reply['likes'] ?? 0}',
                                          style: TextStyle(
                                            color: (reply['liked'] ?? false) ? AppColors.likeRed : AppColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () => showPostReplySheet(context, reply['id']),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${reply['replies'] ?? 0}',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasNestedReplies)
                    PostReplyList(replies: reply['replyList'], indent: indent + 16),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
