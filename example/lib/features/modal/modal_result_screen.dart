import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modal_result_viewmodel.dart';

class ModalResultScreen extends ConsumerWidget {  
  const ModalResultScreen(this.param,{super.key});
  final String param;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(modalResultViewModelProvider(param));
    final viewModel = ref.read(modalResultViewModelProvider(param).notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('ModalResultScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('パラメータ: ${state.message}'),
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