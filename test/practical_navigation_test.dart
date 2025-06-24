import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/flutter_typed_navigation.dart';
import 'mocks/test_parameter.dart';

/// 実際のNavigationServiceとViewRegistryを使用した実用的なテスト
/// MAUIテストに近い実装パターンで動作確認
void main() {
  group('Practical NavigationService Tests', () {
    late ProviderContainer container;
    late NavigationService navigationService;
    
    setUp(() {
      container = ProviderContainer();
      navigationService = container.read(navigationServiceProvider);
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('ViewRegistry Integration Tests', () {
      test('ViewRegistryの基本登録機能', () {
        // Act & Assert - ViewRegistry自体の動作確認
        expect(() {
          navigationService.register((registry) {
            // ViewRegistryが利用可能であることを確認
            expect(registry, isNotNull);
          });
        }, returnsNormally);
      });
    });
    
    group('AbsoluteNavigation Builder Tests', () {      
      test('基本的なAbsoluteNavigationBuilder構築', () {
        // Act - Builderの作成と基本的な構造のみテスト
        final builder = navigationService.createAbsoluteBuilder();
        
        // Assert - エラーが発生しないことを確認
        expect(builder, isNotNull);
        expect(builder, isA<AbsoluteNavigationBuilder>());
      });
      
      test('AbsoluteBuilderのaddNavigator呼び出し', () {
        // Act & Assert - エラーが発生しないことを確認
        expect(() {
          final builder = navigationService.createAbsoluteBuilder();
          builder.addNavigator((routeBuilder) {
            // NavigatorBuilderが渡されることを確認
            expect(routeBuilder, isNotNull);
          });
        }, returnsNormally);
      });
      
      test('複数NavigatorのAbsoluteBuilder構築', () {
        // Act & Assert - エラーが発生しないことを確認
        expect(() {
          final builder = navigationService.createAbsoluteBuilder();
          
          builder
            .addNavigator((routeBuilder) {
              expect(routeBuilder, isNotNull);
            })
            .addNavigator((routeBuilder) {
              expect(routeBuilder, isNotNull);
            });
        }, returnsNormally);
      });
    });
    
    group('RelativeNavigation Builder Tests', () {
      test('基本的なRelativeNavigationBuilder構築', () {
        // Act - Builderの作成のみテスト
        final builder = navigationService.createRelativeBuilder();
        
        // Assert - エラーが発生しないことを確認
        expect(builder, isNotNull);
        expect(builder, isA<RelativeNavigationBuilder>());
      });
      
      test('RelativeBuilderのaddBack呼び出し', () {
        // Act & Assert - エラーが発生しないことを確認
        expect(() {
          final builder = navigationService.createRelativeBuilder();
          builder.addBack();
        }, returnsNormally);
      });
      
      test('RelativeBuilderのaddDelay呼び出し', () {
        // Act & Assert - エラーが発生しないことを確認
        expect(() {
          final builder = navigationService.createRelativeBuilder();
          builder.addDelay(500);
        }, returnsNormally);
      });
      
      test('RelativeBuilderの連続操作', () {
        // Act & Assert - エラーが発生しないことを確認
        expect(() {
          final builder = navigationService.createRelativeBuilder();
          
          builder
            .addDelay(100)
            .addBack()
            .addDelay(200);
        }, returnsNormally);
      });
    });
    
    group('Navigation Builder State Tests', () {
      test('AbsoluteBuilderの連続操作', () {
        // Act & Assert
        expect(() {
          final builder = navigationService.createAbsoluteBuilder();
          
          // 複数のaddNavigatorを連続実行
          builder
            .addNavigator((routeBuilder) {
              expect(routeBuilder, isNotNull);
            })
            .addNavigator((routeBuilder) {
              expect(routeBuilder, isNotNull);
            });
        }, returnsNormally);
      });
      
      test('RelativeBuilderの連続操作', () {
        // Act & Assert
        expect(() {
          final builder = navigationService.createRelativeBuilder();
          
          // 複数の操作を連続実行
          builder
            .addDelay(100)
            .addBack()
            .addDelay(200)
            .addBack();
        }, returnsNormally);
      });
      
      test('複数のBuilderを独立して作成', () {
        // Act & Assert - 複数のBuilderが独立して動作することを確認
        expect(() {
          final absoluteBuilder1 = navigationService.createAbsoluteBuilder();
          final absoluteBuilder2 = navigationService.createAbsoluteBuilder();
          final relativeBuilder1 = navigationService.createRelativeBuilder();
          final relativeBuilder2 = navigationService.createRelativeBuilder();
          
          // それぞれが独立していることを確認
          expect(absoluteBuilder1, isNot(same(absoluteBuilder2)));
          expect(relativeBuilder1, isNot(same(relativeBuilder2)));
          expect(absoluteBuilder1, isNot(same(relativeBuilder1)));
        }, returnsNormally);
      });
    });
    
    group('NavigationService State Management Tests', () {
      test('setRoutesの基本動作', () {
        // Act & Assert - 空配列でのsetRoutes
        expect(() {
          navigationService.setRoutes([]);
        }, returnsNormally);
      });
      
      test('複数回のregister呼び出し', () {
        // Act & Assert - 複数回registerを呼び出してもエラーが発生しない
        expect(() {
          navigationService.register((registry) {
            expect(registry, isNotNull);
          });
          
          navigationService.register((registry) {
            expect(registry, isNotNull);
          });
        }, returnsNormally);
      });
      
      test('NavigationServiceの状態確認メソッド', () {
        // Act & Assert - NavigationServiceが提供するメソッドが呼び出し可能
        expect(() {
          // これらのメソッドが存在し、呼び出し可能であることを確認
          expect(navigationService.createAbsoluteBuilder, isA<Function>());
          expect(navigationService.createRelativeBuilder, isA<Function>());
          expect(navigationService.register, isA<Function>());
          expect(navigationService.setRoutes, isA<Function>());
        }, returnsNormally);
      });
    });
  });
}