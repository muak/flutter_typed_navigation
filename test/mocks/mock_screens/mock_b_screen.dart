import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_b_viewmodel.dart';

class MockBScreen extends ConsumerWidget {
  final MockBParameter parameter;
  const MockBScreen({super.key, required this.parameter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mockBViewModelProvider(parameter));
    final viewModel = ref.read(mockBViewModelProvider(parameter).notifier);
    return Text(
      state.value,
    );
  }
}