import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/main.dart';
import 'package:alertify/services/user_service.dart';

final profileDataProvider = FutureProvider.autoDispose((ref) async {
  final userService = UserService(FirebaseFirestore.instance);
  final currentUserId = ref.watch(authRepoProvider).currentUserId;

  final result = await userService.userFromId(currentUserId);

  return switch (result) {
    Success(value: final user) => user,
    Err(value: final exception) => throw Exception(exception.message),
  };
});
