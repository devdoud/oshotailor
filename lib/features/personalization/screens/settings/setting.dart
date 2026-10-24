import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/utils/validators/validation.dart';

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
              final hasName = user.fullName.trim().isNotEmpty;
              final uploading = controller.photoUploading.value;
              return Row(
                children: [
                  _Avatar(
                    url: photo,
                    uploading: uploading,
                    onTap: uploading
                        ? null
                        : () => _photoOptions(context, controller),
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
                                  onPressed: uploading
                                      ? null
                                      : () =>
                                          _photoOptions(context, controller),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: Text(uploading
                                      ? 'Envoi de la photo…'
                                      : photo.isEmpty
                                          ? 'Ajouter une photo'
                                          : 'Changer la photo'),
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
            Obx(() {
              final name = controller.user.value.fullName.trim();
              return OSpecRow(
                label: 'Nom',
                value: name.isEmpty ? 'Ajouter' : name,
                tapHint: 'Modifier le nom',
                onTap: () => _editName(context, controller),
              );
            }),
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
                  OLoaders.infoSnackBar(title: 'Identifiant copié.');
                },
              );
            }),
            Obx(() => OSpecRow(
                  label: 'Rôle',
                  value: _roleLabel(controller.user.value.role),
                )),
            const SizedBox(height: 32),

            OutlinedButton(
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Se déconnecter ?',
                  message:
                      'Vous ne recevrez plus les commandes sur cet appareil.',
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

  static String _roleLabel(String role) => switch (role.trim().toLowerCase()) {
        'tailor' => 'Tailleur',
        'customer' => 'Client',
        'admin' => 'Administrateur',
        '' => '',
        final other => other[0].toUpperCase() + other.substring(1),
      };

  void _photoOptions(BuildContext context, UserController controller) {
    final t = context.osho;
    final hasPhoto = controller.user.value.profilePicture.isNotEmpty;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        Widget option(String label, VoidCallback onTap, {Color? color}) =>
            OMenuRowAction(label: label, color: color, onTap: () {
              Navigator.of(ctx).pop();
              onTap();
            });
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(kGutter, 12, kGutter, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const OSectionLabel('Photo de profil'),
                const SizedBox(height: 4),
                const OHairline(),
                option('Prendre une photo',
                    () => controller.changePhoto(ImageSource.camera)),
                option('Choisir dans la galerie',
                    () => controller.changePhoto(ImageSource.gallery)),
                if (hasPhoto)
                  option('Retirer la photo', controller.removePhoto,
                      color: t.dangerInk),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editName(BuildContext context, UserController controller) {
    _EditFieldSheet.show(
      context,
      title: "Nom de l'atelier",
      label: "Nom de l'atelier",
      initial: controller.user.value.fullName.trim(),
      validator: OValidator.validateWorkshopName,
      capitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.organizationName],
      onSave: (v) => controller
          .saveProfile(controller.user.value.copyWith(fullName: v)),
    );
  }

  void _editPhone(BuildContext context, UserController controller) {
    _EditFieldSheet.show(
      context,
      title: 'Téléphone',
      label: 'Numéro de téléphone',
      helper: 'Indicatif compris, par exemple +229 01 23 45 67',
      initial: controller.user.value.phone,
      validator: OValidator.validatePhoneNumber,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      onSave: (v) =>
          controller.saveProfile(controller.user.value.copyWith(phone: v)),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await confirmAction(
      context,
      title: 'Supprimer le compte ?',
      message: "Action irréversible : les données de l'atelier seront perdues.",
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!ok) return;
    OLoaders.infoSnackBar(
      title: 'Contactez le support pour supprimer votre compte.',
    );
  }
}

/// Photo de profil carrée, avec indicateur pendant l'envoi.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.uploading, this.onTap});

  final String url;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return Semantics(
      button: onTap != null,
      label: 'Photo de profil',
      hint: onTap != null ? 'Modifier la photo' : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Sans photo : l'emplacement vide, jamais un visage d'exemple.
            OThumb(url: url.isEmpty ? null : url, size: 72),
            if (uploading)
              Positioned.fill(
                child: ColoredBox(
                  color: t.bg.withValues(alpha: 0.7),
                  child: const OLoader(size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Feuille de modification d'un champ : validation, état d'enregistrement,
/// erreur affichée sur place. Ne se ferme qu'une fois l'enregistrement réussi.
class _EditFieldSheet extends StatefulWidget {
  const _EditFieldSheet({
    required this.title,
    required this.label,
    required this.initial,
    required this.validator,
    required this.onSave,
    this.helper,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
    this.autofillHints,
  });

  final String title;
  final String label;
  final String? helper;
  final String initial;
  final String? Function(String?) validator;

  /// Renvoie un message d'erreur, ou `null` si l'enregistrement a réussi.
  final Future<String?> Function(String value) onSave;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final List<String>? autofillHints;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String label,
    required String initial,
    required String? Function(String?) validator,
    required Future<String?> Function(String value) onSave,
    String? helper,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    List<String>? autofillHints,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditFieldSheet(
        title: title,
        label: label,
        helper: helper,
        initial: initial,
        validator: validator,
        onSave: onSave,
        keyboardType: keyboardType,
        capitalization: capitalization,
        autofillHints: autofillHints,
      ),
    );
  }

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initial);
  bool _saving = false;
  bool _changed = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onSave(_controller.text.trim());
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.osho;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(kGutter, 20, kGutter, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.title,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    OIconButton(
                      icon: OIcons.close,
                      tooltip: 'Fermer',
                      onPressed:
                          _saving ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !_saving,
                  keyboardType: widget.keyboardType,
                  textCapitalization: widget.capitalization,
                  autofillHints: widget.autofillHints,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: widget.validator,
                  onChanged: (v) => setState(
                      () => _changed = v.trim() != widget.initial.trim()),
                  onFieldSubmitted: (_) {
                    if (_changed && !_saving) _submit();
                  },
                  decoration: InputDecoration(
                    labelText: widget.label,
                    helperText: widget.helper,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Text(_error!,
                        style: OType.text(OType.secondary, t.dangerInk,
                            weight: FontWeight.w500)),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _changed && !_saving ? _submit : null,
                  child: _saving
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: t.muted,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
