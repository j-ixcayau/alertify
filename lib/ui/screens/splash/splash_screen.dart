import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/main.dart';
import 'package:alertify/repositories/auth_repo.dart';
import 'package:alertify/ui/screens/auth/auth_screen.dart';
import 'package:alertify/ui/screens/home/home_screen.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const String route = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late AuthRepo authRepo;

  @override
  void initState() {
    authRepo = ref.read(authRepoProvider);

    Future<void>.delayed(
      const Duration(seconds: 3),
      () {
        final path = authRepo.logged ? HomeScreen.route : AuthScreen.route;

        context.pushReplacementNamed<void>(path);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
