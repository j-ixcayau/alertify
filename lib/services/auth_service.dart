import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/failures/auth_failure.dart';
import 'package:alertify/repositories/auth_repo.dart';

class FirebaseAuthAdapter implements AuthRepo {
  const FirebaseAuthAdapter(this.client);
  final FirebaseAuth client;

  @override
  FutureAuthResult<AppUser, SignUpAuthFailure> signUp(
    String email,
    String password,
  ) async {
    try {
      final credentials = await client.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credentials.user;
      if (user != null) {
        return Success(
          AppUser(
            id: user.uid,
            email: email,
            username: user.displayName ?? '',
            photoUrl: user.photoURL,
          ),
        );
      }
      return Err(SignUpAuthFailure.userNotCreate);
    } on FirebaseAuthException catch (e) {
      return Err(
        SignUpAuthFailure.values.firstWhere(
          (failure) => failure.code == e.code,
          orElse: () => SignUpAuthFailure.unknown,
        ),
      );
    } catch (e) {
      return Err(SignUpAuthFailure.unknown);
    }
  }

  @override
  bool get logged => client.currentUser != null;

  @override
  String get currentUserId => client.currentUser?.uid ?? '';

  @override
  Future<void> logout() => client.signOut();
}

// extension type AuthService(FirebaseAuth auth) {
//   FutureAuthResult<void, SignInAuthFailure> signIn({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final credentials = await auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final user = credentials.user;
//       if (user != null) {
//         return Success(null);
//       }
//       return Err(SignInAuthFailure.userNotFound);
//     } on FirebaseAuthException catch (e) {
//       return Err(
//         SignInAuthFailure.values.firstWhere(
//           (failure) => failure.code == e.code,
//           orElse: () => SignInAuthFailure.unknown,
//         ),
//       );
//     } catch (_) {
//       return Err(SignInAuthFailure.unknown);
//     }
//   }

//   FutureAuthResult<AppUser, SignUpAuthFailure> signUp({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final credentials = await auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final user = credentials.user;
//       if (user != null) {
//         return Success(
//           AppUser(
//             id: user.uid,
//             email: email,
//             username: user.displayName ?? '',
//             photoUrl: user.photoURL,
//           ),
//         );
//       }
//       return Err(SignUpAuthFailure.userNotCreate);
//     } on FirebaseAuthException catch (e) {
//       return Err(
//         SignUpAuthFailure.values.firstWhere(
//           (failure) => failure.code == e.code,
//           orElse: () => SignUpAuthFailure.unknown,
//         ),
//       );
//     } catch (e) {
//       return Err(SignUpAuthFailure.unknown);
//     }
//   }

//   Future<void> logout() => auth.signOut();

//   bool get logged => auth.currentUser != null;
//   String get currentUserId => auth.currentUser!.uid;
// }