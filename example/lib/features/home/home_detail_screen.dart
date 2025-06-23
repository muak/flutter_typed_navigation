import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_detail_viewmodel.dart';

class HomeDetailScreen extends ConsumerWidget  {
  const HomeDetailScreen(this.param,{super.key});
  final HomeDetailParam param;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('HomeDetailScreen build');
    final state = ref.watch(homeDetailViewModelProvider(param));
    final viewModel = ref.read(homeDetailViewModelProvider(param).notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Home詳細')),
      body: const Center(child: Text('Homeの詳細ページです')),
    );
  }
} 