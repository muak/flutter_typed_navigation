import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_a_viewmodel.dart';

class MockAScreen extends ConsumerWidget {
  const MockAScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockAViewModelProvider);
    final viewModel = ref.read(mockAViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
}
