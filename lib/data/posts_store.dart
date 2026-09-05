import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'api_exception.dart';
import 'repositories/posts_repository.dart';
import 'repositories/users_repository.dart';
import 'session_store.dart';
import '../widgets/user_avatar.dart';
import '../screens/post_detail_screen.dart';

// Store de publicações com integração à API.
class PostsStore extends ChangeNotifier {
  PostsStore._();

  static final PostsStore instance = PostsStore._();

  final PostsRepository _postsRepository = PostsRepository.instance;
  final UsersRepository _usersRepository = UsersRepository.instance;

  // Pegamos o usuário logado lá do SessionStore pra não precisar mockar mais.
  static String get currentUserName =>
      SessionStore.instance.name ?? SessionStore.instance.userLogin ?? '';
  static String get currentUserHandle =>
      '@${SessionStore.instance.userLogin ?? ''}';
 

  bool isLoadingFeed = false;
  String? feedError;
 
  // Ids das postagens retornadas por GET /posts?feed=1 (postagens de quem você segue). Usado para separar as abas "Todos" / "Seguindo" do feed com dados reais da API.
  Set<String> _followingPostIds = {};
 
  List<String> followedHandles = [];
 
  bool isFollowedAuthor(String handle) => followedHandles.contains(handle);
 
  // Essa lista filtra o feed pegando só os ids que a API retornou pra aba de Seguindo, assim a gente aproveita o cache.
  List<Map<String, dynamic>> get followedFeedPosts => posts
      .where((post) => _followingPostIds.contains(post['id']))
      .take(currentFeedPage * 12)
      .toList();
 
  List<Map<String, dynamic>> get recommendedFeedPosts => posts
      .where((post) => !_followingPostIds.contains(post['id']))
      .take(currentFeedPage * 12)
      .toList();
 
  final List<Map<String, dynamic>> posts = [];
 
  // Aqui a gente limita visualmente pra renderizar no máximo 12 posts de cada vez (currentFeedPage * 12). Se a API mandar 50 de uma vez, a gente não trava a home. O botão "Ver mais" vai liberando o resto.
  List<Map<String, dynamic>> get visiblePosts => posts.take(currentFeedPage * 12).toList();
 
