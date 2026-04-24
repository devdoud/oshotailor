// Configuration des variables d'environnement
// Note : Dans un projet en production, ces valeurs devraient être gérées via --dart-define ou un fichier sécurisé.

const String supabaseUrl = 'https://pzkeklqgogwvnspmivhp.supabase.co';
const String supabaseAnonKey = 'sb_publishable_kNei4UoU8GgPwr05EXXJXw_yJFzmBAY';

Future<void> loadEnv() async {
  // Cette fonction est conservée pour ne pas casser main.dart, 
  // mais elle n'a plus besoin de charger de fichier .env
  return;
}
