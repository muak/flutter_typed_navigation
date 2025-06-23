import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sheet_param_viewmodel.g.dart';
part 'sheet_param_viewmodel.freezed.dart';

class SheetParam {
  final String message;
  SheetParam(this.message);
}

@freezed
abstract class SheetParamState with _$SheetParamState {
  const factory SheetParamState({
    @Default('') String message,
  }) = _SheetParamState;
}

@riverpod
class SheetParamViewModel extends _$SheetParamViewModel {
  @override
  SheetParamState build(SheetParam param) => SheetParamState(message: param.message);

  void closeSheet() {
    ref.read(navigationServiceProvider).closeBottomSheet();
  }
} 