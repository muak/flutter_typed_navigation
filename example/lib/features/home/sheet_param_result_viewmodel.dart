import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

part 'sheet_param_result_viewmodel.g.dart';
part 'sheet_param_result_viewmodel.freezed.dart';

class SheetParamResult {
  final String message;
  SheetParamResult(this.message);
}

@freezed
abstract class SheetParamResultState with _$SheetParamResultState {
  const factory SheetParamResultState({
    @Default('') String message,
  }) = _SheetParamResultState;
}

@riverpod
class SheetParamResultViewModel extends _$SheetParamResultViewModel {
  @override
  SheetParamResultState build(SheetParamResult param) => SheetParamResultState(message: param.message);

  void closeSheetWithResult(String result) {
    ref.read(navigationServiceProvider).closeBottomSheetResult(result);
  }
} 