import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/failures/auth_failure.dart';

extension type AuthService(FirebaseAuth auth) {
  FutureAuthResult<void, SignInAuthFailure> signIn(
    String email,
    String password,
  ) async {
    try {
      final credentials = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credentials.user;

      if (user != null) {
        return Success(null);
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

  FutureAuthResult<AppUser, SignInAuthFailure> signUp(
    String email,
    String password,
  ) async {
    try {
      final credentials = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credentials.user;

      if (user != null) {
        return Success(
          AppUser(
            id: user.uid,
            username: user.displayName ?? '',
            email: user.email ?? '',
            photoUrl: user.photoURL,
          ),
        );
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

  Future<void> signOut() => auth.signOut();

  bool get logged => auth.currentUser != null;
  String get userId => auth.currentUser?.uid ?? '';

  (bool, String?) get isLogged =>
      (auth.currentUser != null, auth.currentUser?.uid);
}
