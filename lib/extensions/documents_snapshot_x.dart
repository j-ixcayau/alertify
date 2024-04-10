import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';

extension DocumentSnapshotX on DocumentSnapshot<Json> {
  AppUser toAppUser() {
    return AppUser(
      id: this['id'],
      username: this['username'],
      email: this['email'],
      photoUrl: this['photoUrl'],
    );
  }
}
