import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typed_navigation/flutter_typed_navigation.dart';
import 'home_viewmodel.dart';

@RegisterFor<HomeViewModel>()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('HomeScreen build');
    final state = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        automaticallyImplyLeading: false,        
      ),
      body: SingleChildScrollView(
        child: Center(
          child: state.isLoading
              ? const CircularProgressIndicator()
              : state.error.isNotEmpty
                  ? Text('Error: ${state.error}')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Running on: ${state.platformVersion}\n'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.loadPlatformVersion,
                          child: const Text('再取得'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.absoluteNavigate,
                          child: const Text('絶対遷移'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.navigateAlpha,
                          child: const Text('Alpha画面へ（遷移のみ）'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.navigateAlphaResult,
                          child: const Text('AlphaResult画面へ（戻り値あり）'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.navigateAlphaParam,
                          child: const Text('AlphaParam画面へ（パラメータ渡し）'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.navigateAlphaParamResult,
                          child: const Text('AlphaParamResult画面へ（パラメータ+戻り値）'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.navigateModal,
                          child: const Text('モーダル画面へ(Navigator)'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.navigateModalResult,
                          child: const Text('モーダル画面へ(Navigator+戻り値)'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.navigateModalTab,
                          child: const Text('モーダルタブ画面へ(戻り値あり)'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.showSheet,
                          child: const Text('シート表示（戻り値なし）'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.showSheetResult,
                          child: const Text('シート表示（戻り値あり）'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.showSheetParam,
                          child: const Text('シート表示（パラメータ渡し）'),
                        ),
                        ElevatedButton(
                          onPressed: viewModel.showSheetParamResult,
                          child: const Text('シート表示（パラメータ+戻り値）'),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: viewModel.minimizeApp,
                          child: const Text('アプリを最小化'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
        ),
      ),
    );
  }
}

