import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';

// .NET MAUIのViewModel（INotifyPropertyChanged）と同様に状態を管理するが、
// Flutter(Riverpod)ではNotifierを継承し、状態はbuild()で初期化する。
part 'tab_root_viewmodel.g.dart';

@riverpod
class TabRootViewModel extends _$TabRootViewModel with ViewModelCore {
  @override
  void build() {}
} 