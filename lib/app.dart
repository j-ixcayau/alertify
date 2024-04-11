import 'package:flutter/material.dart';

import 'package:alertify/ui/screens/auth/auth_screen.dart';
import 'package:alertify/ui/screens/home/home_screen.dart';
import 'package:alertify/ui/screens/search/search_screen.dart';
import 'package:alertify/ui/screens/sign_in/sign_in_screen.dart';
import 'package:alertify/ui/screens/sign_up/sign_up_screen.dart';
import 'package:alertify/ui/screens/splash/splash_screen.dart';
import 'package:alertify/ui/shared/theme/app_theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routes: {
          SplashScreen.route: (_) => const SplashScreen(),
          AuthScreen.route: (_) => const AuthScreen(),
          SignInScreen.route: (_) => const SignInScreen(),
          SignUpScreen.route: (_) => const SignUpScreen(),
          HomeScreen.route: (_) => const HomeScreen(),
          SearchScreen.route: (_) => const SearchScreen(),
        },
      ),
    );
  }
}
