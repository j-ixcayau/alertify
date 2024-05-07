import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/mobile_auth/user_repository.dart';

class UserService implements UserRepository {
  UserService({
    required FirebaseAuth client,
  }) : _client = client;

  final FirebaseAuth _client;

  @override
  bool get logged => _client.currentUser != null;

  @override
  String get userId => _client.currentUser?.uid ?? '';
}
