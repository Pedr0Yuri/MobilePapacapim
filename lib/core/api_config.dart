// Configurações globais de acesso à API Papacapim.

class ApiConfig {
  // URL base da API. Todas as chamadas HTTP usam este endereço como prefixo.
  // Ex: baseUrl + '/sessions' = https://api.papacapim.just.pro.br/sessions
  static const String baseUrl = 'https://api.papacapim.just.pro.br';

  // Nome do cabeçalho HTTP usado para autenticação, conforme a documentação
  // da API: todas as requisições autenticadas devem enviar o token de
  // sessão neste header.
  static const String sessionTokenHeader = 'x-session-token';
}