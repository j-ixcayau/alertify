import 'package:alertify/core/typedefs.dart';

abstract interface class FriendshipRepository {
  FutureResult<List<FriendshipData>> getFriends(String userId);
}
