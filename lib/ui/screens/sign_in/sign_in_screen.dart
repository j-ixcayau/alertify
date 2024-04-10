import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/services/auth_service.dart';
import 'package:alertify/ui/screens/home/home_screen.dart';
import 'package:alertify/ui/screens/sign_up/sign_up_screen.dart';
import 'package:alertify/ui/shared/dialogs/error_dialog.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/auth_failure_x.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/validators/form_validator.dart';
import 'package:alertify/ui/shared/widgets/flutter_masters_rich_text.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String route = '/sign_in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final authService = AuthService(FirebaseAuth.instance);

  late final formKey = GlobalKey<FormState>();
  var email = '';
  var password = '';

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final result = await showLoader(
      context,
      authService.signIn(email, password),
    );

    final failure = switch (result) {
      Success() => null,
      Error(value: final exception) => exception,
    };

    if (failure != null) {
      final data = failure.errorData;

      ErrorDialog.show(
        context,
        title: data.message,
        icon: data.icon,
      );
      return;
    }

    return context.pushNamedAndRemoveUntil<void>(HomeScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      validator: FormValidator.email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Your email here',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      onChanged: (value) => setState(() => email = value),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      validator: FormValidator.password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Your password here',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      onChanged: (value) => setState(() => password = value),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: signIn,
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 56),
                    FlutterMastersRichText(
                      text: 'Don’t have an Account?',
                      secondaryText: 'Sign Up',
                      onTap: () => context.pushNamed(SignUpScreen.route),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
