import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'api_exception.dart';
import 'session_store.dart';

/// Cliente HTTP único e genérico para conversar com a API Papacapim.

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    final token = SessionStore.instance.token;
    if (token != null) {
      headers[ApiConfig.sessionTokenHeader] = token;
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams == null || queryParams.isEmpty) return uri;

    final filtered = <String, String>{};
    queryParams.forEach((key, value) {
      if (value != null) filtered[key] = value.toString();
    });

    return uri.replace(queryParameters: filtered);
  }

  /// GET /path?query
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => http.get(_buildUri(path, query), headers: _headers));
  }

  /// POST /path com corpo JSON opcional
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send(() => http.post(
          _buildUri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  /// PATCH /path com corpo JSON opcional
  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) {
    return _send(() => http.patch(
          _buildUri(path),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  /// DELETE /path
  Future<dynamic> delete(String path) {
    return _send(() => http.delete(_buildUri(path), headers: _headers));
  }

  /// Executa a requisição, capturando falhas de rede (sem internet, DNS,
  /// timeout, etc.) e transformando-as em ApiException também — assim o
  /// código que chama o ApiClient só precisa tratar um único tipo de erro.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    http.Response response;
    try {
      response = await request();
    } catch (_) {
      throw ApiException(
        message: 'Não foi possível conectar à API. Verifique sua internet.',
      );
    }
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    final status = response.statusCode;

    // 204 = sucesso sem conteúdo (ex: logout, excluir post, deixar de seguir).
    if (status == 204) return null;

    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decoded = null;
    }

    if (status >= 200 && status < 300) {
      return decoded;
    }

    // A API retornou um erro. Tentamos extrair uma mensagem legível do
    // corpo da resposta, se houver uma.
    String message = 'Erro ao comunicar com o servidor (status $status).';
    if (decoded is Map && decoded['errors'] != null) {
      message = _stringifyErrors(decoded['errors']);
    } else if (decoded is Map && decoded['message'] != null) {
      message = decoded['message'].toString();
    } else if (decoded != null) {
      // Não veio no formato esperado, mas veio ALGUMA coisa: mostramos o
      // corpo bruto em vez de um texto genérico, pra ajudar a debugar.
      message = decoded.toString();
    }

    throw ApiException(statusCode: status, message: message, body: decoded);
  }

  /// Converte o campo "errors" (formato comum em APIs Rails, ex:
  /// {"login": ["já está em uso"], "password": ["é muito curto"]}) em um
  /// texto legível para mostrar ao usuário.
  String _stringifyErrors(dynamic errors) {
    if (errors is Map) {
      return errors.entries.map((entry) {
        final value = entry.value;
        final valueText = value is List ? value.join(', ') : value.toString();
        return '${entry.key}: $valueText';
      }).join('\n');
    }
    if (errors is List) {
      return errors.join('\n');
    }
    return errors.toString();
  }
}