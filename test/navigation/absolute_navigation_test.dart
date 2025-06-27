import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/chaining_assertion.dart';
import '../mocks/mock_viewmodels/mock_viewmodel_base.dart';
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

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      await base
          .assertPageLifecycle<MockAViewModel>(['onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: '状態が変わってないことを確認');
    });

    testWidgets('Navigatorの複数ページ遷移(遅延ロード)', (WidgetTester tester) async {
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

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      await base
          .assertPageLifecycle<MockAViewModel>(['onActiveFirst', 'onActive']);
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find
          .text('MockAStateInit', skipOffstage: false)
          .shouldBe(findsOneWidget, reason: '状態が変わってないことを確認');
    });
  });
}
