import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modal_home_viewmodel.dart';

class ModalHomeScreen extends ConsumerWidget {
  const ModalHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ModalHomeScreen build');
    final state = ref.watch(modalHomeViewModelProvider);
    final viewModel = ref.read(modalHomeViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('ModalHomeScreen')),
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
              onPressed: viewModel.closeScreen,
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
} 