import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/typedefs.dart';
import 'package:alertify/features/friendship/presentation/controller/friendship_controller.dart';
import 'package:alertify/ui/screens/home/tabs/friends/widgets/app_bar.dart';
import 'package:alertify/ui/screens/search/search_screen.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/widgets/user_list.dart';
import 'package:alertify/ui/shared/widgets/user_tile.dart';

class FriendsTab extends ConsumerWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendship = ref.watch(friendshipControllerProvider);

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          FriendsAppbar(onAdd: () => context.pushNamed(SearchScreen.route)),
          Expanded(
            child: switch (friendship) {
              AsyncLoading() =>
                const Center(child: CircularProgressIndicator()),
              AsyncError(:final error) => Text(error.toString()),
              AsyncData(value: final friends) when friends.isEmpty =>
                const Center(
                  child: Text('You have no friends'),
                ),
              AsyncData(value: final friends) => UserList(
                  data: friends,
                  builder: (context, data) {
                    return UserTile(
                      onPressed: () => _onDelete(ref, context, data),
                      username: data.user.username,
                      email: data.user.email,
                    );
                  },
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onDelete(
    WidgetRef ref,
    BuildContext context,
    FriendshipData data,
  ) async {
    showLoader(
      context,
      ref.read(friendshipControllerProvider.notifier).delete(data),
    );
  }
}
