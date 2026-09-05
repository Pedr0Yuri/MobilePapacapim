import '../api_cliente.dart';
import '../models/post.dart';
import '../models/user.dart';

class UsersRepository {
  UsersRepository._();
  static final UsersRepository instance = UsersRepository._();

  final ApiClient _client = ApiClient.instance;

  /// Lista/busca usuários.
  /// Endpoint: GET /users?search=termo
  Future<List<User>> searchUsers({String? search, int page = 1}) async {
    final query = <String, dynamic>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (page > 1) query['page'] = page;

    final json = await _client.get(
      '/users',
      query: query.isEmpty ? null : query,
    );
    final list = json as List<dynamic>;
    return list
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Obtém dados de um usuário específico.
  /// Endpoint: GET /users/{login}
  Future<User> getUser(String login) async {
    final json = await _client.get('/users/$login');
    return User.fromJson(json as Map<String, dynamic>);
  }

  /// Lista seguidores de um usuário.
  /// Endpoint: GET /users/{login}/followers
  Future<List<User>> getFollowers(String login) async {
    final json = await _client.get('/users/$login/followers');
    final list = json as List<dynamic>;
    return list.map((item) {
      final followerMap = item as Map<String, dynamic>;
      // A API retorna { "follower": { "login": ..., "name": ..., "profile_image": ... } }
      final follower = followerMap['follower'] as Map<String, dynamic>;
      return User.fromJson(follower);
    }).toList();
  }

  /// Lista postagens de um usuário.
  /// Endpoint: GET /users/{login}/posts
  Future<List<Post>> getUserPosts(String login, {int? page}) async {
    final query = <String, dynamic>{};
    if (page != null) query['page'] = page;
    final json = await _client.get(
      '/users/$login/posts',
      query: query.isEmpty ? null : query,
    );
    final list = json as List<dynamic>;
    final posts = list
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
    // Ordena os posts pelos mais recentes primeiro usando a data de criação
    posts.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null) {
        return b.createdAt!.compareTo(a.createdAt!);
      }
      return 0;
    });
    return posts;
  }

  /// Segue um usuário.
  /// Endpoint: POST /users/{login}/followers
  Future<void> followUser(String login) async {
    await _client.post('/users/$login/followers');
  }

  /// Deixa de seguir um usuário.
  /// Endpoint: DELETE /users/{login}/followers/me
  Future<void> unfollowUser(String login) async {
    await _client.delete('/users/$login/followers/me');
  }
}