import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mocks/test_parameter.dart';
import 'widget_mock_viewmodels.dart';

/// Widget Test用のMock Screen基底クラス
abstract class WidgetMockScreenBase extends ConsumerWidget {
  const WidgetMockScreenBase({super.key});
}

/// Mock A Screen（パラメータなし）
class WidgetMockAScreen extends WidgetMockScreenBase {
  const WidgetMockAScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(widgetMockAViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock A Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mock A Screen'),
            Text('Active: ${viewModel.isActive}'),
            Text('Destroyed: ${viewModel.isDestroyed}'),
            Text('Actions: ${viewModel.actionLogQueue.length}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // RelativeNavigationBuilder経由でMock Bに遷移
                // 実際のテストではnavigationServiceを使用
              },
              child: const Text('Navigate to B'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock B Screen（パラメータあり）
class WidgetMockBScreen extends WidgetMockScreenBase {
  final TestParameter? parameter;
  
  const WidgetMockBScreen(this.parameter, {super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(widgetMockBViewModelProvider(parameter));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock B Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mock B Screen'),
            if (parameter != null) 
              Text('Parameter: ${parameter!.value}'),
            Text('Active: ${viewModel.isActive}'),
            Text('Destroyed: ${viewModel.isDestroyed}'),
            Text('Actions: ${viewModel.actionLogQueue.length}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // RelativeNavigationBuilder経由でMock Cに遷移
                // 実際のテストではnavigationServiceを使用
              },
              child: const Text('Navigate to C'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Back navigation
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock C Screen（パラメータあり）
class WidgetMockCScreen extends WidgetMockScreenBase {
  final TestParameter? parameter;
  
  const WidgetMockCScreen(this.parameter, {super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(widgetMockCViewModelProvider(parameter));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock C Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Mock C Screen'),
            if (parameter != null) 
              Text('Parameter: ${parameter!.value}'),
            Text('Active: ${viewModel.isActive}'),
            Text('Destroyed: ${viewModel.isDestroyed}'),
            Text('Actions: ${viewModel.actionLogQueue.length}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 結果を返してBack navigation
                Navigator.of(context).pop('Result from C');
              },
              child: const Text('Return Result'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // 通常のBack navigation
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock Tab Root Screen
class WidgetMockTabRootScreen extends WidgetMockScreenBase {
  final dynamic config;
  
  const WidgetMockTabRootScreen({required this.config, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(widgetMockTabRootViewModelProvider);
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mock Tab Root Screen'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tab 1'),
              Tab(text: 'Tab 2'),
              Tab(text: 'Tab 3'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tab 1 Content'),
                  Text('Active: ${viewModel.isActive}'),
                  Text('Destroyed: ${viewModel.isDestroyed}'),
                ],
              ),
            ),
            const Center(child: Text('Tab 2 Content')),
            const Center(child: Text('Tab 3 Content')),
          ],
        ),
      ),
    );
  }
}