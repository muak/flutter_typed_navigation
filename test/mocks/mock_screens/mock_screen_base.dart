import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mock_viewmodels/mock_viewmodel_base.dart';

/// テスト用Screen基底クラス
abstract class MockScreenBase extends ConsumerWidget {
  final MockViewModelBase viewModel;
  bool _isDestroyed = false;
  
  bool get isDestroyed => _isDestroyed;
  
  MockScreenBase({super.key, required this.viewModel});

  void destroy() {
    _isDestroyed = true;
    viewModel.destroy();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(runtimeType.toString())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Mock Screen: ${runtimeType}'),
            Text('ViewModel: ${viewModel.runtimeType}'),
            Text('Is Active: ${viewModel.isActive}'),
            Text('Is Destroyed: ${viewModel.isDestroyed}'),
            if (viewModel.parameters != null)
              Text('Parameters: ${viewModel.parameters}'),
          ],
        ),
      ),
    );
  }
}