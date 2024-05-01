import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/providers.dart';
import 'package:alertify/core/result.dart';

final friendhsipDataProvider = FutureProvider.autoDispose(
  (ref) async {
    final userId = ref.watch(userServiceProvider).userId;
    final result =
        await ref.watch(friendshipServiceProvider).getFriends(userId);

    return switch (result) {
      Success(value: final friends) => friends,
      Err(value: final failure) => throw Exception(failure.message),
    };
  },
);
