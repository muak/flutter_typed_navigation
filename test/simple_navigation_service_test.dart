import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/flutter_typed_navigation.dart';

/// NavigationServiceの基本動作確認テスト
/// Widget Testの前段階として実際のNavigationServiceが動作するかテスト
void main() {
  group('Simple NavigationService Tests', () {
    late ProviderContainer container;
    late NavigationService navigationService;
    
    setUp(() {
      container = ProviderContainer();
      navigationService = container.read(navigationServiceProvider);
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('NavigationServiceの初期化確認', () {
      // Assert - NavigationServiceが正しく初期化されている
      expect(navigationService, isNotNull);
      expect(navigationService, isA<NavigationService>());
    });

    test('AbsoluteNavigationBuilderの作成', () {
      // Act
      final builder = navigationService.createAbsoluteBuilder();
      
      // Assert
      expect(builder, isNotNull);
      expect(builder, isA<AbsoluteNavigationBuilder>());
    });

    test('RelativeNavigationBuilderの作成', () {
      // Act
      final builder = navigationService.createRelativeBuilder();
      
      // Assert
      expect(builder, isNotNull);
      expect(builder, isA<RelativeNavigationBuilder>());
    });

    test('ViewRegistryの登録機能', () {
      // Act & Assert - エラーが発生しないことを確認
      expect(() {
        navigationService.register((registry) {
          // 基本的な登録処理（実際のViewModelは登録しない）
        });
      }, returnsNormally);
    });

    test('setRoutesの基本動作', () {
      // Act & Assert - エラーが発生しないことを確認
      expect(() {
        navigationService.setRoutes([]);
      }, returnsNormally);
    });

    test('AbsoluteBuilderの基本操作', () {
      // Act - AbsoluteBuilderの作成のみテスト
      final builder = navigationService.createAbsoluteBuilder();
      
      // Assert - エラーが発生しないことを確認
      expect(builder, isNotNull);
      expect(builder, isA<AbsoluteNavigationBuilder>());
    });

    test('RelativeBuilderの基本操作', () {
      // Act - RelativeBuilderの作成のみテスト
      final builder = navigationService.createRelativeBuilder();
      
      // Assert - エラーが発生しないことを確認
      expect(builder, isNotNull);
      expect(builder, isA<RelativeNavigationBuilder>());
    });
  });
}