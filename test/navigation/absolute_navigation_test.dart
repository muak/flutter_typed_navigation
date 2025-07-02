import 'package:flutter_test/flutter_test.dart';
import '../helpers/chaining_assertion.dart';
import '../mocks/mocks.dart';
import 'navigation_test_base.dart';

void main() {
  group('Absolute Navigation Tests', () {
    final base = NavigationTestBase();

    setUp(() {
      base.setUpTest();
    });

    tearDown(() {
      base.tearDownTest();
    });

    testWidgets('基本的なPage遷移（パラメータなし）', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        builder.addNavigator((routeBuilder) {
          routeBuilder.addPage<MockAViewModel>();
        });
        return builder;
      }));
      await base.testPageLifecycle(tester);

      find
          .text('MockAStateInit')
          .shouldBe(findsOneWidget, reason: 'MockAStateInitが表示されていることを確認');

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');

      final vm = base.assertPageLifecycle<MockAViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vm.isActive.shouldBe(true, reason: '1ページのみなので常にアクティブ');
      vm.isDestroyed.shouldBe(false, reason: '1ページのみなのでDestroyされない');
    });

    testWidgets('パラメータ付きのPage遷移', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        builder.addNavigator((routeBuilder) {
          routeBuilder.addPage<MockBViewModel>(param: MockBParameter('bParam'));
        });
        return builder;
      }));

      await base.testPageLifecycle(tester);

      find.text('MockBStateInit bParam').shouldBe(findsOneWidget,
          reason: 'Build後のStateの状態の反映とパラメータが渡されていることを確認');

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はBの1つ');

      final vm = base.assertPageLifecycle<MockBViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vm.isActive.shouldBe(true, reason: '1ページのみなので常にアクティブ');
      vm.isDestroyed.shouldBe(false, reason: '1ページのみなのでDestroyされない');
    });

    testWidgets('Navigatorの複数ページ遷移', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        return builder.addNavigator((routeBuilder) {
          routeBuilder
              .addPage<MockAViewModel>()
              .addPage<MockBViewModel>(param: MockBParameter('bParam'));
        });
      }));

      await base.testPageLifecycle(tester);

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: 'MockAStateInitが表示されていることを確認');
      find
          .text('MockBStateInit bParam', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: 'MockBStateInitが表示されていることを確認');

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(2, reason: 'Navigatorの子要素はA,Bの2つ');

      final vmA = base.assertPageLifecycle<MockAViewModel>(
          ['build', 'onPaused', 'onResumed']);
      vmA.isActive.shouldBe(false, reason: '下層なので非アクティブ');
      vmA.isDestroyed.shouldBe(false, reason: 'まだ破棄対象ではない');

      final vmB = base.assertPageLifecycle<MockBViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vmB.isActive.shouldBe(true, reason: 'カレントページなのでアクティブ');
      vmB.isDestroyed.shouldBe(false, reason: 'まだ破棄対象ではない');

      // 戻る
      base.navigationService.goBack();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つに戻った');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      await base
          .assertPageLifecycle<MockAViewModel>(['onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: '状態が変わってないことを確認');
    });

    final lazyBoolVariant = ValueVariant<bool>({true, false});

    testWidgets('Navigatorの複数ページ遷移(遅延ロード)', (WidgetTester tester) async {
      // 1回目 Navigator自体を遅延ロード
      // 2回目 1つ目の子要素を遅延ロード
      // どちらも結果は同じになる
      await tester.pumpWidget(base.CreateTestApp((builder) {
        return builder.addNavigator((routeBuilder) {
          routeBuilder
              .addPage<MockAViewModel>(isLazy: !lazyBoolVariant.currentValue!)
              .addPage<MockBViewModel>(param: MockBParameter('bParam'));
        }, isLazy: lazyBoolVariant.currentValue!);
      }));

      await base.testPageLifecycle(tester);

      // Navigator自体が遅延ロードになっていると子も遅延ロード扱いとなる
      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsNothing, reason: 'MockAStateInitが表示されていないことを確認');
      // 遅延ロードONになっていてもカレントページはbuildされる
      find
          .text('MockBStateInit bParam', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: 'MockBStateInitが表示されていることを確認');

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(2, reason: 'Navigatorの子要素はA,Bの2つ（遅延ロードでも構造は同じ）');

      base
          .isVmExist<MockAViewModel>()
          .shouldBeFalse(reason: 'MockAViewModelが存在しないことを確認');

      final vmB = base.assertPageLifecycle<MockBViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vmB.isActive.shouldBe(true, reason: 'カレントページなのでアクティブ');
      vmB.isDestroyed.shouldBe(false, reason: 'まだ破棄対象ではない');

      // 戻る
      base.navigationService.goBack();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つに戻った');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      final vmA = await base.assertPageLifecycle<MockAViewModel>(
          ['build', 'onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: '状態が正しく反映されていることを確認');
    }, variant: lazyBoolVariant);

    testWidgets('TabPageの遷移', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        return builder.addTabPage<MockTabbedViewModel>((routeBuilder) {
          routeBuilder
          .addNavigator((navBuilder) {
            navBuilder
              .addPage<MockAViewModel>()
              .addPage<MockBViewModel>(param: MockBParameter('bParam'));
          })
          .addNavigator((navBuilder) {
            navBuilder.addPage<MockCViewModel>();
          });
        }, selectedIndex: 1);
      }));

      await base.testPageLifecycle(tester);

      find
        .text('MockAStateInit', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockAStateInitが表示されていることを確認');
      find
        .text('MockBStateInit bParam', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockBStateInitが表示されていることを確認');
      find
        .text('MockCStateInit', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockCStateInitが表示されていることを確認');

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getTabEntry(0).children.length.shouldBe(2, reason: 'Tabは2つ');
      base.getNavigatorEntryInTab(0, 0).children.length.shouldBe(2, reason: 'Tabの子要素はA,Bの2つ');
      base.getNavigatorEntryInTab(0, 1).children.length.shouldBe(1, reason: 'Tabの子要素はCの1つ');

      final vmA = base.assertPageLifecycle<MockAViewModel>(
          ['build', 'onPaused', 'onResumed']);
      vmA.isActive.shouldBeFalse(reason: '下層なので非アクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      final vmB = base.assertPageLifecycle<MockBViewModel>(
          ['build', 'onPaused', 'onResumed']);
      vmB.isActive.shouldBeFalse( reason: '選択されていないので非アクティブ');
      vmB.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      final vmC = base.assertPageLifecycle<MockCViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vmC.isActive.shouldBeTrue(reason: 'カレントページなのでアクティブ');
      vmC.isDestroyed.shouldBeFalse( reason: 'まだ破棄対象ではない');

      // タブを切り替える
      base.navigationService.changeTab(0);
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getTabEntry(0).children.length.shouldBe(2, reason: 'Tabは2つ');

      base.assertPageLifecycle<MockBViewModel>(['onActiveFirst', 'onActive']);
      vmB.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      base.assertPageLifecycle<MockCViewModel>(['onInActive']);
      vmC.isActive.shouldBeFalse(reason: '非アクティブになった');

      find
        .text('MockBStateInit bParam', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: '状態が変わってないことを確認');
      
      // 戻る
      base.navigationService.goBack();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getTabEntry(0).children.length.shouldBe(2, reason: 'Tabは2つ');
      base.getNavigatorEntryInTab(0, 0).children.length.shouldBe(1, reason: 'Tabの子要素はAの1つに戻った');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      await base
          .assertPageLifecycle<MockAViewModel>(['onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: '状態が変わってないことを確認');
    });

    testWidgets('TabPageの遷移(遅延ロード)', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        return builder.addTabPage<MockTabbedViewModel>((routeBuilder) {
          routeBuilder
          .addNavigator((navBuilder) {
            navBuilder
              .addPage<MockAViewModel>()
              .addPage<MockBViewModel>(param: MockBParameter('bParam'));
          }, isLazy: !lazyBoolVariant.currentValue!)
          .addNavigator((navBuilder) {
            navBuilder.addPage<MockCViewModel>();
          }, isLazy: !lazyBoolVariant.currentValue!);
        }, selectedIndex: 1, isLazy: lazyBoolVariant.currentValue!);
      }));

      await base.testPageLifecycle(tester);

      // Lazyロード対象のページは表示されない
      find
        .text('MockAStateInit', skipOffstage: false)
        .shouldBe(findsNothing, reason: 'MockAStateInitが表示されていないことを確認');
      // Lazyロード対象のページは表示されない
      find
        .text('MockBStateInit bParam', skipOffstage: false)
        .shouldBe(findsNothing, reason: 'MockBStateInitが表示されていないことを確認');
      // カレントページは表示される
      find
        .text('MockCStateInit', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockCStateInitが表示されていることを確認');

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getTabEntry(0).children.length.shouldBe(2, reason: 'Tabは2つ');
      base.getNavigatorEntryInTab(0, 0).children.length.shouldBe(2, reason: 'Tabの子要素はA,Bの2つ（遅延ロードでも構造は同じ）');
      base.getNavigatorEntryInTab(0, 1).children.length.shouldBe(1, reason: 'Tabの子要素はCの1つ');

      base.isVmExist<MockAViewModel>().shouldBeFalse(reason: 'MockAViewModelが存在しないことを確認');
      base.isVmExist<MockBViewModel>().shouldBeFalse(reason: 'MockBViewModelが存在しないことを確認');
      
      // タブページのViewModelはライフサイクルの対象外
      var vmTabbed = base.assertPageLifecycle<MockTabbedViewModel>(
          ['build']);
      vmTabbed.isActive.shouldBeFalse(reason: 'Active系ライフサイクルの対象外');
      vmTabbed.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      
      final vmC = base.assertPageLifecycle<MockCViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vmC.isActive.shouldBeTrue(reason: 'カレントページなのでアクティブ');
      vmC.isDestroyed.shouldBeFalse( reason: 'まだ破棄対象ではない');

      // タブを切り替える
      base.navigationService.changeTab(0);
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getTabEntry(0).children.length.shouldBe(2, reason: 'Tabは2つ');

      base.isVmExist<MockAViewModel>().shouldBeFalse(reason: 'MockAViewModelが存在しないことを確認');
      // 遅延ロードによるMockBのビルドが走る
      final vmB =base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst', 'onActive']);
      vmB.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmB.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      vmC.isActive.shouldBeFalse(reason: '非アクティブになった');

      find
        .text('MockBStateInit bParam', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'カレントになったことで表示される');
      find
        .text('MockAStateInit', skipOffstage: false)
        .shouldBe(findsNothing, reason: '非アクティブなので表示されない');
      
      // 戻る
      base.navigationService.goBack();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'Modalスタックは1つ');
      base.getTabEntry(0).children.length.shouldBe(2, reason: 'Tabは2つ');
      base.getNavigatorEntryInTab(0, 0).children.length.shouldBe(1, reason: 'Tabの子要素はAの1つに戻った');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      // 遅延ロードによるMockAのビルドが走る
      final vmA = base
          .assertPageLifecycle<MockAViewModel>(['build','onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      vmC.isDestroyed.shouldBeFalse(reason: '非アクティブになっただけでまだ破棄対象ではない');

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: 'カレントになったことで表示される');
    }, variant: lazyBoolVariant);

    testWidgets('多段モーダル遷移', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        return builder
        .addNavigator((navBuilder) {
          navBuilder.addPage<MockAViewModel>();
        })
        .addNavigator((navBuilder){
          navBuilder.addPage<MockBViewModel>(param: MockBParameter('bParam'));
        });
      }));

      await base.testPageLifecycle(tester);

      find
        .text('MockAStateInit', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockAStateInitが表示されていることを確認');
      find
        .text('MockBStateInit bParam', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockBStateInitが表示されていることを確認');

      base.modalStack.length.shouldBe(2, reason: 'Modalスタックは2つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');
      base.getNavigatorEntry(1).children.length.shouldBe(1, reason: 'Navigatorの子要素はBの1つ');

      final vmA = base.assertPageLifecycle<MockAViewModel>(
          ['build', 'onPaused', 'onResumed']);
      vmA.isActive.shouldBeFalse(reason: '下層なので非アクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      final vmB = base.assertPageLifecycle<MockBViewModel>(
          ['build', 'onActiveFirst', 'onActive', 'onPaused', 'onResumed']);
      vmB.isActive.shouldBeTrue(reason: 'カレントページなのでアクティブ');
      vmB.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      // モーダルを閉じる
      base.navigationService.closeModal();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: 'モーダルが閉じられてModalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はAの1つ');

      base.assertPageLifecycle<MockAViewModel>(['onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find
        .text('MockAStateInit', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: '状態が変わってないことを確認');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
    });

    testWidgets('絶対遷移の破棄パターン', (WidgetTester tester) async {
      await tester.pumpWidget(base.CreateTestApp((builder) {
        return builder
        .addNavigator((navBuilder) {
          navBuilder
          .addPage<MockAViewModel>()
          .addPage<MockBViewModel>(param: MockBParameter('bParam'));
        });
      }));

      // さらに絶対遷移を行う
      base.navigationService.createAbsoluteBuilder()
      .addNavigator((navBuilder) {
        navBuilder
        .addPage<MockCViewModel>();
      }).setRoutes();

      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1, reason: '絶対遷移によりModalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(1, reason: 'Navigatorの子要素はCの1つ');

      final vmA = base.assertPageLifecycle<MockAViewModel>(['build','destroy']);
      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive','destroy']);
      final vmC = base.assertPageLifecycle<MockCViewModel>(['build','onActiveFirst','onActive']);

      // 前のStackのViewModelは破棄される
      vmA.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
      vmC.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmC.isActive.shouldBeTrue(reason: 'カレントページなのでアクティブ');
      
      find
        .text('MockCStateInit', skipOffstage: false)
        .shouldBe(findsOneWidget, reason: 'MockCStateInitが表示されていることを確認');
    });
  });


}
