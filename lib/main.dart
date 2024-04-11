import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:alertify/app.dart';
import 'package:alertify/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}
