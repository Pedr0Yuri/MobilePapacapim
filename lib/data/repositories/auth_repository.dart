import '../api_cliente.dart';
import '../models/user.dart';
import '../session_store.dart';
import '../profile_store.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final ApiClient _client = ApiClient.instance;

  /// Cria uma nova conta.
  /// Endpoint: POST /users (único endpoint que não exige autenticação).
  /// Body: { "user": { "login": ..., "name": ..., "password": ..., "password_confirmation": ... } }
  Future<User> createUser({
    required String login,
    required String name,
    required String password,
    required String passwordConfirmation,
  }) async {
    final json = await _client.post(
      '/users',
      body: {
        'login': login,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return User.fromJson(json as Map<String, dynamic>);
  }

  /// Autentica o usuário.
  /// Endpoint: POST /sessions.
  Future<void> login({
    required String login,
    required String password,
  }) async {
    final json = await _client.post(
      '/sessions',
      body: {
        'login': login,
        'password': password,
      },
    );
    final map = json as Map<String, dynamic>;

    await SessionStore.instance.save(
      token: map['token'] as String,
      userLogin: map['user_login'] as String,
    );
  }

  /// Busca os dados do usuário autenticado.
  /// Endpoint: GET /users/me
  Future<User> getCurrentUser() async {
    final json = await _client.get('/users/me');
    return User.fromJson(json as Map<String, dynamic>);
  }
 
  /// Altera dados do usuário autenticado (nome, senha e/ou foto).
  /// Endpoint: PATCH /users/me
  /// Body: { "user": { ... } }
  Future<User> updateUser({
    String? name,
    String? password,
    String? passwordConfirmation,
    String? imageDataBase64,
  }) async {
    final userData = <String, dynamic>{};
    if (name != null && name.isNotEmpty) userData['name'] = name;
    if (password != null && password.isNotEmpty) {
      userData['password'] = password;
      userData['password_confirmation'] = passwordConfirmation;
    }
    if (imageDataBase64 != null) userData['image_data'] = imageDataBase64;
 
    final json = await _client.patch('/users/me', body: {'user': userData});
    return User.fromJson(json as Map<String, dynamic>);
  }

  /// Encerra a sessão no servidor.
  /// Endpoint: DELETE /sessions/1
  Future<void> logout() async {
    try {
      await _client.delete('/sessions/1');
    } catch (_) {
      // Mesmo que falhe no servidor, limpamos a sessão local.
    }
    await SessionStore.instance.clear();
    ProfileStore.instance.clearProfileImage();
  }

  /// Exclui a conta do usuário autenticado.
  /// Endpoint: DELETE /users/me
  Future<void> deleteAccount() async {
    await _client.delete('/users/me');
    await SessionStore.instance.clear();
    ProfileStore.instance.clearProfileImage();
  }
}
