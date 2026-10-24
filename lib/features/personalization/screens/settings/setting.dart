import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/constants/image_strings.dart';

/// Onglet Profil : tout le compte sur un seul écran, sans niveau
/// intermédiaire. Chaque ligne modifiable s'ouvre dans une feuille du bas.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LoginController>()) Get.put(LoginController());
    final controller = Get.isRegistered<UserController>()
        ? UserController.instance
        : Get.put(UserController());
    final t = context.osho;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kGutter, 16, kGutter, 32),
          children: [
            Semantics(
              header: true,
              child: Text('Profil',
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 20),

            /// Identity
            Obx(() {
              final user = controller.user.value;
              final photo = user.profilePicture;
              final hasName =
                  user.firstName.isNotEmpty || user.lastName.isNotEmpty;
              return Row(
                children: [
                  OThumb(
                    url: photo.isNotEmpty ? photo : OImages.profile,
                    asset: photo.isEmpty,
                    size: 72,
                    semanticLabel: 'Photo de profil',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: controller.profileLoading.value
                        ? const Align(
                            alignment: Alignment.centerLeft,
                            child: OLoader(size: 24),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  hasName
                                      ? user.fullName.trim()
                                      : 'Votre atelier',
                                  style: OType.display(20, t.ink,
                                      weight: FontWeight.w600)),
                              if (user.email.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(user.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        OType.text(OType.secondary, t.muted)),
                              ],
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed:
                                      controller.uploadUserProfilePicture,
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: const Text('Changer la photo'),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 28),

            /// Workshop
            const OSectionLabel('Atelier'),
            const SizedBox(height: 4),
            const OHairline(),
            Obx(() => OSpecRow(
                  label: 'Nom',
                  value: controller.user.value.fullName.trim().isEmpty
                      ? 'Ajouter'
                      : controller.user.value.fullName.trim(),
                  tapHint: 'Modifier le nom',
                  onTap: () => _editName(context, controller),
                )),
            Obx(() {
              final phone = controller.user.value.phone;
              return OSpecRow(
                label: 'Téléphone',
                value: phone.isEmpty ? 'Ajouter' : phone,
                tabular: phone.isNotEmpty,
                tapHint: 'Modifier le téléphone',
                onTap: () => _editPhone(context, controller),
              );
            }),
            Obx(() => OSpecRow(
                  label: 'E-mail',
                  value: controller.user.value.email,
                )),
            const SizedBox(height: 28),

            /// Account
            const OSectionLabel('Compte'),
            const SizedBox(height: 4),
            const OHairline(),
            Obx(() {
              final id = controller.user.value.id;
              return OSpecRow(
                label: 'Identifiant',
                value: id.length > 10 ? '${id.substring(0, 10)}…' : id,
                tabular: true,
                tapHint: "Copier l'identifiant",
                onTap: () {
                  Clipboard.setData(ClipboardData(text: id));
                  OLoaders.infoSnackBar(title: 'Identifiant copié');
                },
              );
            }),
            Obx(() {
              final role = controller.user.value.role.trim();
              return OSpecRow(
                label: 'Rôle',
                value: role.isEmpty
                    ? role
                    : role[0].toUpperCase() + role.substring(1).toLowerCase(),
              );
            }),
            const SizedBox(height: 32),

            OutlinedButton(
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Se déconnecter ?',
                  message:
                      'Vous ne recevrez plus les nouvelles commandes sur cet appareil tant que vous ne vous reconnectez pas.',
                  confirmLabel: 'Se déconnecter',
                );
                if (ok) LoginController.instance.logout();
              },
              child: const Text('Se déconnecter'),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => _deleteAccount(context),
                style: TextButton.styleFrom(foregroundColor: t.dangerInk),
                child: const Text('Supprimer mon compte'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sheet(BuildContext context,
      {required String title, required List<Widget> children}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kGutter, 20, kGutter, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: Theme.of(ctx).textTheme.titleLarge),
                    ),
                    OIconButton(
                      icon: OIcons.close,
                      tooltip: 'Fermer',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editName(BuildContext context, UserController controller) {
    final first = TextEditingController(text: controller.user.value.firstName);
    final last = TextEditingController(text: controller.user.value.lastName);

    _sheet(context, title: "Nom de l'atelier", children: [
      TextField(
        controller: first,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Prénom'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: last,
        textCapitalization: TextCapitalization.words,
        decoration:
            const InputDecoration(labelText: "Nom ou nom de l'atelier"),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          final user = controller.user.value;
          user.firstName = first.text.trim();
          user.lastName = last.text.trim();
          controller.updateProfile(user);
          Navigator.of(context).pop();
        },
        child: const Text('Enregistrer'),
      ),
    ]);
  }

  void _editPhone(BuildContext context, UserController controller) {
    final phone = TextEditingController(text: controller.user.value.phone);

    _sheet(context, title: 'Téléphone', children: [
      TextField(
        controller: phone,
        autofocus: true,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          final user = controller.user.value;
          user.phone = phone.text.trim();
          controller.updateProfile(user);
          Navigator.of(context).pop();
        },
        child: const Text('Enregistrer'),
      ),
    ]);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await confirmAction(
      context,
      title: 'Supprimer le compte ?',
      message:
          "Cette action est irréversible. Toutes les données de l'atelier seront perdues.",
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!ok) return;
    OLoaders.infoSnackBar(
      title: 'Action requise',
      message:
          'Pour des raisons de sécurité, contactez le support pour supprimer définitivement votre compte atelier.',
    );
  }
}
