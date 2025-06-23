import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sheet_param_result_viewmodel.dart';

class SheetParamResultScreen extends ConsumerWidget {
  final SheetParamResult param;
  const SheetParamResultScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sheetParamResultViewModelProvider(param));
    final viewModel = ref.read(sheetParamResultViewModelProvider(param).notifier);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SheetParamResultScreen: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.closeSheetWithResult('Result: \\${state.message}'),
              child: const Text('値を返して閉じる'),
            ),
          ],
        ),
      ),
    );
  }
} 