import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_h_viewmodel.dart';

class MockHScreen extends ConsumerWidget {
  const MockHScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockHViewModelProvider);
    final viewModel = ref.read(mockHViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
} 