import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typed_navigation/src/navigation_router_delegate.dart';
import '../helpers/chaining_assertion.dart';
import '../mocks/mocks.dart';
import 'navigation_test_base.dart';

void main() {
  group('BackButton Navigation Tests', () {
    final base = NavigationTestBase();
    late NavigationRouterDelegate routerDelegate;

    setUp(() {
      base.setUpTest();
    });

    tearDown(() {
      base.tearDownTest();
      // MethodChannelのモックハンドラーをクリーンアップ
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_typed_navigation'),
        null,
      );
    });

    testWidgets('BackButton with single page should minimize app', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');
      
      // MethodChannelをモック化
      bool minimizeAppCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_typed_navigation'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'minimizeApp') {
            minimizeAppCalled = true;
            return true;
          }
          return null;
        },
      );
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      minimizeAppCalled.shouldBeTrue(reason: 'minimizeAppが呼ばれる');
      
      // ViewModelは破棄されない
      vmA.isDestroyed.shouldBeFalse(reason: 'ViewModelはアプリ最小化では破棄されない');
      vmA.isActive.shouldBeTrue(reason: 'ViewModelはアクティブのまま');
    });

    testWidgets('BackButton with multiple pages should go back', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // MockBに遷移
      base.navigationService.navigate<MockBViewModel>(param: MockBParameter('bParam'));
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(2, reason: 'Navigatorの子要素はA,Bの2つ');
      
      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive']);
      vmB.isActive.shouldBeTrue(reason: 'MockBがアクティブ');
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      
      // 戻ったかの確認
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つに戻った');
      
      vmA.isActive.shouldBeTrue(reason: 'MockAがアクティブに戻った');
      vmB.isDestroyed.shouldBeTrue(reason: 'MockBは破棄された');
    });

    testWidgets('BackButton with modal should close modal', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // MockBをモーダルで開く
      base.navigationService.navigateModal<MockBViewModel>(param: MockBParameter('bParam'));
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      base.modalStack.length.shouldBe(2, reason: 'Modalスタックは2つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');
      base.getNavigatorEntry(1).children.length.shouldBe(1, reason: 'Navigatorの子要素はBの1つ');
      
      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive']);
      vmB.isActive.shouldBeTrue(reason: 'MockBがアクティブ');
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      
      // モーダルが閉じられたかの確認
      base.modalStack.length.shouldBe(1, reason: 'モーダルが閉じられてModalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');
      
      vmA.isActive.shouldBeTrue(reason: 'MockAがアクティブに戻った');
      vmB.isDestroyed.shouldBeTrue(reason: 'MockBは破棄された');
    });

    testWidgets('BackButton with multiple modals should close top modal', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // MockBをモーダルで開く
      base.navigationService.navigateModal<MockBViewModel>(param: MockBParameter('bParam'));
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      // MockCをさらにモーダルで開く
      base.navigationService.navigateModal<MockCViewModel>();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      base.modalStack.length.shouldBe(3, reason: 'Modalスタックは3つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');
      base.getNavigatorEntry(1).children.length.shouldBe(1, reason: 'Navigatorの子要素はBの1つ');
      base.getNavigatorEntry(2).children.length.shouldBe(1, reason: 'Navigatorの子要素はCの1つ');
      
      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive','onInActive']);
      final vmC = base.assertPageLifecycle<MockCViewModel>(['build','onActiveFirst','onActive']);
      vmC.isActive.shouldBeTrue(reason: 'MockCがアクティブ');
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      
      // トップモーダルが閉じられたかの確認
      base.modalStack.length.shouldBe(2, reason: 'トップモーダルが閉じられてModalスタックは2つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');
      base.getNavigatorEntry(1).children.length.shouldBe(1, reason: 'Navigatorの子要素はBの1つ');
      
      vmB.isActive.shouldBeTrue(reason: 'MockBがアクティブに戻った');
      vmC.isDestroyed.shouldBeTrue(reason: 'MockCは破棄された');
    });

    testWidgets('BackButton with no current navigator should return true', (WidgetTester tester) async {
      await base.setUpHomePage(tester);
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // 強制的にmodalStackをクリア（異常状態のシミュレート）
      base.modalStack.clear();
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      
      result.shouldBeTrue(reason: 'NavigatorEntryが存在しない場合はtrueを返す');
    });

    testWidgets('BackButton with complex navigation structure', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // 複雑な階層を構築
      base.navigationService.createRelativeBuilder()
        .addPage<MockBViewModel>(param: MockBParameter('bParam'))
        .addPage<MockCViewModel>()
        .addNavigator((navBuilder) {
          navBuilder.addPage<MockDViewModel>();
        })
        .navigate();
      
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      base.modalStack.length.shouldBe(2, reason: 'Modalスタックは2つ');
      base.getNavigatorEntry(0).children.length.shouldBe(3, reason: 'Navigatorの子要素はA,B,Cの3つ');
      base.getNavigatorEntry(1).children.length.shouldBe(1, reason: 'Navigatorの子要素はDの1つ');
      
      final vmD = base.assertPageLifecycle<MockDViewModel>(['build','onActiveFirst','onActive']);
      vmD.isActive.shouldBeTrue(reason: 'MockDがアクティブ');
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      
      // トップモーダルが閉じられたかの確認
      base.modalStack.length.shouldBe(1, reason: 'トップモーダルが閉じられてModalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(3, reason: 'Navigatorの子要素はA,B,Cの3つ');
      
      final vmC = base.assertPageLifecycle<MockCViewModel>(['build','onActiveFirst','onActive','onInActive','onActive']);
      vmC.isActive.shouldBeTrue(reason: 'MockCがアクティブに戻った');
      vmD.isDestroyed.shouldBeTrue(reason: 'MockDは破棄された');
    });

    testWidgets('BackButton with PopScope canPop=true should call onPopInvokedWithResult and pop', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // MockPopScopeViewModelに遷移（canPop=trueで開始）
      base.navigationService.navigate<MockPopScopeViewModel>();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(2, reason: 'Navigatorの子要素はA,PopScopeの2つ');
      
      final vmPopScope = base.assertPageLifecycle<MockPopScopeViewModel>(['build','onActiveFirst','onActive']) as MockPopScopeViewModel;
      vmPopScope.isActive.shouldBeTrue(reason: 'MockPopScopeViewModelがアクティブ');
      vmPopScope.canPop.shouldBeTrue(reason: 'canPopはtrueに設定されている');
      vmPopScope.onPopInvokedCalled.shouldBeFalse(reason: 'まだonPopInvokedWithResultは呼ばれていない');
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      
      // onPopInvokedWithResultが呼ばれ、実際にPopしたことを確認
      vmPopScope.onPopInvokedCalled.shouldBeTrue(reason: 'onPopInvokedWithResultが呼ばれた');
      
      // 戻ったかの確認
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つに戻った');
      
      vmA.isActive.shouldBeTrue(reason: 'MockAがアクティブに戻った');
      vmPopScope.isDestroyed.shouldBeTrue(reason: 'MockPopScopeViewModelは破棄された');
    });

    testWidgets('BackButton with PopScope canPop=false should call onPopInvokedWithResult and still pop', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);
      
      // MockPopScopeViewModelに遷移
      base.navigationService.navigate<MockPopScopeViewModel>();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      final vmPopScope = base.assertPageLifecycle<MockPopScopeViewModel>(['build','onActiveFirst','onActive']) as MockPopScopeViewModel;
      
      // canPopをfalseに設定
      vmPopScope.setCanPop(false);
      vmPopScope.canPop.shouldBeFalse(reason: 'canPopはfalseに設定されている');
      vmPopScope.resetOnPopInvokedCalled();
      
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(2, reason: 'Navigatorの子要素はA,PopScopeの2つ');
      
      // NavigationRouterDelegateの取得（MockAppから直接取得）
      routerDelegate = base.mockApp.routerDelegate;
      
      // BackButtonの動作をシミュレート
      final result = await routerDelegate.popRoute();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      result.shouldBeTrue(reason: 'popRouteはtrueを返す');
      
      // onPopInvokedWithResultが呼ばれ、canPop=falseでもプログラムからのpopRoute()では実際にPopされることを確認
      vmPopScope.onPopInvokedCalled.shouldBeTrue(reason: 'onPopInvokedWithResultが呼ばれた');
      
      // canPop=falseでもpopRoute()では実際にPopしてしまうことを確認
      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つに戻った');
      
      vmA.isActive.shouldBeTrue(reason: 'MockAがアクティブに戻った');
      vmPopScope.isDestroyed.shouldBeTrue(reason: 'MockPopScopeViewModelは破棄された');
    });
  });
}