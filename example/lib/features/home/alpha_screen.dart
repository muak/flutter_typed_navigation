import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'alpha_viewmodel.dart';

@RegisterFor<AlphaViewModel>()
class AlphaScreen extends ConsumerWidget {
  const AlphaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('AlphaScreen build');
    ref.watch(alphaViewModelProvider);
    final viewModel = ref.read(alphaViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('AlphaScreen')),
      body: Center(
        child: ElevatedButton(
          onPressed: viewModel.closeScreen,
          child: const Text('閉じる'),
        ),
      ),
    );
  }
} 