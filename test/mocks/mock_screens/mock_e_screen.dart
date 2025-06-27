import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_e_viewmodel.dart';

class MockEScreen extends ConsumerWidget {
  const MockEScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(mockEViewModelProvider.notifier);
    return SizedBox.shrink();
  }
}