import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/ui/screens/home/tabs/profile/controller/profile_tab_controller.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/theme/palette.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(profileDataProvider);

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: provider.when(
            data: (user) {
              return Column(
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
                    // onPressed: () => signOut(),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.darkGray,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Palette.pink),
                    ),
                  ),
                ],
              );
            },
            error: (e, s) {
              return const Center(
                child: Text('An unknown error occurred'),
              );
            },
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          /* child: switch (state) {
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
          }, */
        ),
      ),
    );
  }

  /* Future<void> loadUser() async {
    setState(() => state = const ProfileLoadingState());

    setState(() {});
  }

  Future<void> signOut() async {
    await showLoader(
      context,
      authService.signOut(),
    );

    return context.pushNamedAndRemoveUntil<void>(AuthScreen.route);
  } */
}
