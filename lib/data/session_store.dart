import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o token de sessão (autenticação) do usuário logado.

/// 1. Manter esse token em memória, para acesso rápido durante o uso do app.
/// 2. Persistir o token no armazenamento do dispositivo (shared_preferences), para que o usuário não precise fazer login toda vez que abrir o app.

class SessionStore {
  SessionStore._();
  static final SessionStore instance = SessionStore._();

  static const String _tokenKey = 'papacapim_session_token';
  static const String _loginKey = 'papacapim_user_login';

  String? _token;
  String? _userLogin;

  String? _name;
  String? _profileImage;

  String? get token => _token;
  String? get userLogin => _userLogin;
  String? get name => _name;
  String? get profileImage => _profileImage;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  void updateProfile({String? name, String? profileImage}) {
    if (name != null) _name = name;
    if (profileImage != null) _profileImage = profileImage;
  }

  /// Deve ser chamado uma única vez, no início do app 
  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userLogin = prefs.getString(_loginKey);
  }

  /// Salva o token em memória e em disco. Deve ser chamado logo após um login bem-sucedido (resposta de POST /sessions).
  Future<void> save({required String token, required String userLogin}) async {
    _token = token;
    _userLogin = userLogin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_loginKey, userLogin);
  }

  /// Remove o token de memória e de disco. Deve ser chamado no logout, na exclusão de conta, ou se a API responder que a sessão é inválida.
  Future<void> clear() async {
    _token = null;
    _userLogin = null;
    _name = null;
    _profileImage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_loginKey);
  }
}
