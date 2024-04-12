import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/services/auth_service.dart';
import 'package:alertify/services/user_service.dart';
import 'package:alertify/ui/screens/auth/auth_screen.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/theme/palette.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({required this.user});

  final AppUser user;
}

class ProfileLoadedErrorState extends ProfileState {
  const ProfileLoadedErrorState({required this.error});

  final String error;
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final authService = AuthService(FirebaseAuth.instance);
  final userService = UserService(FirebaseFirestore.instance);
  ProfileState state = const ProfileLoadingState();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => loadUser());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: switch (state) {
            ProfileLoadingState() =>
              const Center(child: CircularProgressIndicator()),
            ProfileLoadedState(user: final user) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  CircleAvatar(
                    radius: 50,
                    child: (user.photoUrl != null)
                        ? Image(
                            image: NetworkImage(user.photoUrl!),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.username,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'email: ${user.email}',
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
            ProfileLoadedErrorState(error: final error) => Text(error),
          },
        ),
      ),
    );
  }

  Future<void> loadUser() async {
    setState(() => state = const ProfileLoadingState());

    final result = await userService.userFromId(authService.userId);

    final newState = switch (result) {
      Success(value: final user) => ProfileLoadedState(user: user),
      Error(value: final exception) =>
        ProfileLoadedErrorState(error: exception.message),
    };

    setState(() => state = newState);
  }

  Future<void> signOut() async {
    await showLoader(
      context,
      authService.signOut(),
    );

    return context.pushNamedAndRemoveUntil<void>(AuthScreen.route);
  }
}
