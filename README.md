# flutter_typed_navigation

A typed navigation framework for Flutter with hierarchical routing and state management support.

## Features

- **Type-safe Navigation**: Strongly typed parameter passing with compile-time safety
- **Hierarchical Architecture**: 3-layer navigation structure (Modal → Navigator → Tab)
- **Riverpod Integration**: Built-in state management with Riverpod
- **MVVM Support**: ViewModel lifecycle management with automatic state tracking
- **Result Navigation**: Type-safe result retrieval from navigation operations
- **Modal Support**: Bottom sheets, dialogs, and custom modal presentations
- **Builder Pattern**: Declarative navigation construction with fluent API
- **Performance Optimized**: Lazy rendering with build flags for inactive pages

## Architecture

```
ModalStack (List<NavigationEntry>)     // Modal layer management
├── NavigatorStack (List<PageEntry>)   // Page stack management
    └── TabStack (List<NavigatorEntry>) // Tab container management
```

## Quick Start

### 1. Registration

```dart
navigationService.register((registry) {
  registry
    .register<HomeViewModel>(homeViewModelProvider.notifier, () => const HomeScreen())
    .registerWithParameter<DetailViewModel>(
      (p) => detailViewModelProvider(p).notifier, 
      (p) => DetailScreen(p)
    );
});
```

### 2. Navigation

```dart
// Basic navigation
await navigationService
  .createRelativeBuilder()
  .addPage<HomeViewModel>()
  .navigate();

// Parameter passing
await navigationService
  .createRelativeBuilder()
  .addPage<DetailViewModel>(param: DetailParam('data'))
  .navigate();

// Result retrieval
final result = await navigationService
  .createRelativeBuilder()
  .addPage<ResultViewModel>()
  .navigateResult<String>();
```

### 3. ViewModel

```dart
@riverpod
class HomeViewModel extends _$HomeViewModel with ViewModelCore {
  @override
  void build() {}

  @override
  void onActive() {
    // Called when page becomes active
  }

  @override
  void onInActive() {
    // Called when page becomes inactive
  }
}
```

## License

MIT License