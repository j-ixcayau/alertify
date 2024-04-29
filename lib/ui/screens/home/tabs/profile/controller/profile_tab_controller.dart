import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/services/auth_service.dart';
import 'package:alertify/services/user_service.dart';

final profileDataProvider = FutureProvider.autoDispose((ref) async {
  final userService = UserService(FirebaseFirestore.instance);
  final authService = AuthService(FirebaseAuth.instance);

  final result = await userService.userFromId(authService.userId);

  return switch (result) {
    Success(value: final user) => user,
    Err(value: final exception) => throw Exception(exception.message),
  };
});
