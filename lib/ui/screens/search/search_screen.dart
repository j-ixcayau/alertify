import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/friendship.dart';
import 'package:alertify/services/auth_service.dart';
import 'package:alertify/services/friendship_service.dart';
import 'package:alertify/ui/screens/search/widgets/app_bar.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/validators/form_validator.dart';
import 'package:alertify/ui/shared/widgets/user_list.dart';
import 'package:alertify/ui/shared/widgets/user_tile.dart';

sealed class SearchState {
  const SearchState();
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

class SearchLoadedState extends SearchState {
  const SearchLoadedState({
    required this.friends,
  });

  final List<FriendshipData> friends;
}

class SearchLoadedErrorState extends SearchState {
  const SearchLoadedErrorState({
    required this.error,
  });

  final String error;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const String route = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final authService = AuthService(FirebaseAuth.instance);
  final friendshipService = FriendshipService(FirebaseFirestore.instance);

  SearchState state = const SearchLoadingState();
  late String userId;

  final controller = TextEditingController(text: '');

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadFriendshipRequest());

    userId = authService.userId;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSearch: (email) {
          if (email.isEmpty) {
            return;
          }

          final emailCheckMsg = FormValidator.email(email);
          if (emailCheckMsg != null) {
            return;
          }

          searchUser(email);
        },
        controller: controller,
      ),
      body: switch (state) {
        SearchLoadingState() =>
          const Center(child: CircularProgressIndicator()),
        SearchLoadedState(friends: final friends) when friends.isEmpty =>
          const Center(
            child: Text('You have no friends'),
          ),
        SearchLoadedState(friends: final friends) => RefreshIndicator(
            onRefresh: () async {
              final email = controller.text.trim();

              if (email.isEmpty) {
                return;
              }

              final emailCheckMsg = FormValidator.email(email);
              if (emailCheckMsg != null) {
                return;
              }

              await searchUser(email);
            },
            child: UserList(
              data: friends,
              builder: (context, data) {
                final user = data.user;
                final friendship = data.friendship;
                final status = friendship?.status;

                return switch (status) {
                  (null || FriendshipStatus.archived) => UserTile(
                      onPressed: () => sendFriendship(data),
                      username: data.user.username,
                      email: data.user.email,
                      trailingIcon: Icons.person_add,
                    ),
                  FriendshipStatus.pending
                      when friendship?.senderId == userId =>
                    UserTile(
                      // TODO: Add method to cancel friendship
                      onPressed: () {},
                      username: data.user.username,
                      email: data.user.email,
                      trailingIcon: Icons.remove_circle_outline,
                    ),
                  FriendshipStatus.pending => UserTile(
                      // TODO: Add method to accept friendship
                      onPressed: () {},
                      username: data.user.username,
                      email: data.user.email,
                    ),
                  FriendshipStatus.active => UserTile(
                      // TODO: Add method to delete friendship
                      onPressed: () {},
                      username: data.user.username,
                      email: data.user.email,
                    ),
                };
              },
            ),
          ),
        SearchLoadedErrorState(error: final error) =>
          Center(child: Text(error)),
      },
    );
  }

  Future<void> loadFriendshipRequest() async {
    setState(() => state = const SearchLoadingState());

    final result =
        await friendshipService.getFriendshipsRequest(authService.userId);

    state = switch (result) {
      Success(value: final friends) => SearchLoadedState(friends: friends),
      Error(value: final failure) =>
        SearchLoadedErrorState(error: failure.message),
    };

    setState(() {});
  }

  Future<void> searchUser(String email) async {
    setState(() => state = const SearchLoadingState());

    final result =
        await friendshipService.searchUser(authService.userId, email);

    state = switch (result) {
      Success(value: final friendship) =>
        SearchLoadedState(friends: [friendship]),
      Error(value: final failure) =>
        SearchLoadedErrorState(error: failure.message)
    };

    setState(() {});
  }

  Future<void> sendFriendship(FriendshipData friendshipData) async {
    final result = await showLoader(
      context,
      friendshipService.sendFriendshipRequest(userId, friendshipData.user.id),
    );

    final friendship = switch (result) {
      Success(value: final friendship) =>
        addNewData(friendship, friendshipData),
      Error() => data
    };

    state = SearchLoadedState(friends: friendship);
    setState(() {});
  }

  List<FriendshipData> addNewData(
    Friendship friendship,
    FriendshipData friendshipData,
  ) {
    final friendshipsList = [...data];

    final index = friendshipsList
        .indexWhere((it) => it.user.id == friendshipData.user.id);

    if (index != -1) {
      friendshipsList[index] = (
        user: friendshipsList[index].user,
        friendship: friendship,
      );
    }

    return friendshipsList;
  }

  List<FriendshipData> get data => switch (state) {
        SearchLoadedState(friends: final friends) => friends,
        _ => []
      };
}
