import '../api_cliente.dart';
import '../models/post.dart';
import '../session_store.dart';
import '../profile_store.dart';

/// Sabe conversar com os endpoints de postagens (`/posts`) da API Papacapim.

class PostsRepository {
  PostsRepository._();
  static final PostsRepository instance = PostsRepository._();

  final ApiClient _client = ApiClient.instance;

  /// Lista/busca postagens.
  /// Endpoint: GET /posts
 
  Future<List<Post>> getFeed({bool followingOnly = false, String? search, int page = 1, int? limit}) async {
    final query = <String, dynamic>{};
    if (followingOnly) query['feed'] = 1;
    if (page > 1) query['page'] = page;
    if (limit != null) query['limit'] = limit;

    final json = await _client.get(
      '/posts',
      query: query.isEmpty ? null : query,
    );
    final list = json as List<dynamic>;
    var posts = list
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();

    // Filtramos a string aqui no app mesmo porque a busca da API estava meio bugada e não trazia os resultados certos.
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      posts = posts.where((p) => p.message.toLowerCase().contains(q)).toList();
    }
    // A API às vezes mandava os IDs fora de ordem, então forçamos a ordenação pela data de criação pra garantir o mais recente no topo.
    posts.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });
    return posts;
  }

  /// Cria uma nova postagem.
  /// Endpoint: POST /posts
  /// Body: { "post": { "message": "..." } }
  Future<Post> createPost(String message) async {
    final json = await _client.post(
      '/posts',
      body: {
        'message': message,
      },
    ) as Map<String, dynamic>;

    if (json['user'] == null) {
      json['user'] = {
        'login': SessionStore.instance.userLogin ?? '',
        'name': SessionStore.instance.name ?? SessionStore.instance.userLogin ?? '',
        'profile_image': ProfileStore.instance.networkProfileImageUrl,
      };
    }

    return Post.fromJson(json);
  }

  /// Exclui uma postagem.
  /// Endpoint: DELETE /posts/{id}
  Future<void> deletePost(String id) async {
    await _client.delete('/posts/$id');
  }

  /// Curte uma postagem.
  /// Endpoint: POST /posts/{id}/likes
  Future<void> likePost(String id) async {
    await _client.post('/posts/$id/likes');
  }

  /// Remove a curtida de uma postagem.
  /// Endpoint: DELETE /posts/{id}/likes/me
  Future<void> unlikePost(String id) async {
    await _client.delete('/posts/$id/likes/me');
  }

  /// Busca as respostas (replies) de uma postagem.
  /// Endpoint: GET /posts/{id}/replies
  Future<List<Post>> getReplies(String id) async {
    final json = await _client.get('/posts/$id/replies');
    final list = json as List<dynamic>;
    return list
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Cria uma resposta a uma postagem.
  /// Endpoint: POST /posts/{id}/replies
  /// Body: { "reply": { "message": "..." } }
  Future<Post> createReply(String postId, String message) async {
    final json = await _client.post(
      '/posts/$postId/replies',
      body: {
        'message': message,
      },
    ) as Map<String, dynamic>;

    if (json['user'] == null) {
      json['user'] = {
        'login': SessionStore.instance.userLogin ?? '',
        'name': SessionStore.instance.name ?? SessionStore.instance.userLogin ?? '',
        'profile_image': ProfileStore.instance.networkProfileImageUrl,
      };
    }

    return Post.fromJson(json);
  }
}