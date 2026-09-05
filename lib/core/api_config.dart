class ApiConfig {
  static const String baseUrl = 'https://api.papacapim.just.pro.br';
  static const String sessionTokenHeader = 'x-session-token';

  static String getProfileImageUrl(String imagePath) {
    var path = imagePath.trim();
    if (path.isEmpty) return '';

    // Se já é URL completa, apenas garante HTTPS
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path.replaceFirst('http://', 'https://');
    }

    // Se é apenas o UUID (ex: "fa87ebb3-...webp"), monta a URL completa
    if (!path.contains('/image/profile/')) {
      // Remove '/' inicial se tiver
      path = path.replaceFirst(RegExp(r'^/'), '');
      return '$baseUrl/image/profile/$path';
    }

    // Se já contém '/image/profile' mas não começa com http
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '$baseUrl$path';
  }
}
