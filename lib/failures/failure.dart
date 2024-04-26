class Failure implements Exception {
  Failure({required this.message});

  final String message;

  @override
  String toString() {
    return '''Failure(
      message: $message
    )''';
  }
}
