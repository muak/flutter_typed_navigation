import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_j_viewmodel.dart';

class MockJScreen extends ConsumerWidget {
  const MockJScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockJViewModelProvider);
    final viewModel = ref.read(mockJViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
} 