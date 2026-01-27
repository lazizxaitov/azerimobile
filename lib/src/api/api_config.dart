class ApiConfig {
  static const String baseUrl = 'https://azeriadmin.uz';
  static const String apiKey =
      'ae34c6dc16e7a735a0cc1a50905988ad5ced538b94dcc89bfa4ff9d8a8f3050e';

  static Uri buildUri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(baseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: _joinPaths(base.path, normalizedPath),
      queryParameters: query?.isEmpty ?? true ? null : query,
    );
  }

  static String resolveImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final base = Uri.parse(baseUrl);
    final normalizedPath = url.startsWith('/') ? url : '/$url';
    return base
        .replace(path: _joinPaths(base.path, normalizedPath))
        .toString();
  }

  static String _joinPaths(String basePath, String path) {
    if (basePath.isEmpty || basePath == '/') {
      return path;
    }
    if (basePath.endsWith('/') && path.startsWith('/')) {
      return '${basePath.substring(0, basePath.length - 1)}$path';
    }
    if (!basePath.endsWith('/') && !path.startsWith('/')) {
      return '$basePath/$path';
    }
    return '$basePath$path';
  }
}
