class Friendship {
  const Friendship({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.senderId,
    required this.users,
  });

  final String id;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String senderId;
  final List<String> users;
}

enum FriendshipStatus {
  pending,
  active,
  archived,
}
