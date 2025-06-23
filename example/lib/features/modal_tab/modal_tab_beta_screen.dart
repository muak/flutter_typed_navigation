import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modal_tab_beta_viewmodel.dart';

class ModalTabBetaScreen extends ConsumerWidget {
  const ModalTabBetaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ModalTabBetaScreen build');
    final state = ref.watch(modalTabBetaViewModelProvider);
    final viewModel = ref.read(modalTabBetaViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('ModalTabBetaScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [                  
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