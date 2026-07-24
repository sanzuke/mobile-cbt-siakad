/// Backend base URL, overridable at build/run time:
///   flutter run --dart-define=API_BASE_URL=https://siakad.example.com/api
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
