import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_detail_viewmodel.freezed.dart';
part 'home_detail_viewmodel.g.dart';

class HomeDetailParam {
  final String message;
  HomeDetailParam(this.message);
}

@freezed
abstract class HomeDetailState with _$HomeDetailState {
  const factory HomeDetailState({
    @Default('') String message,
  }) = _HomeDetailState;
}

@riverpod
class HomeDetailViewModel extends _$HomeDetailViewModel with ViewModelCore {
  @override
  HomeDetailState build(HomeDetailParam param) {
    debugPrint('HomeDetailViewModel build');
    return HomeDetailState(message: param.message);
  }

  @override
  void onActiveFirst() {
    debugPrint('HomeDetailViewModel onActiveFirst');
  }

  @override
  void onActive() {
    debugPrint('HomeDetailViewModel onActive');
  }
  @override
  void onInActive() {
    debugPrint('HomeDetailViewModel onInActive');
  }

  @override
  void onPaused() {
    debugPrint('HomeDetailViewModel onPaused');
  }

  @override
  void onResumed() {
    debugPrint('HomeDetailViewModel onResumed');
  }

  void closeScreen() {
    ref.read(navigationServiceProvider).goBack();
  }
}