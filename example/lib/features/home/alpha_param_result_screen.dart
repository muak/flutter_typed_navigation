import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'alpha_param_result_viewmodel.dart';

class AlphaParamResultScreen extends ConsumerWidget {
  final AlphaParamResult param;
  const AlphaParamResultScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alphaParamResultViewModelProvider(param));
    final viewModel = ref.read(alphaParamResultViewModelProvider(param).notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('AlphaParamResultScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AlphaParamResultScreen: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.closeScreenWithResult('Result: ${state.message}'),
              child: const Text('値を返して閉じる'),
            ),
          ],
        ),
      ),
    );
  }
} 