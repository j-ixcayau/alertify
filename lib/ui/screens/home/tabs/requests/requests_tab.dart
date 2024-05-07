import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/providers.dart';
import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/failures/failure.dart';
import 'package:alertify/main.dart';
import 'package:alertify/repositories/auth_repo.dart';
import 'package:alertify/services/friendship_service.dart';
import 'package:alertify/ui/screens/home/tabs/requests/widgets/app_bar.dart';
import 'package:alertify/ui/screens/home/tabs/requests/widgets/request_tile.dart';
import 'package:alertify/ui/shared/dialogs/loader_dialog.dart';
import 'package:alertify/ui/shared/extensions/build_context.dart';
import 'package:alertify/ui/shared/widgets/user_list.dart';

sealed class RequestState {
  const RequestState();
}

class RequestLoadingState extends RequestState {
  const RequestLoadingState();
}

class RequestLoadedState extends RequestState {
  const RequestLoadedState({
    required this.friends,
  });

  final List<FriendshipData> friends;
}

class RequestLoadedErrorState extends RequestState {
  const RequestLoadedErrorState({
    required this.error,
  });

  final String error;
}

class RequestsTab extends ConsumerStatefulWidget {
  const RequestsTab({super.key});

  @override
  ConsumerState<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends ConsumerState<RequestsTab> {
  late AuthRepo authRepo;
  final friendshipsService = FriendshipService(FirebaseFirestore.instance);
  String get userId => ref.read(userServiceProvider).userId;

  RequestState state = const RequestLoadingState();

  @override
  void initState() {
    authRepo = ref.read(authRepoProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => loadRequests());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          const RequestsAppBar(),
          Expanded(
            child: switch (state) {
              RequestLoadingState() =>
                const Center(child: CircularProgressIndicator()),
              RequestLoadedState(friends: final friends) when friends.isEmpty =>
                const Center(
                  child: Text('You have no requests'),
                ),
              RequestLoadedState(friends: final friends) => UserList(
                  data: friends,
                  builder: (context, data) {
                    return RequestTile(
                      username: data.user.username,
                      email: data.user.email,
                      photoUrl: data.user.photoUrl,
                      onAccept: () => acceptFriendshipRequest(data),
                      onReject: () => rejectFriendshipRequest(data),
                    );
                  },
                ),
              RequestLoadedErrorState(error: final error) => Text(error),
            },
          ),
        ],
      ),
    );
  }

  Future<void> loadRequests() async {
    state = const RequestLoadingState();

    setState(() {});
    final result = await friendshipsService.getFriendshipsRequest(userId);

    state = switch (result) {
      Success(value: final requests) => RequestLoadedState(friends: requests),
      Err(value: final failure) => RequestLoadedErrorState(
          error: failure.message,
        ),
    };
    setState(() {});
  }

  Future<void> acceptFriendshipRequest(FriendshipData friendshipData) async {
    final result = await showLoader(
      context,
      friendshipsService.acceptFriendshipRequest(friendshipData.friendship!.id),
    );
    resultToState(result, friendshipData);
  }

  Future<void> rejectFriendshipRequest(FriendshipData friendshipData) async {
    final result = await showLoader(
      context,
      friendshipsService.rejectFriendshipRequest(
        friendshipData.friendship!.id,
      ),
    );
    resultToState(result, friendshipData);
  }

  void resultToState(
    Result<void, Failure> result,
    FriendshipData friendshipData,
  ) {
    final data = switch (state) {
      RequestLoadedState(friends: final data) => data,
      _ => <FriendshipData>[],
    };
    final friendshipsData = switch (result) {
      Success() => [...data]..remove(friendshipData),
      Err() => data,
    };
    state = RequestLoadedState(friends: friendshipsData);
    setState(() {});
  }
}
