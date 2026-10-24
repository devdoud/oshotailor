import 'package:flutter/material.dart';
import 'package:osho/common/widgets/atelier/atelier.dart';
import 'package:osho/features/authentication/screens/login/widgets/login_form.dart';
import 'package:osho/features/authentication/screens/login/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(kGutter, 24, kGutter, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// Headline Title
              OLoginHeader(),

              /// Form
              OLoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
