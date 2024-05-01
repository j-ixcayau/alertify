import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/failures/auth_failure.dart';
import 'package:alertify/features/sign_in/domain/repositories/sigin_in_repository.dart';

class SigninService implements SigninRepository {
  SigninService({
    required FirebaseAuth client,
  }) : _client = client;

  final FirebaseAuth _client;

  @override
  FutureAuthResult<void, SignInAuthFailure> signIn(
    String email,
    String password,
  ) async {
    try {
      final credentials = await _client.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credentials.user;
      if (user != null) {
        return Success(null);
      }
      return Err(SignInAuthFailure.userNotFound);
    } on FirebaseAuthException catch (e) {
      return Err(
        SignInAuthFailure.values.firstWhere(
          (failure) => failure.code == e.code,
          orElse: () => SignInAuthFailure.unknown,
        ),
      );
    } catch (_) {
      return Err(SignInAuthFailure.unknown);
    }
  }
}
