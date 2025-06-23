export 'sheet_result_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sheet_result_viewmodel.dart';

class SheetResultScreen extends ConsumerWidget {
  const SheetResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // stateは不要な場合でもViewModel経由で取得
    ref.watch(sheetResultViewModelProvider);
    final viewModel = ref.read(sheetResultViewModelProvider.notifier);
    return SizedBox(
      height: 200,
      child: Center(
        child: ElevatedButton(
          onPressed: () => viewModel.closeSheetWithResult('OK!'),
          child: const Text('値を返して閉じる'),
        ),
      ),
    );
  }
} 