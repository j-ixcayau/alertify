import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/failures/auth_failure.dart';

abstract interface class AuthRepo {
  FutureAuthResult<AppUser, SignUpAuthFailure> signUp(
    String email,
    String password,
  );

  Future<void> logout();

  // TODO: Remover estos getters
  bool get logged;
  String get currentUserId;
}
