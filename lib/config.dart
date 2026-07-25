import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl {
  try {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  } catch (_) {
    return 'http://localhost:8000';
  }
}
