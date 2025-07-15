/// ViewRegistryの自動登録のためのアノテーション
/// 
/// Viewクラスに付与することで、指定されたViewModelとの
/// 組み合わせでViewRegistryに自動登録される
/// 
/// 使用例:
/// ```dart
/// @RegisterFor<MyViewModel>()
/// class MyScreen extends StatelessWidget {
///   // ...
/// }
/// ```
class RegisterFor<T> {
  const RegisterFor();
} 