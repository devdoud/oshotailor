# Osho Atelier — app tailleur

Application Flutter des ateliers partenaires d'Osho : le tailleur reçoit les
commandes sur mesure, les accepte ou les refuse, suit la confection et la
marque comme terminée. L'app cliente est un projet séparé.

Données et logique métier : Supabase (auth, tables, fonctions serveur),
partagé avec l'app cliente, dont le dépôt contient les migrations et les
fonctions serveur. Le profil est dans la table `profiles`.
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
   - `lib/firebase_options.dart` : généré par
     `flutterfire configure --project=osho-f0ba3` (projet Firebase commun
     avec l'app cliente, voir « Notifications »).
   - `android/app/google-services.json` : à télécharger depuis la console
     Firebase du projet `osho-f0ba3` (app Android `com.example.oshotailor`). **Indispensable** :
     sans lui, Android ne peut pas recevoir de notification app fermée,
     car le service FCM démarre avant le code Dart. La compilation Android
     échoue s'il manque.
3. `flutter run`

Identifiants d'app actuels : `com.example.oshotailor` (Android et iOS). À
remplacer par un identifiant définitif avant toute publication en boutique.

## Notifications de commande

Le serveur est dans le projet de l'app cliente (`osho_supa/supabase`) :
quand une commande est affectée, `notifyTailorsForOrder` appelle la fonction
`send-notification`, qui lit les jetons dans la table **`fcm_tokens`** et
envoie via l'API FCM HTTP v1 :

- un bloc `notification` (titre « Nouvelle commande », texte) ;
- `data.type = "new_order"` et `data.order_id` ;
- `android.notification.channel_id = "osho_high_importance"`.

Côté app tailleur (`lib/data/services/notification_service.dart`) :

- le jeton est enregistré dans `fcm_tokens` (`user_id`, `token`, `platform`)
  après la connexion, tenu à jour, et supprimé à la déconnexion ;
- le canal Android `osho_high_importance` (« Nouvelles commandes ») joue le
  son `new_order` ;
- l'app affiche elle-même les messages reçus app ouverte, et ouvre la
  commande `order_id` au toucher.

**Un seul projet Firebase.** `send-notification` envoie avec le projet
défini par `FCM_PROJECT_ID`, celui de l'app cliente (`osho-f0ba3`). Un jeton
n'est valable que pour le projet qui l'a créé : l'app tailleur doit donc être
enregistrée dans **ce même projet** (app Android `com.example.oshotailor`),
puis :

```
flutterfire configure --project=osho-f0ba3
```

et remplacer `android/app/google-services.json` par celui de ce projet. Avec
un autre projet Firebase, FCM refuse l'envoi (`SENDER_ID_MISMATCH`).

iOS ne reçoit rien tant que l'app iOS n'est pas déclarée dans ce projet,
avec une clé APNs et la capacité « Push Notifications » dans Xcode.

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
