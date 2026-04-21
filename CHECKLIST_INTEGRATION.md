# ✅ CHECKLIST D'INTÉGRATION - SYSTÈME DE RÉCEPTION DE COMMANDES

## 🎯 Phase 1: Configuration Firebase (AVANT de tester)

- [ ] **Générer firebase_options.dart**
  ```bash
  dart pub global activate flutterfire_cli
  flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
  ```
  Cela remplace le fichier template par la vraie configuration.

- [ ] **Tester la compilation locale**
  ```bash
  flutter pub get
  flutter analyze
  ```

## 🎯 Phase 2: Intégration au Navigation Menu

- [ ] **Modifier lib/navigation_menu.dart**
  - Importer `TailorDashboardScreen`
  - Remplacer `OrderScreen()` par `TailorDashboardScreen()` dans la liste des screens

```dart
// Ajouter import
import 'package:osho/features/tailor_dashboard/screens/tailor_dashboard.dart';

// Remplacer dans NavigationController.screens:
final List<Widget> screens = [
  const HomeScreen(),           // 0. Accueil
  const TailorDashboardScreen(),   // 1. NOUVEAU - Commandes avec tabs
  const SettingScreen(),        // 2. Profil
];
```

## 🎯 Phase 3: Vérifier les Edge Functions

- [ ] **Vérifier que les 2 edge functions existent dans Supabase:**
  - `get-tailor-orders` - Retourne la liste des commandes
  - `update-assignment-status` - Met à jour le statut d'une assignation

- [ ] **Tester les edge functions manuellement**
  ```bash
  # Via Supabase Dashboard: Functions > Test
  # Body pour get-tailor-orders:
  {
    "status": "pending",
    "limit": 50,
    "offset": 0
  }
  
  # Body pour update-assignment-status:
  {
    "assignment_id": "xxx-xxx-xxx",
    "status": "accepted"
  }
  ```

## 🎯 Phase 4: Configuration Base de Données

- [ ] **S'assurer que la table `tailor_tokens` existe**
  ```sql
  -- Colonnes requises:
  - tailor_id (UUID, FK users)
  - token (TEXT)
  - created_at (TIMESTAMP)
  - updated_at (TIMESTAMP)
  ```

- [ ] **S'assurer que les tables d'orders/assignments ont les colonnes:**
  - `status` (pending, accepted, in_progress, completed)
  - `accepted_at` (TIMESTAMP, nullable)
  - `started_at` (TIMESTAMP, nullable)
  - `completed_at` (TIMESTAMP, nullable)

## 🎯 Phase 5: Test Local

- [ ] **Démarrer l'app**
  ```bash
  flutter run
  ```

- [ ] **Connexion tailleur**
  - Entrer email/password du tailleur
  - Vérifier que la redirection fonctionne

- [ ] **Vérifier FCM initialization**
  - Regarde la console pour: "✅ FCM token registered"
  - Pas d'erreur Firebase

- [ ] **Tester l'écran dashboard**
  - Aller au tab "Commandes"
  - Vérifier que les 4 tabs apparaissent: Pending, Accepted, In Progress, Completed
  - Vérifier que les commandes se chargent

## 🎯 Phase 6: Test des Actions

- [ ] **Accepter une commande**
  - Cliquer "Accepter" sur une commande pending
  - Voir le snackbar: "Succès - Commande acceptée!"
  - La commande devrait passer dans l'onglet "Accepted"

- [ ] **Démarrer une commande**
  - Cliquer "Commencer" sur une commande accepted
  - Voir le snackbar: "Succès - Commande commencée!"
  - La commande devrait passer dans l'onglet "In Progress"

- [ ] **Terminer une commande**
  - Cliquer "Terminer" sur une commande in_progress
  - Voir le snackbar: "Succès - Commande terminée!"
  - La commande devrait passer dans l'onglet "Completed"

## 🎯 Phase 7: Test des Notifications FCM

- [ ] **Envoyer une notification test via Firebase Console**
  - Firebase Console > Cloud Messaging > New Topic
  - Sélectionner le device qui a l'app ouverte
  - Envoyer une notification avec:
    ```json
    {
      "type": "new_order"
    }
    ```

- [ ] **Vérifier la réaction**
  - L'app devrait raffraîchir la liste des commandes
  - Pas de crash

## 🎯 Phase 8: Test Mode Arrière-plan

- [ ] **Fermer l'app**

- [ ] **Envoyer une notification**
  - Via Firebase Console ou backend

- [ ] **Ouvrir l'app**
  - Doit gérer la notification sans crash

## 🎯 Phase 9: Peaufinage UI (Optionnel)

- [ ] **Ajouter des animations de transition entre tabs**
- [ ] **Améliorer la mise en page des cartes de commande**
- [ ] **Ajouter des images/logos aux statuts**
- [ ] **Ajouter un swipe to refresh**

## 🎯 Phase 10: Déploiement

- [ ] **Build APK/AAB pour Android**
  ```bash
  flutter build apk --release
  # ou
  flutter build appbundle --release
  ```

- [ ] **Build IPA pour iOS**
  ```bash
  flutter build ios --release
  ```

- [ ] **Uploader sur Play Store / App Store**

---

## 📞 Support

Si une étape échoue:

1. **FCM Token Not Registered**
   - Vérifier que l'utilisateur est authentifié
   - Vérifier que la session Supabase est valide
   - Voir la console pour l'erreur exacte

2. **Edge Function Not Found**
   - Vérifier dans Supabase Dashboard > Functions
   - Vérifier le Bearer token dans les headers
   - Tester la fonction directement dans le dashboard

3. **Notifications Not Received**
   - Vérifier Firebase Project ID
   - Vérifier que Cloud Messaging est activé
   - Sur Android: Vérifier que l'APK est signé correctement

4. **Erreur de Compilation**
   - Exécuter `flutter clean`
   - Exécuter `flutter pub get`
   - Exécuter `flutter analyze`

---

**Last Updated:** 25 Mars 2026
**Status:** ✅ Implémentation Complète - Prêt pour Test
