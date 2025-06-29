import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_c_viewmodel.dart';

class MockCScreen extends ConsumerWidget {
  const MockCScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockCViewModelProvider);
    final viewModel = ref.read(mockCViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
}