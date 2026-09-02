import '../api_cliente.dart';
import '../models/post.dart';

/// Sabe conversar com os endpoints de postagens (`/posts`) da API Papacapim.

class PostsRepository {
  PostsRepository._();
  static final PostsRepository instance = PostsRepository._();

  final ApiClient _client = ApiClient.instance;

  /// Lista/busca postagens.
  /// Endpoint: GET /posts
 
  Future<List<Post>> getFeed({bool followingOnly = false, String? search}) async {
    final query = <String, dynamic>{};
    if (followingOnly) query['feed'] = 1;
    if (search != null && search.isNotEmpty) query['search'] = search;

    final json = await _client.get(
      '/posts',
      query: query.isEmpty ? null : query,
    );
    final list = json as List<dynamic>;
    return list
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}