import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabConfigState{
  final Provider<List<Widget>> childrenProvider;
  final Provider<int> currentIndexProvider;
  final void Function(int) setCurrentIndex; 

  TabConfigState({required this.childrenProvider, required this.currentIndexProvider, required this.setCurrentIndex});
}

class TabBaseWidget extends ConsumerWidget {
  final TabConfigState config;
  const TabBaseWidget({super.key, required this.config});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}