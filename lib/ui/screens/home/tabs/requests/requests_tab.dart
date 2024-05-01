import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/main.dart';
import 'package:alertify/repositories/auth_repo.dart';
import 'package:alertify/services/friendship_service.dart';
import 'package:alertify/ui/screens/home/tabs/requests/widgets/app_bar.dart';
import 'package:alertify/ui/screens/home/tabs/requests/widgets/request_tile.dart';
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
  final friendshipService = FriendshipService(FirebaseFirestore.instance);

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
                      onAccept: () {},
                      onReject: () {},
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
    setState(() => state = const RequestLoadingState());

    final result =
        await friendshipService.getFriendshipsRequest(authRepo.currentUserId);

    state = switch (result) {
      Success(value: final friends) => RequestLoadedState(friends: friends),
      Err(value: final failure) =>
        RequestLoadedErrorState(error: failure.message),
    };

    setState(() {});
  }
}
