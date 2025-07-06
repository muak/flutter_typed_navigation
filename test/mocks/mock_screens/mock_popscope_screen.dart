import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_popscope_viewmodel.dart';

class MockPopScopeScreen extends ConsumerWidget {
  const MockPopScopeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockPopScopeViewModelProvider);
    final viewModel = ref.read(mockPopScopeViewModelProvider.notifier);
    
    return PopScope(
      canPop: state.canPop,
      onPopInvokedWithResult: viewModel.onPopInvokedWithResult,
      child: Text(
        state.value,
      ),
    );
  }
}