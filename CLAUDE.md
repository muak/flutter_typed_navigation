# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

flutter_typed_navigationは、型安全なナビゲーションとRiverpod状態管理を統合したFlutterプラグインフレームワークです。

## プロジェクト構造

```
flutter_typed_navigation/
├── lib/                        # メインプラグインコード
│   ├── flutter_typed_navigation.dart
│   └── src/                    # コア実装
│       ├── navigation_service.dart          # NavigationServiceインターフェース
│       ├── internal_navigation_service.dart # Riverpod Notifier実装
│       ├── navigation_router_delegate.dart  # Flutterルーターデリゲート
│       ├── navigation_entry.dart            # 階層型ナビゲーションデータ構造
│       ├── navigation_segment.dart          # ナビゲーション操作設定
│       ├── navigation_state.dart            # イミュータブル状態管理
│       ├── absolute_navigation_builder.dart # 絶対パスナビゲーション構築
│       ├── relative_navigation_builder.dart # 相対パスナビゲーション構築
│       ├── view_registry.dart               # ViewModelとView登録システム
│       ├── viewmodel_core.dart              # ViewModelライフサイクル管理
│       └── tab_base_widget.dart             # タブベースナビゲーション基底
├── example/                    # デモンストレーション用サンプルアプリ
│   ├── lib/
│   │   ├── features/           # 機能別モジュール
│   │   │   ├── home/          # ホーム機能
│   │   │   ├── modal/         # モーダル機能
│   │   │   ├── settings/      # 設定機能
│   │   │   └── tab_root/      # タブルート機能
│   │   └── main.dart          # アプリエントリーポイント
│   └── pubspec.yaml
├── test/                      # 単体テスト
│   ├── mocks/                 # テスト用モッククラス
│   │   ├── mock_viewmodels/   # MockViewModelクラス群
│   │   └── mock_screens/      # MockScreenクラス群
│   └── navigation/            # ナビゲーション機能テスト
└── pubspec.yaml
```

## 開発コマンド

### 基本セットアップ
```bash
# 依存関係の取得
flutter pub get

# サンプルアプリの依存関係も取得
cd example && flutter pub get && cd ..
```

### コード生成（必須）
Riverpodの`@riverpod`アノテーションとFreezedの`@freezed`を使用しているため、コード生成が必要です。

```bash
# 1. プラグインレベルでのコード生成（テスト用モック含む）
dart run build_runner build --delete-conflicting-outputs

# 2. サンプルアプリレベルでのコード生成
cd example
dart run build_runner build --delete-conflicting-outputs
cd ..

# 開発時はウォッチモードが便利
dart run build_runner watch --delete-conflicting-outputs
```

### テスト実行
```bash
# 全テスト実行
flutter test

# 特定テスト実行
flutter test test/navigation/absolute_navigation_test.dart
flutter test test/navigation/relative_navigation_test.dart

# カバレッジ付きテスト
flutter test --coverage
```

### サンプルアプリ実行
```bash
cd example
flutter run

# プラットフォーム指定
flutter run -d chrome    # Web
flutter run -d macos     # macOS
```

### コード品質チェック
```bash
# 静的解析
flutter analyze

# ⚠️ 重要: dart formatは実行禁止
# dart format .              # 実行しないこと
# dart format --set-exit-if-changed .  # 実行しないこと
```

### ⚠️ dart format 実行禁止
**このプロジェクトでは dart format コマンドの実行を禁止します。**

#### 理由
- 意図しないフォーマット変更により、PRに大量の無関係な変更が混入する
- 実際の機能変更のみをコミットに含めたいため
- レビュー時に本質的な変更を見つけにくくなる

#### 禁止対象
- `dart format .` コマンドの直接実行
- IDE/エディタの自動フォーマット機能の使用
- 保存時の自動フォーマット

#### コミット時の注意
- `git diff` で変更内容を必ず確認
- フォーマット変更が含まれている場合は、機能変更のみを選択的にコミット
- `git add -p` を活用して部分的なステージングを行う

## アーキテクチャ

### 3層階層ナビゲーション構造
```
ModalStack (List<NavigationEntry>)     // モーダル階層管理
├── NavigatorStack (List<PageEntry>)   // ページスタック管理
    └── TabStack (List<NavigatorEntry>) // タブコンテナ管理
```

### 主要コンポーネント

