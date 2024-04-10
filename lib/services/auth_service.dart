import 'package:firebase_auth/firebase_auth.dart';

import '../core/result.dart';
import '../core/typedefs.dart';
import '../failures/auth_failure.dart';

extension type AuthService(FirebaseAuth auth) {
  FutureAuthResult<void, SignInAuthFailure> signIn(
      String email, String password) async {
    try {
      final credentials = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credentials.user;

      if (user != null) {
        Success(user);
      }

      return Error(SignInAuthFailure.userNotFound);
    } on FirebaseAuthException catch (e) {
      final failure = SignInAuthFailure.values.firstWhere(
        (it) => it.code == e.code,
        orElse: () => SignInAuthFailure.unknown,
      );
      return Error(failure);
    } catch (e) {
      return Error(SignInAuthFailure.unknown);
    }
  }
}
