import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_g_viewmodel.dart';

class MockGScreen extends ConsumerWidget {
  const MockGScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockGViewModelProvider);
    final viewModel = ref.read(mockGViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
} 