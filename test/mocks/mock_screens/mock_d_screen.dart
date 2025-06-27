import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_d_viewmodel.dart';

class MockDScreen extends ConsumerWidget {
  const MockDScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(mockDViewModelProvider.notifier);
    return SizedBox.shrink();
  }
}