  // Carrega o feed a partir da API.
  Future<void> loadFeed() async {
    isLoadingFeed = true;
    feedError = null;
    currentFeedPage = 1;
    notifyListeners();
 
    try {
      final results = await Future.wait([
        _postsRepository.getFeed(limit: 12),
        _postsRepository.getFeed(followingOnly: true, limit: 12),
      ]);
      final allPosts = results[0];
      final followingPosts = results[1];
 
      // Monta a lista única de posts (fonte de verdade usada por toda a
      // UI), evitando duplicar um post que apareça nas duas respostas.
      final byId = <String, Map<String, dynamic>>{
        for (final post in allPosts) post.id.toString(): post.toUiMap(),
      };
      for (final post in followingPosts) {
        byId.putIfAbsent(post.id.toString(), () => post.toUiMap());
      }
 
      posts
        ..clear()
        ..addAll(byId.values);

      posts.sort((a, b) {
        final dateA = a['createdAt'] != null ? DateTime.tryParse(a['createdAt'] as String) : null;
        final dateB = b['createdAt'] != null ? DateTime.tryParse(b['createdAt'] as String) : null;
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        }
        return 0;
      });
 
      _followingPostIds = followingPosts.map((p) => p.id.toString()).toSet();
    } on ApiException catch (e) {
      feedError = e.message;
    } finally {
      isLoadingFeed = false;
      notifyListeners();
    }
  }

  bool isLoadingMoreFeed = false;
  int currentFeedPage = 1;

  Future<void> loadMoreFeed() async {
    if (isLoadingMoreFeed) return;
    isLoadingMoreFeed = true;
    notifyListeners();
 
    try {
      currentFeedPage++;
      final results = await Future.wait([
        _postsRepository.getFeed(page: currentFeedPage, limit: 12),
        _postsRepository.getFeed(followingOnly: true, page: currentFeedPage, limit: 12),
      ]);
      final allPosts = results[0];
      final followingPosts = results[1];
 
      if (allPosts.isEmpty && followingPosts.isEmpty) {
        currentFeedPage--; // Volta a página se a API não mandar mais nada
        return;
      }

      final byId = <String, Map<String, dynamic>>{
        for (final post in posts) post['id'].toString(): post,
      };
      for (final post in allPosts) {
        byId.putIfAbsent(post.id.toString(), () => post.toUiMap());
      }
      for (final post in followingPosts) {
        byId.putIfAbsent(post.id.toString(), () => post.toUiMap());
      }
 
      posts
        ..clear()
        ..addAll(byId.values);

      posts.sort((a, b) {
        final dateA = a['createdAt'] != null ? DateTime.tryParse(a['createdAt'] as String) : null;
        final dateB = b['createdAt'] != null ? DateTime.tryParse(b['createdAt'] as String) : null;
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        }
        return 0;
      });
 
      _followingPostIds.addAll(followingPosts.map((p) => p.id.toString()));
    } on ApiException {
      currentFeedPage--;
    } finally {
      isLoadingMoreFeed = false;
      notifyListeners();
    }
  }
 
  List<Map<String, dynamic>> get ownPosts =>
      posts.where((post) => post['handle'] == currentUserHandle).toList();
 
  // Criei esse cache isolado pra consertar aquele erro de abrir um post pela tela de pesquisa/perfil e ele não carregar os dados completos.
  final Map<String, Map<String, dynamic>> _isolatedPosts = {};

  void cacheIsolatedPost(Map<String, dynamic> post) {
    if (_findPostOrReply(post['id'], posts) == null) {
      _isolatedPosts[post['id']] = post;
    }
  }

  Map<String, dynamic>? findPost(String id) {
    return _findPostOrReply(id, posts) ?? _findPostOrReply(id, _isolatedPosts.values.toList());
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
 
  Future<void> addPost(String content) async {
    try {
      final newPost = await _postsRepository.createPost(content);
      posts.insert(0, newPost.toUiMap());
      notifyListeners();
    } on ApiException {
      rethrow;
    }
  }
 
  Future<void> deletePost(String id) async {
    try {
      await _postsRepository.deletePost(id);
      posts.removeWhere((post) => post['id'] == id);
      notifyListeners();
    } on ApiException {
      rethrow;
    }
  }
 
  void deleteReply(String id) {
    _deleteReplyRecursively(id, posts);
    notifyListeners();
  }
 
  bool _deleteReplyRecursively(String id, List<Map<String, dynamic>> currentList) {
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
        if (_deleteReplyRecursively(id, replyList)) return true;
      }
    }
    return false;
  }
 
  Future<void> toggleLike(String id) async {
    final post = findPost(id);
    if (post == null) return;
 
    final liked = post['liked'] as bool;

    // Atualiza otimisticamente a UI antes da resposta da API.
    post['liked'] = !liked;
    post['likes'] = (post['likes'] as int) + (liked ? -1 : 1);
    notifyListeners();

    try {
      if (liked) {
        await _postsRepository.unlikePost(id);
      } else {
        await _postsRepository.likePost(id);
      }
    } on ApiException {
      // Reverte em caso de erro.
      post['liked'] = liked;
      post['likes'] = (post['likes'] as int) + (liked ? 1 : -1);
      notifyListeners();
    }
  }
 
  Future<void> toggleFollow(String handle) async {
    // Remove o @ do handle para obter o login.
    final login = handle.startsWith('@') ? handle.substring(1) : handle;
    final wasFollowing = followedHandles.contains(handle);

    // Atualiza otimisticamente.
    if (wasFollowing) {
      followedHandles.remove(handle);
    } else {
      followedHandles.add(handle);
    }
    notifyListeners();

    try {
      if (wasFollowing) {
        await _usersRepository.unfollowUser(login);
      } else {
        await _usersRepository.followUser(login);
      }
    } on ApiException {
      // Reverte em caso de erro.
      if (wasFollowing) {
        followedHandles.add(handle);
      } else {
        followedHandles.remove(handle);
      }
      notifyListeners();
    }
  }
 
  Future<void> addReply(String id, String content) async {
    try {
      final reply = await _postsRepository.createReply(id, content);
      final post = findPost(id);
      if (post != null) {
        final replyList = post['replyList'] as List<Map<String, dynamic>>;
        replyList.insert(0, reply.toUiMap());
        post['replies'] = (post['replies'] as int) + 1;
        notifyListeners();
      }
    } on ApiException {
      rethrow;
    }
  }

  Future<void> loadReplies(String postId) async {
    try {
      final replies = await _postsRepository.getReplies(postId);
      final post = findPost(postId);
      if (post != null) {
        final replyList = post['replyList'] as List<Map<String, dynamic>>;
        replyList.clear();
        replyList.addAll(replies.map((r) => r.toUiMap()));
        notifyListeners();
      }
    } on ApiException {
      // Ignora silenciosamente, replies continuam vazias.
    }
  }
}
 
// Navega para a tela de resposta em modo fullscreen para evitar conflitos de teclado.
Future<bool?> showPostReplySheet(BuildContext context, String postId, {String? initialText}) {
  return Navigator.of(context, rootNavigator: true).push<bool>(
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
  bool _isSending = false;
 
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

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await PostsStore.instance.addReply(widget.postId, text);
      if (mounted) Navigator.of(context, rootNavigator: true).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
              onPressed: _isSending ? null : _handleSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cta,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.white)),
                    )
                  : const Text('Enviar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              handle: PostsStore.currentUserHandle,
              radius: 21,
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

// Componente visual que renderiza as respostas de forma recursiva (efeito escadinha).
class PostReplyList extends StatelessWidget {
  final List<Map<String, dynamic>> replies;
  final int depth;
  final VoidCallback? onReplyAdded;

  const PostReplyList({super.key, required this.replies, this.depth = 0, this.onReplyAdded});

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (depth == 0) const SizedBox(height: 14),
        ...replies.map(
          (reply) {
            // Limita a escadinha a 3 níveis para não dar overflow na tela
            return Padding(
              padding: EdgeInsets.only(left: depth == 0 ? 0 : (depth <= 3 ? 16.0 : 0.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: reply['id']),
                        ),
                      );
                    },
                    child: Container(
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
                        UserAvatar(
                          imageUrl: reply['profileImage'] as String?,
                          handle: reply['handle'] as String?,
                          radius: 16,
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
                                                    onPressed: () async {
                                                      try {
                                                        await PostsStore.instance.deletePost(reply['id']);
                                                      } on ApiException {
                                                        // Erro silenciado — a UI já removeu
                                                      }
                                                      if (ctx.mounted) Navigator.pop(ctx);
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PostDetailScreen(postId: reply['id']),
                                          ),
                                        );
                                      },
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
                ),
                ],
              ),
            );
          },
        ),
        ],
      );
    }
  }
