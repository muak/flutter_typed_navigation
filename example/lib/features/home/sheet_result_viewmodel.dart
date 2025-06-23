import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sheet_result_viewmodel.g.dart';

@riverpod
class SheetResultViewModel extends _$SheetResultViewModel {

  @override
  void build() {}

  void closeSheetWithResult(String result) {
    ref.read(navigationServiceProvider).closeBottomSheetResult(result);
  }
} 