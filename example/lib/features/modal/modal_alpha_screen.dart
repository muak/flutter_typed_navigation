import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modal_alpha_viewmodel.dart';

class ModalAlphaScreen extends ConsumerWidget {
  const ModalAlphaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ModalAlphaScreen build');
    final state = ref.watch(modalAlphaViewModelProvider);
    final viewModel = ref.read(modalAlphaViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('ModalAlphaScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [          
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