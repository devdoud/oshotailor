# 🔴 À FAIRE EN PRIORITÉ ABSOLUE

## ⏱️ Prochaines 30 Secondes

**Ouvre ce fichier en ordre:**

1. **ACCUEIL.md** (2 min) ← POINT DE DÉPART
2. **QUICK_START.md** (3 min) ← INSTRUCTIONS CONCRÈTES
3. **Exécute:** `flutterfire configure --project=YOUR_ID` (5 min) ← CRITIQUE!

---

## 🚨 CRITIQUE - Sans cette étape, rien ne marche!

```bash
# 1. Installer (une seule fois):
dart pub global activate flutterfire_cli

# 2. Générer firebase_options.dart:
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

⚠️ **Remplace YOUR_FIREBASE_PROJECT_ID par ton vrai ID**

---

## 📝 Modification Fichier

**Fichier:** `lib/navigation_menu.dart`

**À faire:** Remplacer une ligne

**Avant:**
```dart
const OrderScreen(),
```

**Après:**
```dart
const TailorDashboardScreen(),
```

Et ajouter en haut:
```dart
import 'package:osho/features/tailor_dashboard/screens/tailor_dashboard.dart';
```

---

## 🧪 Test Rapide

```bash
flutter pub get
flutter run
```

---

## ✅ Voilà!

C'est tout ce que tu dois faire pour que ça marche! 

Pour plus de détails: Lire **ACCUEIL.md** ou **QUICK_START.md**
