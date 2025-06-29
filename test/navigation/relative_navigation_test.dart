import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import '../helpers/chaining_assertion.dart';
import '../mocks/mocks.dart';
import 'navigation_test_base.dart';

void main(){

  group('Relative Navigation Tests', () {

    final base = NavigationTestBase();

    setUp(() {
      base.setUpTest();
    });

    tearDown(() {
      base.tearDownTest();
    });
    
    testWidgets('Forward Backward Navigation', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);

      // MockBに遷移する
      base.navigationService.navigate<MockBViewModel>(param: MockBParameter('bParam'));

      await tester.pumpAndSettle(Duration(milliseconds: 100));

      vmA.isActive.shouldBeFalse(reason: '非アクティブになった');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive']);
      vmB.isActive.shouldBeTrue(reason: 'カレントページなのでアクティブ');
      vmB.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockBStateInit bParam').shouldBe(findsOneWidget, reason: '表示されていることを確認');

      // 戻る
      base.navigationService.goBack();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockAStateInit').shouldBe(findsOneWidget, reason: '表示されていることを確認');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
    });

    testWidgets('Forward Backward Modal Navigation', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);

      // MockBに遷移する
      base.navigationService.navigateModal<MockBViewModel>(param: MockBParameter('bParam'));
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      vmA.isActive.shouldBeFalse(reason: '非アクティブになった');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive']);
      vmB.isActive.shouldBeTrue(reason: 'カレントページなのでアクティブ');
      vmB.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockBStateInit bParam').shouldBe(findsOneWidget, reason: '表示されていることを確認');

      // モーダルを閉じる
      base.navigationService.closeModal();
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      
      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockAStateInit').shouldBe(findsOneWidget, reason: '表示されていることを確認');

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
    });

    testWidgets('Result Navigation', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);

      final completer = Completer<String>();
      base.navigationService.navigateResult<MockBViewModel, String>(param: MockBParameter('bParam')).then((result) {
        completer.complete(result);
      });
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      base.navigationService.goBackResult("OK");   
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      final result = await completer.future;
      result.shouldBe("OK", reason: 'goBackResultの値が取得できた');

      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive','destroy']);
      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockAStateInit').shouldBe(findsOneWidget, reason: '表示されていることを確認');
    });

    testWidgets('Modal Result Navigation', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);

      final completer = Completer<String>();
      base.navigationService.navigateModalResult<MockBViewModel, String>(param: MockBParameter('bParam')).then((result) {
        completer.complete(result);
      });
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      base.navigationService.closeModalResult("OK");
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      final result = await completer.future;
      result.shouldBe("OK", reason: 'closeModalResultの値が取得できた');

      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive','destroy']);
      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockAStateInit').shouldBe(findsOneWidget, reason: '表示されていることを確認');
    });
  });
}