import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modal_tab_alpha_viewmodel.dart';

class ModalTabAlphaScreen extends ConsumerWidget {
  const ModalTabAlphaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ModalTabAlphaScreen build');
    final state = ref.watch(modalTabAlphaViewModelProvider);
    final viewModel = ref.read(modalTabAlphaViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('ModalTabAlphaScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [                  
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.goNext,
              child: const Text('次へ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.closeScreen,
              child: const Text('値を返して閉じる'),
            ),
          ],
        ),
      ),
    );
  }
} 