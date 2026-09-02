/// Exceção lançada quando:
/// - a API responde com um erro (status HTTP >= 400), ou
/// - a requisição falha por outro motivo (sem internet, timeout, etc.).

/// Usamos uma exceção própria para que as telas possam capturar um único tipo de erro
/// e mostrar uma mensagem amigável ao usuário, sem se preocupar com os
/// detalhes de rede/HTTP.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic body;

  ApiException({required this.message, this.statusCode, this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
