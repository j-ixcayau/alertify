import 'package:alertify/core/typedefs.dart';
import 'package:alertify/failures/auth_failure.dart';

abstract interface class SigninRepository {
  FutureAuthResult<void, SignInAuthFailure> signIn(
    String email,
    String password,
  );
}
