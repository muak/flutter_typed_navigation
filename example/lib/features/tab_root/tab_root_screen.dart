import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'tab_root_viewmodel.dart';

@RegisterFor<TabRootViewModel>()
class TabRootScreen extends TabBaseWidget {
  const TabRootScreen({super.key, required super.config});

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