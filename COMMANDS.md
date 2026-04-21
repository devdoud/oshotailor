# ⚡ COMMANDES RAPIDES - Copier-Coller

Toutes les commandes à exécuter dans le terminal, dans l'ordre.

---

## 🚀 Phase 1: Configuration Firebase (CRITIQUE)

### Étape 1: Installer flutterfire CLI
```bash
dart pub global activate flutterfire_cli
```

### Étape 2: Générer firebase_options.dart
```bash
# Remplace YOUR_PROJECT_ID par ton vrai Firebase Project ID
flutterfire configure --project=YOUR_PROJECT_ID
```

**Output attendu:**
```
✅ Generated file: lib/firebase_options.dart
✅ Configuration updated successfully
```

---

## 📦 Phase 2: Dépendances

### Étape 3: Mettre à jour les packages
```bash
flutter pub get
```

**Vérifier que ces packages sont installés:**
```bash
flutter pub list | grep -E "firebase_|get|supabase"
```

---

## 🧹 Phase 3: Vérification

### Étape 4a: Vérifier qu'il n'y a pas d'erreurs de compilation
```bash
flutter analyze
```

**Output attendu:** 0 errors (warnings ok)

### Étape 4b: Clean (si besoin)
```bash
flutter clean
flutter pub get
```

---

## 🎨 Phase 4: UI

### Étape 5: Modifier lib/navigation_menu.dart

**À la ligne ~3, ajouter:**
```dart
import 'package:osho/features/tailor_dashboard/screens/tailor_dashboard.dart';
```

**À la ligne ~60-63, remplacer:**
```dart
// AVANT:
const OrderScreen(),     // 1. Liste complète des commandes

// APRÈS:
const TailorDashboardScreen(),  // 1. Commandes avec 4 tabs
```

---

## 🚀 Phase 5: Lancer l'App

### Étape 6: Démarrer le développement
```bash
flutter run
```

**Ou avec plus de logs:**
```bash
flutter run --verbose
```

**Chercher dans la console:**
```
✅ Firebase initialized successfully
✅ FCM token registered
✅ Fetched X pending orders
```

---

## 📱 Phase 6: Tests

### Étape 7a: Tester le dashboard
```
1. Login avec compte tailleur
2. Aller au tab "Commandes"
3. Vérifier que les 4 onglets apparaissent
4. Vérifier que les commandes se chargent
```

### Étape 7b: Tester une action
```
1. Cliquer "Accepter" sur une commande pending
2. Vérifier le snackbar "Commande acceptée!"
3. Vérifier que la commande passe au tab "Accepted"
```

### Étape 7c: Tester les notifications (optionnel)
```
1. Garder l'app ouverte
2. Aller à Firebase Console > Cloud Messaging
3. Envoyer une test notification
4. Vérifier la liste de rafraîchit
```

---

## 🐛 Si Erreur...

### Si: Erreur "firebase_options.dart not found"
```bash
# Réexécuter flutterfire
flutterfire configure --project=YOUR_PROJECT_ID
```

### Si: Erreur "Edge function not found"
```bash
# Vérifier dans Supabase Dashboard > Functions
# Copier le nom exact de la fonction
```

### Si: Compilation échoue
```bash
# Clean complet
flutter clean
rm -rf pubspec.lock
flutter pub get

# Puis retry
flutter analyze
flutter run
```

### Si: Transactions non trouvées
```bash
# Vérifier que tu es bien login dans l'app
# Console devrait montrer: ✅ Fetched X orders
```

---

## 📊 Build pour Production

### Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Android Recommended)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build IPA (iOS)
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

---

## 🔍 Debugging

### Logs détaillés
```bash
flutter run --verbose 2>&1 | tee app.log
```

### Filter par mots-clé
```bash
flutter run --verbose 2>&1 | grep -E "FCM|Order|✅|❌"
```

### Rebuild spécifique
```bash
flutter run --no-fast-start --verbose
```

### Reset everything
```bash
flutter clean
flutter pub get
flutter run --verbose --no-fast-start
```

---

## 🎯 Checklist Finale

```bash
# 1. Firebase configuré?
test -f lib/firebase_options.dart && echo "✅ firebase_options.dart existe" || echo "❌ firebase_options.dart manquant"

# 2. Dépendances à jour?
flutter pub get

# 3. Pas d'erreurs?
flutter analyze

# 4. Compilation ok?
flutter build apk --debug

# 5. Tests en dev?
flutter run
```

---

## 🚀 Commandes à Mémoriser

```bash
# Le plus utilisé:
flutter run                    # Lancer l'app
flutter clean                  # Nettoyer tout
flutter pub get               # Installer des packages
flutter analyze               # Vérifier les erreurs
flutterfire configure        # Reconfigurer Firebase

# Build:
flutter build apk --release   # Android production
flutter build ios --release   # iOS production

# Debug:
flutter run --verbose         # Avec logs détaillés
flutter devices              # Voir les appareils disponibles
```

---

## ✅ Si Tout Ok

Tu devrais voir:
- ✅ App lance sans erreur
- ✅ Dashboard s'affiche avec 4 onglets
- ✅ Les commandes se chargent
- ✅ Les boutons d'action fonctionnent
- ✅ Snackbars de succès/erreur apparaissent

→ Bravo! Tu es prêt pour la production! 🎊

---

**Dernier commit status:** ✅ COMPLET  
**Avant de pousher:** Vérifier que tous les tests passent  
**Documentation:** Voir [ACCUEIL.md](ACCUEIL.md)
