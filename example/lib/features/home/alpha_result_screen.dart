import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'alpha_result_viewmodel.dart';

class AlphaResultScreen extends ConsumerWidget {
  const AlphaResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(alphaResultViewModelProvider);
    final viewModel = ref.read(alphaResultViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('AlphaResultScreen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => viewModel.closeScreenWithResult('AlphaResult OK!'),
          child: const Text('値を返して戻る'),
        ),
      ),
    );
  }
} 