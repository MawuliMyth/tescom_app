class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'TESCON_API_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
