import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> loadEnv() async {
  await dotenv.load(fileName: '.env');
}

String get supabaseUrl => _requireEnv('SUPABASE_URL');
String get supabaseAnonKey => _requireEnv('SUPABASE_ANON_KEY');

String _requireEnv(String key) {
  final value = dotenv.env[key];
  if (value == null || value.isEmpty) {
    throw Exception('Missing environment variable: $key');
  }
  return value;
}