#### NavigationService
- **抽象インターフェース**: `navigation_service.dart`
- **実装クラス**: `internal_navigation_service.dart` (Riverpod Notifier)
- **ルーターデリゲート**: `navigation_router_delegate.dart`

#### ビルダーパターン
- **AbsoluteNavigationBuilder**: 完全に新しいナビゲーションスタック構築
- **RelativeNavigationBuilder**: 現在のスタックに対する相対的な操作

#### 登録システム
- **ViewRegistry**: ViewModelとViewの型安全な登録
- **ViewModelCore**: ライフサイクル管理ミックスイン

### MVVMパターン

#### ViewModel実装
```dart
@riverpod
class ExampleViewModel extends _$ExampleViewModel with ViewModelCore {
  @override
  void build() {}

  @override
  void onActive() {
    // ページアクティブ時の処理
  }

  @override
  void onInActive() {
    // ページ非アクティブ時の処理
  }
}
```

#### Screen実装
```dart
class ExampleScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(exampleViewModelProvider.notifier);
    // UI実装
  }
}
```

#### 登録（main.dart）
```dart
navigationService.register((registry) {
  registry
    .register<ExampleViewModel>(
      exampleViewModelProvider.notifier,
      () => const ExampleScreen()
    )
    .registerWithParameter<ParamViewModel>(
      (p) => paramViewModelProvider(p).notifier,
      (p) => ParamScreen(p)
    );
});
```

## ナビゲーション使用例

### 基本遷移
```dart
// 相対ナビゲーション
await navigationService
  .createRelativeBuilder()
  .addPage<HomeViewModel>()
  .navigate();
```

### パラメータ付き遷移
```dart
await navigationService
  .createRelativeBuilder()
  .addPage<DetailViewModel>(param: DetailParam('data'))
  .navigate();
```

### 結果取得遷移
```dart
final result = await navigationService
  .createRelativeBuilder()
  .addPage<ResultViewModel>()
  .navigateResult<String>();
```

### モーダル表示
```dart
// ボトムシート
await navigationService.showBottomSheet<SheetViewModel>();

// 結果取得ボトムシート
final result = await navigationService
  .showBottomSheetResult<SheetResultViewModel, String>();
```

### タブナビゲーション
```dart
await navigationService
  .createRelativeBuilder()
  .addTabPage<TabRootViewModel>((tabBuilder) {
    tabBuilder
      .addNavigator((navBuilder) {
        navBuilder.addPage<HomeViewModel>();
      }, isBuild: false)
      .addNavigator((navBuilder) {
        navBuilder.addPage<SettingsViewModel>();
      }, isBuild: false);
  }, selectedIndex: 0)
  .navigate();
```

## テスト戦略

### テスト構成
- **Mock Classes**: `test/mocks/` にViewModelとScreenのモッククラス
- **Navigation Tests**: `test/navigation/` に階層ナビゲーションテスト
- **Base Test**: `test/navigation/navigation_test_base.dart` でテスト基盤

### 主要テストケース
- **Absolute Navigation**: 絶対パスナビゲーション
- **Relative Navigation**: 相対パスナビゲーション
- **Result Navigation**: 結果取得ナビゲーション
- **Lifecycle Management**: ViewModelライフサイクル管理

## 重要な開発ルール

### コード生成の実行順序
1. **プラグインレベル**: `dart run build_runner build --delete-conflicting-outputs`
2. **Exampleアプリレベル**: `cd example && dart run build_runner build --delete-conflicting-outputs`

### ViewModelライフサイクル
- `onActiveFirst()`: 初回アクティブ化時
- `onActive()`: アクティブ化時
- `onInActive()`: 非アクティブ化時
- `onPaused()`: アプリ一時停止時
- `onResumed()`: アプリ復帰時

### パフォーマンス最適化
- `isBuild: false`による遅延描画
- 型安全なパラメータ受け渡し
- 効率的なページキャッシュ管理

## 依存関係

### 主要依存関係
- **flutter_riverpod**: 状態管理
- **riverpod_annotation**: Riverpodアノテーション
- **freezed_annotation**: イミュータブルクラス生成

### 開発依存関係
- **riverpod_generator**: コード生成
- **build_runner**: ビルドツール
- **freezed**: イミュータブルクラス生成
- **mockito**: テスト用モック生成