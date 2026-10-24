import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/constants/image_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final t = context.osho;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil professionnel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(kGutter, 24, kGutter, 32),
        children: [
          Row(
            children: [
              Obx(() {
                final networkImage = controller.user.value.profilePicture;
                return OThumb(
                  url: networkImage.isNotEmpty ? networkImage : OImages.profile,
                  asset: networkImage.isEmpty,
                  size: 88,
                  semanticLabel: 'Photo de profil',
                );
              }),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => controller.uploadUserProfilePicture(),
                child: const Text('Changer la photo'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const OSectionLabel("Informations de l'atelier"),
          const SizedBox(height: 4),
          const OHairline(),
          Obx(() => OSpecRow(
                label: 'Atelier',
                value: controller.user.value.fullName,
                tapHint: 'Modifier le nom',
                onTap: () => _showUpdateNameSheet(context, controller),
              )),
          Obx(() => OSpecRow(
                label: 'E-mail',
                value: controller.user.value.email,
              )),
          Obx(() {
            final phone = controller.user.value.phone;
            return OSpecRow(
              label: 'Téléphone',
              value: phone.isEmpty ? 'Ajouter' : phone,
              tabular: phone.isNotEmpty,
              tapHint: 'Modifier le téléphone',
              onTap: () => _showUpdatePhoneSheet(context, controller),
            );
          }),
          const SizedBox(height: 32),
          const OSectionLabel('Paramètres techniques'),
          const SizedBox(height: 4),
          const OHairline(),
          Obx(() {
            final id = controller.user.value.id;
            return OSpecRow(
              label: 'ID atelier',
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
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _showDeleteConfirmation(context),
              style: TextButton.styleFrom(foregroundColor: t.dangerInk),
              child: const Text('Supprimer mon compte professionnel'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSheet(BuildContext context,
      {required String title, required List<Widget> children}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
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

  void _showUpdateNameSheet(BuildContext context, UserController controller) {
    final firstNameController =
        TextEditingController(text: controller.user.value.firstName);
    final lastNameController =
        TextEditingController(text: controller.user.value.lastName);

    _showSheet(context, title: "Nom de l'atelier", children: [
      TextField(
        controller: firstNameController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Prénom'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: lastNameController,
        textCapitalization: TextCapitalization.words,
        decoration:
            const InputDecoration(labelText: "Nom ou nom de l'atelier"),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          final updatedUser = controller.user.value;
          updatedUser.firstName = firstNameController.text.trim();
          updatedUser.lastName = lastNameController.text.trim();
          controller.updateProfile(updatedUser);
          Navigator.of(context).pop();
        },
        child: const Text('Enregistrer'),
      ),
    ]);
  }

  void _showUpdatePhoneSheet(BuildContext context, UserController controller) {
    final phoneController =
        TextEditingController(text: controller.user.value.phone);

    _showSheet(context, title: 'Téléphone', children: [
      TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          final updatedUser = controller.user.value;
          updatedUser.phone = phoneController.text.trim();
          controller.updateProfile(updatedUser);
          Navigator.of(context).pop();
        },
        child: const Text('Enregistrer'),
      ),
    ]);
  }

  void _showDeleteConfirmation(BuildContext context) {
    final t = context.osho;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le compte ?'),
        content: const Text(
            "Cette action est irréversible. Toutes les données de l'atelier seront perdues."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: t.ink),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              OLoaders.infoSnackBar(
                title: 'Action requise',
                message:
                    'Pour des raisons de sécurité, contactez le support pour supprimer définitivement votre compte atelier.',
              );
            },
            style: TextButton.styleFrom(foregroundColor: t.dangerInk),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
