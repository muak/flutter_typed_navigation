import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_f_viewmodel.dart';

class MockFScreen extends ConsumerWidget {
  const MockFScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockFViewModelProvider);
    final viewModel = ref.read(mockFViewModelProvider.notifier);
    return Text(
      state.value,
    );
  }
}