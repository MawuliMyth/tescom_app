class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'TESCON_API_URL',
    defaultValue: 'https://backend-tawny-delta-99.vercel.app',
  );

  static String mediaUrl(String value) {
    if (value.startsWith('http')) {
      final uri = Uri.tryParse(value);
      if (uri != null && uri.host.endsWith('.public.blob.vercel-storage.com')) {
        return '$baseUrl/api/media?url=${Uri.encodeComponent(value)}';
      }
      return value;
    }
    if (value.startsWith('/')) return '$baseUrl$value';
    return value;
  }
}
