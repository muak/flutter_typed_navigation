import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

class ModalTabScreen extends TabBaseWidget {
  const ModalTabScreen({super.key, required super.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(config.currentIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: ref.watch(config.childrenProvider),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: config.setCurrentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}