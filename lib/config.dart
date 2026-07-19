import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
