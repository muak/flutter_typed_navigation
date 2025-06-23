import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'alpha_param_viewmodel.dart';

class AlphaParamScreen extends ConsumerWidget {  
  const AlphaParamScreen(this.param,{super.key});
  final AlphaParam param;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alphaParamViewModelProvider(param));
    final viewModel = ref.read(alphaParamViewModelProvider(param).notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('AlphaParamScreen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('AlphaParamScreen: ${state.message}'),
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