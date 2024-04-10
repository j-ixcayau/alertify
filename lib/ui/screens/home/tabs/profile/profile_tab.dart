import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/services/auth_service.dart';
import 'package:alertify/ui/screens/auth/auth_screen.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/theme/palette.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final authService = AuthService(FirebaseAuth.instance);

  Future<void> signOut() async {
    await showLoader(
      context,
      authService.signOut(),
    );

    return context.pushNamedAndRemoveUntil<void>(AuthScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const CircleAvatar(radius: 50),
              const SizedBox(height: 10),
              const Text(
                'username',
                textAlign: TextAlign.center,
              ),
              Text(
                'email',
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: Palette.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => signOut(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.darkGray,
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Palette.pink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
