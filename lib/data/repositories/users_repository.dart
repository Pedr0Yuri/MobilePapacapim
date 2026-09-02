import '../api_cliente.dart';
import '../models/user.dart';

class UsersRepository {
  UsersRepository._();
  static final UsersRepository instance = UsersRepository._();

  final ApiClient _client = ApiClient.instance;

  /// Lista/busca usuários.
  
  Future<List<User>> searchUsers({String? search}) async {
    final json = await _client.get(
      '/users',
      query: (search != null && search.isNotEmpty) ? {'search': search} : null,
    );
    final list = json as List<dynamic>;
    return list
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}