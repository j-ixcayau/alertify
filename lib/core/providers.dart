import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/features/sign_in/data/services/sigin_in_service.dart';
import 'package:alertify/features/sign_in/domain/repositories/sigin_in_repository.dart';

final signinServiceProvider = Provider<SigninRepository>(
  (ref) => SigninService(
    client: FirebaseAuth.instance,
  ),
);
