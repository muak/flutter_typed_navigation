import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_i_viewmodel.dart';

class MockIScreen extends ConsumerWidget {
  const MockIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockIViewModelProvider);
    final viewModel = ref.read(mockIViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
} 