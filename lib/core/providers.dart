import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/mobile_auth/user_repository.dart';
import 'package:alertify/core/mobile_auth/user_service.dart';
import 'package:alertify/features/friendship/data/services/friendship_service.dart';
import 'package:alertify/features/friendship/domain/repositories/friendship_repository.dart';
import 'package:alertify/features/sign_in/data/services/sigin_in_service.dart';
import 'package:alertify/features/sign_in/domain/repositories/sigin_in_repository.dart';

final signinServiceProvider = Provider<SigninRepository>(
  (ref) => SigninService(
    client: FirebaseAuth.instance,
  ),
);

final userServiceProvider = Provider<UserRepository>(
  (ref) => UserService(
    client: FirebaseAuth.instance,
  ),
);

final friendshipServiceProvider = Provider<FriendshipRepository>(
  (ref) => FriendshipService(
    db: FirebaseFirestore.instance,
  ),
);
