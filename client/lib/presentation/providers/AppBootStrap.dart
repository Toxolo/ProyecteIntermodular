import 'package:client/infrastructure/data_sources/local/app_database.dart';
import 'package:client/main.dart';
import 'package:client/presentation/providers/UserNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBootstrap extends ConsumerWidget {
  final AppDatabase db;

  const AppBootstrap({super.key, required this.db});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize ApiService singleton once
    ref.watch(apiServiceProvider);

    // Continue with your app
    return MyApp(db: db);
  }
}
