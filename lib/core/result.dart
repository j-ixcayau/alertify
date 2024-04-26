import 'package:flutter/foundation.dart';

sealed class Result<T, E> {}

class Success<T, E> extends Result<T, E> {
  Success(this.value);

  final T value;
}

class Error<T, E> extends Result<T, E> {
  Error(this.value) {
    if (kDebugMode) {
      print(value.toString());
    }
  }

  final E value;
}
