import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/friendship.dart';
import 'package:alertify/extensions/documents_snapshot_x.dart';
import 'package:alertify/failures/failure.dart';
import 'package:alertify/features/friendship/domain/repositories/friendship_repository.dart';
import 'package:alertify/ui/shared/extensions/iterable_x.dart';

class FriendshipService implements FriendshipRepository {
  FriendshipService({
    required FirebaseFirestore db,
  }) : _db = db;

  final FirebaseFirestore _db;

  CollectionReference<Json> get _collection => _db.collection('friendships');
  CollectionReference<Json> get _userCollection => _db.collection('users');

  @override
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
      return Err(Failure(message: e.toString()));
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

  @override
  FutureResult<void> cancelFriendshipRequest(String friendshipId) async {
    try {
      final ref = _collection.doc(friendshipId);
      final snapshot = await ref.get();
      if (!snapshot.exists) {
        return Err(Failure(message: 'Friendship does not exists'));
      }
      await ref.set(
        {
          'status': FriendshipStatus.archived.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return Success(null);
    } catch (e) {
      return Err(Failure(message: e.toString()));
    }
  }
}
