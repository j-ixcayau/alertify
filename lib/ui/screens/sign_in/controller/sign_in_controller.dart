import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/services/auth_service.dart';

enum SignInStatus {
  none,
  success,
}

class SignInController extends AsyncNotifier<SignInStatus> {
  final _authService = AuthService(FirebaseAuth.instance);

  @override
  FutureOr<SignInStatus> build() => SignInStatus.none;

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncLoading();

      final result = await _authService.signIn(email, password);

      final failure = switch (result) {
        Success() => null,
        Error(value: final exception) => exception,
      };

      if (failure == null) {
        state = const AsyncData(SignInStatus.success);
      } else {
        state = AsyncError(failure, StackTrace.current);
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    } finally {
      //
    }
  }
}

final signInControllerProvider =
    AsyncNotifierProvider<SignInController, SignInStatus>(
  () => SignInController(),
);
