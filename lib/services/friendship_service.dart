import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/friendship.dart';
import 'package:alertify/extensions/documents_snapshot_x.dart';
import 'package:alertify/failures/failure.dart';
import 'package:alertify/ui/shared/extensions/iterable_x.dart';

extension type FriendshipService(FirebaseFirestore db) {
  CollectionReference<Json> get _collection => db.collection('friendships');
  CollectionReference<Json> get _userCollection => db.collection('users');

  FutureResult<List<FriendshipData>> getFriends(String userId) async {
    try {
      final friendships = await _getFriendshipIds(userId);

      if (friendships.isEmpty) {
        return Success([]);
      }

      final friendshipIds = friendships
          .map((it) => it.users.firstWhereOrNull((id) => id != userId))
          .toList();
      friendshipIds.removeWhere((it) => it == null);

      final query =
          _userCollection.orderBy('email').where('id', whereIn: friendshipIds);

      final result = await query.get();
      final users = result.docs.map((it) => it.toAppUser()).toList();

      final data = <FriendshipData>[];

      for (final user in users) {
        final friendship =
            friendships.firstWhereOrNull((it) => it.users.contains(user.id));

        data.add((friendship: friendship, user: user));
      }

      return Success(data);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  Future<List<Friendship>> _getFriendshipIds(String userId) async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: FriendshipStatus.active.name)
          .where('users', arrayContains: userId)
          .get();

      return snapshot.docs.map((it) => it.toFriendship()).toList();
    } catch (e) {
      rethrow;
    }
  }

  FutureResult<List<FriendshipData>> getFriendshipsRequest(
    String userId,
  ) async {
    try {
      final snapshot = await _collection
          .where('senderId', isNotEqualTo: userId)
          .where('users', arrayContains: userId)
          .where('status', isEqualTo: FriendshipStatus.pending.name)
          .get();

      final friendships = snapshot.docs.map((it) => it.toFriendship()).toList();

      if (friendships.isEmpty) {
        return Success(<FriendshipData>[]);
      }

      final userIds = friendships
          .map(
            (it) => it.users.firstWhereOrNull((id) => id != userId),
          )
          .toList();
      userIds.removeWhere((it) => it == null);

      final usersDocs =
          await _userCollection.where('id', arrayContains: userIds).get();

      final users = usersDocs.docs.map((it) => it.toAppUser()).toList();

      final data = <FriendshipData>[];

      for (final user in users) {
        final friendship =
            friendships.firstWhereOrNull((it) => it.users.contains(user.id));

        data.add((friendship: friendship, user: user));
      }

      return Success(data);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  FutureResult<FriendshipData> searchUser(String userId, String email) async {
    try {
      final userSnapshot = await _userCollection
          .where('email', isEqualTo: email)
          .where('id', isNotEqualTo: userId)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return Error(Failure(message: 'No user were found'));
      }

      final user = userSnapshot.docs.first.toAppUser();

      final friendshipSnapshot =
          await _collection.where('users', arrayContains: user.id).get();

      final userFriendshipsRequests =
          friendshipSnapshot.docs.map((it) => it.toFriendship()).toList();

      if (userFriendshipsRequests.isEmpty) {
        return Success((friendship: null, user: user));
      }

      final friendship = userFriendshipsRequests
          .firstWhereOrNull((it) => it.users.contains(userId));

      return Success((friendship: friendship, user: user));
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }
}
