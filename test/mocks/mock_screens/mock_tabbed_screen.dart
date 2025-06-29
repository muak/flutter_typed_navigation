import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

import '../mock_viewmodels/mock_tabbed_viewmodel.dart';

class MockTabbedScreen extends TabBaseWidget {
  const MockTabbedScreen({super.key, required super.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(config.currentIndexProvider);
    final viewModel = ref.watch(mockTabbedViewModelProvider);

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'TabA'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'TabB'),
        ],
      ),
    );
  }
}