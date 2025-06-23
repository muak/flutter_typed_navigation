import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alpha_result_viewmodel.g.dart';

@riverpod
class AlphaResultViewModel extends _$AlphaResultViewModel with ViewModelCore {
  @override
  void build() {}

  Future<void> closeScreenWithResult(String result) async {
    await ref.read(navigationServiceProvider).goBackResult(result);
  }
}
