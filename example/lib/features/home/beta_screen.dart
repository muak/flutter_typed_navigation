import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'beta_viewmodel.dart';

class BetaScreen extends ConsumerWidget {
  const BetaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('BetaScreen build');
    final state = ref.watch(betaViewModelProvider);
    final viewModel = ref.read(betaViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('BetaScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: viewModel.navigateAlpha,
              child: const Text('Alphaへ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.goBack,
              child: const Text('戻る'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.closeScreen,
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
} 