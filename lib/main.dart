import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/app.dart';
import 'package:raktosewa/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  await DonorHiveService().init();
  runApp(const ProviderScope(child: MyApp()));
}
