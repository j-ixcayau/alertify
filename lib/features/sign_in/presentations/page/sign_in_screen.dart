import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/failures/auth_failure.dart';
import 'package:alertify/ui/screens/home/home_screen.dart';
import 'package:alertify/features/sign_in/presentations/controller/sign_in_controller.dart';
import 'package:alertify/ui/screens/sign_up/sign_up_screen.dart';
import 'package:alertify/ui/shared/dialogs/error_dialog.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/auth_failure_x.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/validators/form_validator.dart';
import 'package:alertify/ui/shared/widgets/flutter_masters_rich_text.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const String route = '/sign_in';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  (Completer<void>, Future<dynamic>)? _completer;

  final formKey = GlobalKey<FormState>();
  var email = '';
  var password = '';

  Future<void> _signIn() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    ref.read(signInControllerProvider.notifier).signIn(email, password);
  }

  Future<void> _showLoader() async {
    _completer?.$1.complete();
    await _completer?.$2;

    _completer = showLoaderCompleter(context);
  }

  Future<void> _hideLoader() async {
    if (_completer == null) {
      return;
    }

    _completer!.$1.complete();
    await _completer!.$2;

    _completer = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signInControllerProvider, (_, next) {
      next.when(
        data: (status) async {
          await _hideLoader();

          if (status != SignInStatus.success) {
            return;
          }

          context.pushNamedAndRemoveUntil<void>(HomeScreen.route);
        },
        error: (e, s) async {
          await _hideLoader();

          if (e is! SignInAuthFailure) {
            // Handle other errors
            return;
          }

          final data = e.errorData;

          ErrorDialog.show(
            context,
            title: data.message,
            icon: data.icon,
          );
        },
        loading: () {
          _showLoader();
        },
      );
    });

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
                      onPressed: _signIn,
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
