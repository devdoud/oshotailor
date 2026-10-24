import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/controllers/forget_password/forget_password_controller.dart';
import '../../../../utils/constants/text_strings.dart';
import '../login/login.dart';

class ResetPassword extends StatelessWidget {
  const ResetPassword({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final t = context.osho;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const Border(),
        actions: [
          OIconButton(
            icon: OIcons.close,
            tooltip: 'Fermer',
            onPressed: () => Get.offAll(() => const LoginScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kGutter, 8, kGutter, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: OshoLogo(height: 32),
            ),
            const SizedBox(height: 40),

            /// Title and SubTitle
            Semantics(
              header: true,
              child: Text(OText.changeYourPasswordTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 12),
            Text(OText.changeYourPasswordSubTitle,
                style: OType.text(OType.body, t.muted, height: 1.5)),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 16),
              const OHairline(),
              OSpecRow(label: 'Envoyé à', value: email),
            ],
            const SizedBox(height: 32),

            /// Buttons
            ElevatedButton(
              onPressed: () => Get.offAll(() => const LoginScreen()),
              child: const Text(OText.done),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ForgetPasswordController.instance
                  .resendPasswordResetEmail(email),
              child: const Text(OText.resendEmail),
            ),
          ],
        ),
      ),
    );
  }
}
