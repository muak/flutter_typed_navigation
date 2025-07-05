import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

// ignore: must_be_immutable
class MockApp extends ConsumerWidget {
  MockApp({super.key});
  late NavigationRouterDelegate routerDelegate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    routerDelegate = ref.read(navigationRouterDelegateProvider);

    return NavigationApp(
      ref: ref,
      title: 'Mock App',      
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
