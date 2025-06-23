export 'sheet_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sheet_viewmodel.dart';

class SheetScreen extends ConsumerWidget {
  const SheetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(sheetViewModelProvider);
    final viewModel = ref.read(sheetViewModelProvider.notifier);
    return SizedBox(
      height: 200,
      child: Center(
        child: ElevatedButton(
          onPressed: viewModel.closeSheet,
          child: const Text('閉じる'),
        ),
      ),
    );
  }
} 