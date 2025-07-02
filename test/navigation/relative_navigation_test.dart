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

    testWidgets('PopToRoot Navigation', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);

      // MockB→MockCに遷移する
      base.navigationService.createRelativeBuilder()
        .addPage<MockBViewModel>(param: MockBParameter('bParam'))
        .addPage<MockCViewModel>()
        .navigate();

      await tester.pumpAndSettle(Duration(milliseconds: 100));

      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive','onInActive']);
      final vmC = base.assertPageLifecycle<MockCViewModel>(['build','onActiveFirst','onActive']);

      // ルートに戻る
      base.navigationService.goBackToRoot();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
      vmC.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      vmA.isActive.shouldBeTrue(reason: 'カレントページになったのでアクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      find.text('MockAStateInit').shouldBe(findsOneWidget, reason: '表示されていることを確認');
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

    testWidgets('Complex Builder Pattern', (WidgetTester tester) async {
      final vmA = await base.setUpHomePage(tester);

      // MockB→MockCに遷移する
      base.navigationService.createRelativeBuilder()        
        .addPage<MockBViewModel>(param: MockBParameter('bParam'))
        .addPage<MockCViewModel>()
        .navigate();

      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(1,reason: 'Modalスタックは1つ');
      base.getNavigatorEntry(0).children.length.shouldBe(3,reason: 'Navigatorの子要素はA,B,Cの3つ');     

      // 複雑な相対遷移を実行
      base.navigationService.createRelativeBuilder()
        .addBack()
        .addBack()
        .addPage<MockDViewModel>()
        .addNavigator((navBuilder) {
          navBuilder
          .addPage<MockEViewModel>();
        })
        .addPage<MockFViewModel>()
        .addTabPage<MockTabbedViewModel>((tabBuilder) {
          tabBuilder
          .addNavigator((navBuilder) {
            navBuilder
            .addPage<MockGViewModel>()
            .addPage<MockHViewModel>();
          })
          .addNavigator((navBuilder) {
            navBuilder
            .addPage<MockIViewModel>();
          });
        })
        .addChangeTab(1)
        .addPage<MockJViewModel>()        
        .navigate();

      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(3,reason: 'Modalスタックは3つ');
      base.getNavigatorEntry(0).children.length.shouldBe(2,reason: 'Navigatorの子要素はA,Dの2つ');  
      base.getNavigatorEntry(1).children.length.shouldBe(2,reason: 'Navigatorの子要素はE,Fの2つ');  
      base.getTabEntry(2).children.length.shouldBe(2,reason: 'Tabは2つ');  
      base.getNavigatorEntryInTab(2, 0).children.length.shouldBe(2,reason: 'Tabの子要素はG,Hの2つ'); 
      base.getNavigatorEntryInTab(2, 1).children.length.shouldBe(2,reason: 'Tabの子要素はI,Jの2つ'); 

      find.text('MockAStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockDStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockEStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockFStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockGStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockHStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockIStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');
      find.text('MockJStateInit', skipOffstage: false).shouldBe(findsOneWidget, reason: '表示されていることを確認');

      vmA.isActive.shouldBeFalse(reason: '非アクティブ');
      vmA.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');

      final vmB = base.assertPageLifecycle<MockBViewModel>(['build','onActiveFirst','onActive','onInActive','onActive','destroy']);
      vmB.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      final vmC = base.assertPageLifecycle<MockCViewModel>(['build','onActiveFirst','onActive','destroy']);
      vmC.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      final vmD = base.assertPageLifecycle<MockDViewModel>(['build','onActiveFirst','onActive','onInActive']);
      vmD.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmD.isActive.shouldBeFalse(reason: '非アクティブ');

      final vmE = base.assertPageLifecycle<MockEViewModel>(['build','onActiveFirst','onActive','onInActive']);
      vmE.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmE.isActive.shouldBeFalse(reason: '非アクティブ');

      final vmF = base.assertPageLifecycle<MockFViewModel>(['build','onActiveFirst','onActive','onInActive']);
      vmF.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmF.isActive.shouldBeFalse(reason: '非アクティブ');

      final vmG = base.assertPageLifecycle<MockGViewModel>(['build']);
      vmG.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmG.isActive.shouldBeFalse(reason: '非アクティブ');

      final vmH = base.assertPageLifecycle<MockHViewModel>(['build','onActiveFirst','onActive','onInActive']);
      vmH.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmH.isActive.shouldBeFalse(reason: '非アクティブ');

      final vmI = base.assertPageLifecycle<MockIViewModel>(['build','onActiveFirst','onActive','onInActive']);
      vmI.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmI.isActive.shouldBeFalse(reason: '非アクティブ');

      final vmJ = base.assertPageLifecycle<MockJViewModel>(['build','onActiveFirst','onActive',]);
      vmJ.isDestroyed.shouldBeFalse(reason: 'まだ破棄対象ではない');
      vmJ.isActive.shouldBeTrue(reason: 'アクティブ');    

      // モーダルを閉じる(TABまるごと閉じる)
      base.navigationService.closeModal();
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      base.modalStack.length.shouldBe(2,reason: 'モーダルが1つ閉じたのでModalスタックは2つ');

      vmG.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
      vmH.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
      vmI.isDestroyed.shouldBeTrue(reason: '破棄対象になった');
      vmJ.isDestroyed.shouldBeTrue(reason: '破棄対象になった');

      vmF.isActive.shouldBeTrue(reason: 'アクティブ');
    });
  });
}