import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'sheet_viewmodel.g.dart';

@riverpod
class SheetViewModel extends _$SheetViewModel {

  @override
  void build() {}

  void closeSheet() {
    ref.read(navigationServiceProvider).closeBottomSheet();
  }
} 