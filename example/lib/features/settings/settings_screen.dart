import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('SettingsScreen build');
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('ダークモード'),
              value: state.isDarkMode,
              onChanged: (_) => viewModel.toggleDarkMode(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/accountSettings');
              },
              child: Text('アカウント設定へ'),
            ),
          ],
        ),
      ),
    );
  }
}