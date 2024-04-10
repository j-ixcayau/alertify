import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:alertify/core/result.dart';
import 'package:alertify/core/typedefs.dart';
import 'package:alertify/entities/app_user.dart';
import 'package:alertify/extensions/documents_snapshot_x.dart';
import 'package:alertify/failures/failure.dart';

extension type UserService(FirebaseFirestore db) {
  CollectionReference<Json> get _collection => db.collection('users');

  FutureResult<AppUser> userFromId(String id) async {
    try {
      final result = await _collection.doc(id).get();

      if (!result.exists) {
        return Error(Failure(message: 'User not found'));
      }

      return Success(result.toAppUser());
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }

  FutureResult<AppUser> createUser(AppUser user) async {
    try {
      await _collection.doc(user.id).set(user.toMap());

      return Success(user);
    } catch (e) {
      return Error(Failure(message: e.toString()));
    }
  }
}
