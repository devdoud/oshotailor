import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/controllers/forget_password/forget_password_controller.dart';
import 'package:osho/utils/validators/validation.dart';
import '../../../../utils/constants/text_strings.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    final t = context.osho;

    return Scaffold(
      appBar: AppBar(shape: const Border()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kGutter, 8, kGutter, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Headline
            Semantics(
              header: true,
              child: Text(OText.forgetPasswordTitle,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 8),
            Text(OText.forgetPassordSubTitle,
                style: OType.text(OType.body, t.muted, height: 1.5)),
            const SizedBox(height: 32),

            /// Text field
            Form(
              key: controller.forgetPasswordFormKey,
              child: TextFormField(
                controller: controller.email,
                validator: OValidator.validateEmail,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: OText.email),
              ),
            ),
            const SizedBox(height: 24),

            /// Submit Button
            ElevatedButton(
              onPressed: () => controller.sendPasswordResetEmail(),
              child: const Text(OText.submit),
            ),
          ],
        ),
      ),
    );
  }
}
