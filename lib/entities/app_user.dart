class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
  });

  final String id;
  final String username;
  final String email;
  final String? photoUrl;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
