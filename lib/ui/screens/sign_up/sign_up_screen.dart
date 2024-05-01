import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/main.dart';
import 'package:alertify/repositories/auth_repo.dart';
import 'package:alertify/services/user_service.dart';
import 'package:alertify/ui/screens/home/home_screen.dart';
import 'package:alertify/ui/screens/sign_in/sign_in_screen.dart';
import 'package:alertify/ui/shared/dialogs/error_dialog.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/auth_failure_x.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/validators/form_validator.dart';
import 'package:alertify/ui/shared/widgets/flutter_masters_rich_text.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  static const String route = '/sign_up';

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late AuthRepo authRepo;
  final userService = UserService(FirebaseFirestore.instance);

  late final formKey = GlobalKey<FormState>();

  var userName = '';
  var email = '';
  var password = '';

  @override
  void initState() {
    authRepo = ref.read(authRepoProvider);

    super.initState();
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
                      'Sign Up',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      validator: FormValidator.userName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: 'Your username here',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      onChanged: (value) => setState(() => userName = value),
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
                    TextFormField(
                      validator: (value) => FormValidator.confirmPassword(
                        value,
                        password,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Confirm password here',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: signUp,
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 56),
                    FlutterMastersRichText(
                      text: 'Already have an Account?',
                      secondaryText: 'Sign In',
                      onTap: () => context.pushNamed(SignInScreen.route),
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

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final result = await showLoader(
      context,
      authRepo.signUp(email, password),
    );

    final record = switch (result) {
      Success(value: final user) => (user: user, failure: null),
      Err(value: final exception) => (user: null, failure: exception),
    };

    if (record.failure != null) {
      final data = record.failure!.errorData;

      ErrorDialog.show(
        context,
        title: data.message,
        icon: data.icon,
      );
      return;
    }

    createUser(record.user!);
  }

  Future<void> createUser(AppUser createdUser) async {
    final newUser = AppUser(
      id: createdUser.id,
      username: userName,
      email: createdUser.email,
      photoUrl: createdUser.photoUrl,
    );

    final result = await showLoader(
      context,
      userService.createUser(newUser),
    );

    final route = switch (result) {
      Success() => HomeScreen.route,
      Err() => null,
    };

    if (route != null) {
      return context.pushNamedAndRemoveUntil<void>(route);
    }
  }
}
