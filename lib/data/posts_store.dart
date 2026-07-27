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
    for (final post in posts) {
      if (post['id'] == id) return post;
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
    replyList.add({
      'name': currentUserName,
      'handle': currentUserHandle,
      'content': content,
      'time': 'agora',
    });
    post['replies'] = (post['replies'] as int) + 1;
    notifyListeners();
  }
}

// Bottom sheet reutilizado pelo Feed e pelo Perfil para responder um post.
void showPostReplySheet(BuildContext context, String postId) {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  // Pede o foco só depois que o sheet terminou de montar.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    focusNode.requestFocus();
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.inputBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Text(
                        'Responder',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 17,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;

                          // Sem await: unfocus e pop no mesmo frame.
                          focusNode.unfocus();
                          Navigator.pop(sheetContext);
                          PostsStore.instance.addReply(postId, text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Enviar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final img =
                                  ProfileStore.instance.profileImageProvider;
                              return CircleAvatar(
                                radius: 21,
                                backgroundColor: AppColors.secondary.withValues(
                                  alpha: 0.15,
                                ),
                                backgroundImage: img,
                                child: img == null
                                    ? Icon(
                                        Icons.person,
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.5,
                                        ),
                                        size: 24,
                                      )
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Escreva sua resposta...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  ).whenComplete(() {
    controller.dispose();
    focusNode.dispose();
  });
}

// Lista compacta de respostas exibida abaixo do conteúdo do post.
class PostReplyList extends StatelessWidget {
  final List<Map<String, dynamic>> replies;

  const PostReplyList({super.key, required this.replies});

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        // Depois de enviar, mostro as respostas junto com o post.
        ...replies.map(
          (reply) => Container(
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
                    final isMe =
                        reply['handle'] == PostsStore.currentUserHandle;
                    final img = isMe
                        ? ProfileStore.instance.profileImageProvider
                        : null;
                    return CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.15,
                      ),
                      backgroundImage: img,
                      child: img == null
                          ? Icon(
                              Icons.person,
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              size: 18,
                            )
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
                        children: [
                          Text(
                            reply['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            reply['handle'] as String,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· ${reply['time']}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reply['content'] as String,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
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
