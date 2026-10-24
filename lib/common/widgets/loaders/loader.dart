import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/utils/theme/osho_tokens.dart';
import 'package:osho/utils/theme/osho_type.dart';
import 'package:osho/utils/theme/theme.dart';

/// Indicateur de chargement : un arc d'encre, bouts francs, sans dégradé.
class OLoader extends StatelessWidget {
  const OLoader({super.key, this.color, this.size = 36.0});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          strokeCap: StrokeCap.butt,
          color: color ?? context.osho.ink,
          semanticsLabel: 'Chargement',
        ),
      ),
    );
  }
}

class OLoaders {
  static OshoTokens get _t =>
      Get.context != null ? OshoTokens.of(Get.context!) : OshoTokens.light;

  static void _show(String title, String? message, Color bg, Color border,
      Color ink, Duration duration) {
    Get.snackbar(
      title,
      message ?? '',
      isDismissible: true,
      colorText: ink,
      backgroundColor: bg,
      borderColor: border,
      borderWidth: 1,
      borderRadius: OshoTheme.radius,
      boxShadows: const [],
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      margin: const EdgeInsets.all(16),
      titleText: Text(title,
          style: OType.text(OType.body, ink, weight: FontWeight.w600)),
      messageText: message == null || message.isEmpty
          ? const SizedBox.shrink()
          : Text(message, style: OType.text(OType.secondary, ink)),
    );
  }

  static void infoSnackBar({required String title, String? message}) {
    final t = _t;
    _show(title, message, t.surface, t.hairline, t.ink,
        const Duration(seconds: 3));
  }

  static void warningSnackBar({required String title, String? message}) {
    final t = _t;
    _show(title, message, t.warnBg, t.warnBorder, t.warnInk,
        const Duration(seconds: 3));
  }

  static void successSnackBar(
      {required String title, String? message, int duration = 3}) {
    final t = _t;
    _show(title, message, t.okBg, t.okBorder, t.okInk,
        Duration(seconds: duration));
  }

  static void errorSnackBar({required String title, String? message}) {
    final t = _t;
    _show(title, message, t.dangerBg, t.dangerBorder, t.dangerInk,
        const Duration(seconds: 4));
  }
}
