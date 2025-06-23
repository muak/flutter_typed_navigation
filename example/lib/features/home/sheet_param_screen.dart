import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sheet_param_viewmodel.dart';

class SheetParamScreen extends ConsumerWidget {
  final SheetParam param;
  const SheetParamScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sheetParamViewModelProvider(param));
    final viewModel = ref.read(sheetParamViewModelProvider(param).notifier);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SheetParamScreen: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.closeSheet,
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
} 