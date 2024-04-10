import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/services/auth_service.dart';
import 'package:alertify/ui/screens/auth/auth_screen.dart';
import 'package:alertify/ui/screens/home/home_screen.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final authService = AuthService(FirebaseAuth.instance);

  @override
  void initState() {
    Future<void>.delayed(
      const Duration(seconds: 3),
      () {
        final path = authService.logged ? HomeScreen.route : AuthScreen.route;

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
