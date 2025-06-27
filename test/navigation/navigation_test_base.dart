import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import '../helpers/chaining_assertion.dart';
import '../mocks/mock_app.dart';
import '../mocks/mock_viewmodels/mock_viewmodel_base.dart';
import '../mocks/mocks.dart';

class NavigationTestBase {
  late MockApp mockApp;
  late NavigationService navigationService;

  Widget CreateTestApp(
      AbsoluteNavigationBuilder Function(AbsoluteNavigationBuilder builder)
          startUp) {
    // 毎回新しいコンテナを作成
    final container = ProviderContainer();
    navigationService = container.read(navigationServiceProvider);
    navigationService.register((regisgtry) {
      regisgtry
          .register<MockAViewModel>(
              mockAViewModelProvider.notifier, () => const MockAScreen())
          .registerWithParameter<MockBViewModel>(
              (p) => mockBViewModelProvider(p).notifier,
              (p) => MockBScreen(parameter: p))
          .register<MockCViewModel>(
              mockCViewModelProvider.notifier, () => const MockCScreen())
          .register<MockDViewModel>(
              mockDViewModelProvider.notifier, () => const MockDScreen())
          .register<MockEViewModel>(
              mockEViewModelProvider.notifier, () => const MockEScreen())
          .register<MockFViewModel>(
              mockFViewModelProvider.notifier, () => const MockFScreen());
    });

    startUp(navigationService.createAbsoluteBuilder()).setRoutes();
    mockApp = MockApp();
    return UncontrolledProviderScope(
      container: container,
      child: mockApp,
    );
  }

  void setUpTest() {
    ViewModelStack.clearCallVmStack();
  }

  void tearDownTest() {
    mockApp.dispose();
  }

  Future<void> testPageLifecycle(WidgetTester tester) async {
    await tester.pump(Duration(milliseconds: 100));
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(Duration(milliseconds: 100));
    WidgetsBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(Duration(milliseconds: 100));
  }

  MockViewModelBase assertPageLifecycle<T>(List<String> actions) {
    final vm = ViewModelStack.callVmStack.whereType<T>().lastOrNull;
    vm.shouldBeNotNull(reason: '該当する型のViewModelが存在することを確認');

    final mockVm = vm as MockViewModelBase;
    mockVm.actionLogQueue.length.shouldBe(actions.length,
        reason: '${actions.join(', ')} の順番で実行されていることを確認');
    for (var action in actions) {
      mockVm.actionLogQueue.removeFirst().shouldBe(action);
    }
    return mockVm;
  }
}
