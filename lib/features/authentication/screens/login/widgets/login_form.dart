import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:osho/utils/constants/text_strings.dart';
import 'package:osho/utils/validators/validation.dart';

class OLoginForm extends StatelessWidget {
  const OLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final t = context.osho;

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Email input
              TextFormField(
                controller: controller.email,
                validator: (value) => OValidator.validateEmail(value),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: OText.email),
              ),
              const SizedBox(height: 16),

              /// Password
              Obx(
                () => TextFormField(
                  controller: controller.password,
                  validator: (value) => OValidator.validateLoginPassword(value),
                  obscureText: controller.hidePassword.value,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => controller.emailAndPasswordSignIn(),
                  decoration: InputDecoration(
                    labelText: OText.password,
                    suffixIcon: IconButton(
                      tooltip: controller.hidePassword.value
                          ? 'Afficher le mot de passe'
                          : 'Masquer le mot de passe',
                      onPressed: () => controller.hidePassword.value =
                          !controller.hidePassword.value,
                      icon: OIcon(
                        controller.hidePassword.value
                            ? OIcons.eye
                            : OIcons.eyeOff,
                        size: 20,
                        color: t.muted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              /// Remember me & Forgot Password
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => MergeSemantics(
                        child: InkWell(
                          onTap: () => controller.rememberMe.value =
                              !controller.rememberMe.value,
                          child: Row(
                            children: [
                              Checkbox(
                                value: controller.rememberMe.value,
                                onChanged: (value) =>
                                    controller.rememberMe.value = value ?? false,
                              ),
                              Flexible(
                                child: Text(OText.rememberMe,
                                    style: OType.text(OType.secondary, t.ink)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const ForgetPassword()),
                    child: Text(OText.forgotPassword,
                        style: OType.text(OType.secondary, t.accent,
                            weight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// Sign In Button
              ElevatedButton(
                onPressed: () => controller.emailAndPasswordSignIn(),
                child: const Text(OText.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
