import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/services/auth_service.dart';
import 'package:alertify/services/friendship_service.dart';
import 'package:alertify/ui/screens/home/tabs/friends/widgets/app_bar.dart';
import 'package:alertify/ui/screens/search/search_screen.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/widgets/user_list.dart';
import 'package:alertify/ui/shared/widgets/user_tile.dart';

sealed class FriendState {
  const FriendState();
}

class FriendLoadingState extends FriendState {
  const FriendLoadingState();
}

class FriendLoadedState extends FriendState {
  const FriendLoadedState({
    required this.friends,
  });

  final List<FriendshipData> friends;
}

class FriendLoadErrorState extends FriendState {
  const FriendLoadErrorState({
    required this.error,
  });

  final String error;
}

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final authService = AuthService(FirebaseAuth.instance);
  final friendshipService = FriendshipService(FirebaseFirestore.instance);

  FriendState state = const FriendLoadingState();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => loadFriends());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          FriendsAppbar(onAdd: () => context.pushNamed(SearchScreen.route)),
          Expanded(
            child: switch (state) {
              FriendLoadingState() =>
                const Center(child: CircularProgressIndicator()),
              FriendLoadedState(friends: final friends) when friends.isEmpty =>
                const Center(
                  child: Text('You have no friends'),
                ),
              FriendLoadedState(friends: final friends) => UserList(
                  data: friends,
                  builder: (context, data) {
                    return UserTile(
                      onPressed: () {},
                      username: data.user.username,
                      email: data.user.email,
                    );
                  },
                ),
              FriendLoadErrorState(error: final error) => Text(error),
            },
          ),
        ],
      ),
    );
  }

  Future<void> loadFriends() async {
    setState(() => state = const FriendLoadingState());

    final result = await friendshipService.getFriends(authService.userId);

    state = switch (result) {
      Success(value: final friends) => FriendLoadedState(friends: friends),
      Err(value: final failure) => FriendLoadErrorState(error: failure.message),
    };

    setState(() {});
  }
}
