import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/services/auth_service.dart';
import 'package:alertify/services/friendship_service.dart';
import 'package:alertify/ui/screens/search/widgets/app_bar.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => loadFriendshipRequest());

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
      ),
      body: switch (state) {
        SearchLoadingState() =>
          const Center(child: CircularProgressIndicator()),
        SearchLoadedState(friends: final friends) when friends.isEmpty =>
          const Center(
            child: Text('You have no friends'),
          ),
        SearchLoadedState(friends: final friends) => UserList(
            data: friends,
            builder: (context, data) {
              return UserTile(
                onPressed: () {},
                username: data.user.username,
                email: data.user.email,
              );
            },
          ),
        SearchLoadedErrorState(error: final error) => Text(error),
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
}
