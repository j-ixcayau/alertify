import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/providers.dart';
import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';

class FriendshipController
    extends AutoDisposeAsyncNotifier<List<FriendshipData>> {
  @override
  FutureOr<List<FriendshipData>> build() async {
    final userId = ref.watch(userServiceProvider).userId;
    final result =
        await ref.watch(friendshipServiceProvider).getFriends(userId);

    return switch (result) {
      Success(value: final friends) => friends,
      Err(value: final failure) => throw Exception(failure.message),
    };
  }

  Future<void> delete(FriendshipData friendshipData) async {
    final currentFriendships = state.requireValue;
    state = await AsyncValue.guard(() async {
      final repository = ref.read(friendshipServiceProvider);
      final result = await repository.cancelFriendshipRequest(
        friendshipData.friendship!.id,
      );

      return switch (result) {
        Success() => currentFriendships..remove(friendshipData),
        Err() => currentFriendships,
      };
    });
  }
}

final friendshipControllerProvider = AsyncNotifierProvider.autoDispose<
    FriendshipController, List<FriendshipData>>(FriendshipController.new);
