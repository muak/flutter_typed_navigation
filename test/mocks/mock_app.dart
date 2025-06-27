import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

// ignore: must_be_immutable
class MockApp extends ConsumerWidget {
  MockApp({super.key});
  late AppRouterDelegate routerDelegate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    routerDelegate = AppRouterDelegate(ref);

    return MaterialApp.router(
      title: 'Mock App',
      routerDelegate: routerDelegate,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }

  void dispose() {
    routerDelegate.dispose();
  }
}
