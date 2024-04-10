import 'package:flutter/material.dart';

import 'package:alertify/failures/failure.dart';
import 'package:alertify/core/result.dart';

typedef Json = Map<String, dynamic>;
typedef FutureAuthResult<T, E> = Future<Result<T, E>>;
typedef FutureResult<T> = Future<Result<T, Failure>>;
typedef UserListItemBuilder<T> = Widget Function(BuildContext, T);
