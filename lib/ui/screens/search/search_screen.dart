import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/friendship.dart';
import 'package:alertify/main.dart';
import 'package:alertify/repositories/auth_repo.dart';
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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  static const String route = '/search';

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late AuthRepo authRepo;
  final _friendshipService = FriendshipService(FirebaseFirestore.instance);

  SearchState _state = const SearchLoadingState();
  late String _userId;

  final _controller = TextEditingController(text: '');

  @override
  void initState() {
    authRepo = ref.read(authRepoProvider);
    _userId = authRepo.currentUserId;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadFriendshipRequest(),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSearch: (email) => searchUser(email),
        controller: _controller,
      ),
      body: switch (_state) {
        SearchLoadingState() =>
          const Center(child: CircularProgressIndicator()),
        SearchLoadedState(friends: final friends) when friends.isEmpty =>
          const Center(
            child: Text('You have no friends'),
          ),
        SearchLoadedState(friends: final friends) => RefreshIndicator(
            onRefresh: () async {
              final email = _controller.text.trim();

              await searchUser(email);
            },
            child: UserList(
              data: friends,
              builder: (context, data) {
                final friendship = data.friendship;
                final status = friendship?.status;

                return switch (status) {
                  (null || FriendshipStatus.archived) => UserTile(
                      onPressed: () => _sendFriendship(data),
                      username: data.user.username,
                      email: data.user.email,
                      trailingIcon: Icons.person_add,
                    ),
                  FriendshipStatus.pending
                      when friendship?.senderId == _userId =>
                    UserTile(
                      onPressed: () => _cancelFriendship(data),
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

  Future<void> searchUser(String email) async {
    if (email.isEmpty) {
      return;
    }

    final emailCheckMsg = FormValidator.email(email);
    if (emailCheckMsg != null) {
      return;
    }

    await _searchUser(email);
  }

  Future<void> _loadFriendshipRequest() async {
    setState(() => _state = const SearchLoadingState());

    final result =
        await _friendshipService.getFriendshipsRequest(authRepo.currentUserId);

    _state = switch (result) {
      Success(value: final friends) => SearchLoadedState(friends: friends),
      Err(value: final failure) =>
        SearchLoadedErrorState(error: failure.message),
    };

    setState(() {});
  }

  Future<void> _searchUser(String email) async {
    setState(() => _state = const SearchLoadingState());

    final result =
        await _friendshipService.searchUser(authRepo.currentUserId, email);

    _state = switch (result) {
      Success(value: final friendship) =>
        SearchLoadedState(friends: [friendship]),
      Err(value: final failure) =>
        SearchLoadedErrorState(error: failure.message)
    };

    setState(() {});
  }

  Future<void> _sendFriendship(FriendshipData friendshipData) async {
    final result = await showLoader(
      context,
      _friendshipService.sendFriendshipRequest(_userId, friendshipData.user.id),
    );

    final friendship = switch (result) {
      Success(value: final friendship) =>
        _addNewData(friendship, friendshipData),
      Err() => _data
    };

    _state = SearchLoadedState(friends: friendship);
    setState(() {});
  }

  List<FriendshipData> get _data => switch (_state) {
        SearchLoadedState(friends: final friends) => friends,
        _ => []
      };

  Future<void> _cancelFriendship(FriendshipData data) async {
    final friendship = data.friendship;

    if (friendship == null) {
      return;
    }

    final result = await showLoader(
      context,
      _friendshipService.cancelFriendshipRequest(friendship.id),
    );

    final friendshipData = switch (result) {
      Success() => _addNewData(
          Friendship(
            id: friendship.id,
            status: FriendshipStatus.archived,
            createdAt: friendship.createdAt,
            updatedAt: DateTime.now(),
            senderId: friendship.senderId,
            users: friendship.users,
          ),
          data,
        ),
      Err() => _data
    };

    _state = SearchLoadedState(friends: friendshipData);
    setState(() {});
  }

  List<FriendshipData> _addNewData(
    Friendship friendship,
    FriendshipData friendshipData,
  ) {
    final friendshipsList = [..._data];

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
}
