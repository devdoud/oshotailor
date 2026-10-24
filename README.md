# Osho Atelier — app tailleur

Application Flutter des ateliers partenaires d'Osho : le tailleur reçoit les
commandes sur mesure, les accepte ou les refuse, suit la confection et la
marque comme terminée. L'app cliente est un projet séparé.

Données et logique métier : Supabase (auth, tables, fonctions serveur).
Notifications : Firebase Cloud Messaging.

## Mise en route

1. `flutter pub get`
2. Créer les fichiers secrets, **jamais commités** (déjà dans `.gitignore`) :
   - `lib/env.dart`
     ```dart
     const String supabaseUrl = 'https://<projet>.supabase.co';
     const String supabaseAnonKey = '<clé anon>';

     Future<void> loadEnv() async {}
     ```
   - `lib/firebase_options.dart` : généré par `flutterfire configure`
     (projet Firebase `oshotailor-db96f`).
   - `android/app/google-services.json` : à télécharger depuis la console
     Firebase (app Android `com.example.oshotailor`). **Indispensable** :
     sans lui, Android ne peut pas recevoir de notification app fermée,
     car le service FCM démarre avant le code Dart. La compilation Android
     échoue s'il manque.
3. `flutter run`

Identifiants d'app actuels : `com.example.oshotailor` (Android et iOS). À
remplacer par un identifiant définitif avant toute publication en boutique.

## Notifications de commande

L'app affiche elle-même les notifications (app ouverte, ou message sans bloc
`notification`), sur le canal Android `new_orders` avec le son `new_order`.
Le jeton FCM est enregistré dans `tailor_tokens` après la connexion, tenu à
jour, et supprimé à la déconnexion (`lib/data/services/notification_service.dart`).

Contrat attendu de la fonction serveur qui envoie le message, via l'API
**FCM HTTP v1** (l'ancienne API à « server key » est fermée depuis 2024) :

```json
{
  "message": {
    "token": "<fcm_token de tailor_tokens>",
    "notification": {
      "title": "Nouvelle commande",
      "body": "Aïssatou Diallo — Grand boubou bazin"
    },
    "data": {
      "type": "new_order",
      "order_id": "<id de la commande>"
    },
    "android": {
      "priority": "high",
      "notification": { "channel_id": "new_orders", "sound": "new_order" }
    },
    "apns": {
      "payload": { "aps": { "sound": "new_order.caf" } }
    }
  }
}
```

- `type` : `new_order` ou `order_update`. Les deux rafraîchissent les listes.
- `order_id` : la commande ouverte quand le tailleur touche la notification.
- Sans bloc `notification`, l'app affiche quand même un message, avec les
  champs `data.title` et `data.body` s'ils sont fournis.

iOS ne reçoit rien tant que la configuration Firebase iOS, la clé APNs et la
capacité « Push Notifications » ne sont pas en place dans Xcode.

## Identité visuelle

Direction « Atelier » : papier plat, filets de 1 px, angles de 2 px, aucune
ombre. Couleurs : `lib/utils/theme/osho_tokens.dart` (seule source),
typographie : `osho_type.dart`, briques partagées : `lib/common/widgets/atelier/`.

Icône et écran de démarrage (images dans `assets/icon` et `assets/splash`) :

```
dart run flutter_launcher_icons
dart run flutter_native_splash:create --path=splash.yaml
```

## Tests

```
flutter test
```

## Sécurité

Règles Supabase à appliquer côté serveur : `docs/security/supabase_hardening.sql`
(à relire avant exécution).
