import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modal_tab_alpha_next_viewmodel.dart';

class ModalTabAlphaNextScreen extends ConsumerWidget {
  const ModalTabAlphaNextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ModalTabAlphaNextScreen build');
    final state = ref.watch(modalTabAlphaNextViewModelProvider);
    final viewModel = ref.read(modalTabAlphaNextViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('ModalTabAlphaNextScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [                  
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.goBack,
              child: const Text('戻る'),
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