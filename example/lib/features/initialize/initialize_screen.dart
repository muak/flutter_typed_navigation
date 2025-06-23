import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'initialize_viewmodel.dart';

class InitializeScreen extends ConsumerWidget {
  const InitializeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(initializeViewModelProvider);
    
    return Scaffold(
      body: Center(
        child: state.isLoading
            ? const CircularProgressIndicator()
            : const Text('初期化に失敗しました'),
      ),
    );
  }
}
