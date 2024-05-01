import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/providers.dart';
import 'package:alertify/core/result.dart';

enum SignInStatus {
  none,
  success,
}

class SignInController extends AutoDisposeAsyncNotifier<SignInStatus> {
  @override
  FutureOr<SignInStatus> build() => SignInStatus.none;

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncLoading();

      final authRepo = ref.read(signinServiceProvider);
      final result = await authRepo.signIn(email, password);

      final failure = switch (result) {
        Success() => null,
        Err(value: final exception) => exception,
      };

      if (failure == null) {
        state = const AsyncData(SignInStatus.success);
      } else {
        state = AsyncError(failure, StackTrace.current);
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}

final signInControllerProvider =
    AsyncNotifierProvider.autoDispose<SignInController, SignInStatus>(
  () => SignInController(),
);
