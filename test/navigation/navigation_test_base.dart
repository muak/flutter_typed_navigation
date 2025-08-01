import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:flutter_typed_navigation/src/internal_navigation_service.dart';
import '../helpers/chaining_assertion.dart';
import '../mocks/mock_app.dart';
import '../mocks/mock_viewmodels/mock_viewmodel_base.dart';
import '../mocks/mocks.dart';

class NavigationTestBase {
  late MockApp mockApp;
  late NavigationService navigationService;
  late ProviderContainer container;

  Widget CreateTestApp(
      AbsoluteNavigationBuilder Function(AbsoluteNavigationBuilder builder)
          startUp) {
    // 毎回新しいコンテナを作成
    container = ProviderContainer();
    navigationService = container.read(navigationServiceProvider);
    navigationService.register((regisgtry) {
      regisgtry
        .register<MockAViewModel>(
            () => const MockAScreen(), mockAViewModelProvider.notifier)
        .registerWithParameter<MockBViewModel>(
            (p) => MockBScreen(parameter: p),
            (p) => mockBViewModelProvider(p).notifier)
        .register<MockCViewModel>(
            () => const MockCScreen(), mockCViewModelProvider.notifier)
        .register<MockDViewModel>(
            () => const MockDScreen(), mockDViewModelProvider.notifier)
        .register<MockEViewModel>(
            () => const MockEScreen(), mockEViewModelProvider.notifier)
        .register<MockFViewModel>(
            () => const MockFScreen(), mockFViewModelProvider.notifier)
        .register<MockGViewModel>(
            () => const MockGScreen(), mockGViewModelProvider.notifier)
        .register<MockHViewModel>(
            () => const MockHScreen(), mockHViewModelProvider.notifier)
        .register<MockIViewModel>(
            () => const MockIScreen(), mockIViewModelProvider.notifier)
        .register<MockJViewModel>(
            () => const MockJScreen(), mockJViewModelProvider.notifier)
        .register<MockPopScopeViewModel>(
            () => const MockPopScopeScreen(), mockPopScopeViewModelProvider.notifier)
        .registerTab<MockTabbedViewModel>((config) =>  MockTabbedScreen(config: config), mockTabbedViewModelProvider.notifier);
    });

    startUp(navigationService.createAbsoluteBuilder()).setRoutes();
    mockApp = MockApp();
    return UncontrolledProviderScope(
      container: container,
      child: mockApp,
    );
  }

  List<NavigationEntry> get modalStack => container.read(navigationServiceStateProvider).stack;

  NavigatorEntry getNavigatorEntry(int modalIndex){
    return modalStack[modalIndex] as NavigatorEntry;
  }

  TabEntry getTabEntry(int modalIndex){
    return modalStack[modalIndex] as TabEntry;
  }
  NavigatorEntry getNavigatorEntryInTab(int modalIndex, int tabIndex){
    return getTabEntry(modalIndex).children[tabIndex];
  }

  void setUpTest() {
    ViewModelStack.clearCallVmStack();
  }

  void tearDownTest() {
    mockApp.dispose();
  }

  Future<MockViewModelBase> setUpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(CreateTestApp((builder) {
      return builder.addNavigator((navBuilder) {
        navBuilder.addPage<MockAViewModel>();
      });
    }));

    return ViewModelStack.callVmStack.whereType<MockAViewModel>().last;
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

  bool isVmExist<T>() {
    return ViewModelStack.callVmStack.whereType<T>().isNotEmpty;
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
