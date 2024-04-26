import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:alertify/app.dart';
import 'package:alertify/firebase_options.dart';

void main() async {
  runZonedGuarded(
    () async {
      await SentryFlutter.init(
        (options) {
          options.dsn =
              'https://45708111855b9caac650f65f8e0c14fb@o4506367206948864.ingest.us.sentry.io/4507153958305792';
          options.environment = 'dev';
        },
      );

      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      runApp(const MainApp());
    },
    (exception, stackTrace) async {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    },
  );
}
