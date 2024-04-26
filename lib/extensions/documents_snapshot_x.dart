import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/entities/friendship.dart';

extension DocumentSnapshotX on DocumentSnapshot<Json> {
  AppUser toAppUser() {
    return AppUser(
      id: this['id'],
      username: this['username'],
      email: this['email'],
      photoUrl: this['photoUrl'],
    );
  }

  Friendship toFriendship() {
    return Friendship(
      id: id,
      status: FriendshipStatus.values.firstWhere(
        (it) => it.name == this['status'],
        orElse: () => FriendshipStatus.archived,
      ),
      createdAt: this['createdAt'].toDate(),
      updatedAt: this['updatedAt'].toDate(),
      senderId: this['sender'],
      users: List<String>.from(this['users']),
    );
  }
}
